//
//  CanvasView.swift
//  NewNewNoteTakerApp
//
//  Created by Alexandru Ariton on 25.10.2023.
//

import Foundation
import UIKit
class CanvasView: UIScrollView {
	var rootMainView: RootMainContent!
	weak var parent: CanvasViewController?
	var currentPageView: PageView! {
		willSet {
			self.parent?.currentPage = newValue
		}
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		NotificationCenter.default.addObserver(forName: .toggleScrollingBehaviour, object: nil, queue: nil, using: self.toggleScrollingBehaviour(notification:))
		self.delaysContentTouches = false
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	func toggleScrollingBehaviour(notification: Notification) -> Void {
		let object = notification.object as! Bool
		self.isScrollEnabled = object
	}
	
	func getCoalescedLocations(from touches: Set<UITouch>, with event: UIEvent?) -> [CGPoint] {
		var preciseTouches = [UITouch]()
		for touch in touches {
			let coalesced = event?.coalescedTouches(for: touch)
			preciseTouches.append(contentsOf: coalesced ?? [])
		}
		let locations = preciseTouches.map { touch in
			touch.location(in: self.currentPageView)
		}
		return locations
	}
	
	func checkTouchesAndAddNewLine(_ touches: Set<UITouch>, with event: UIEvent?, options: AddNewLineOptions, deleteAfter: Bool = false) {
		if GLOBAL.currentTool == .move {
			GLOBAL.currentTool = .pencil
		}
		let locations = self.getCoalescedLocations(from: touches, with: event)
		self.currentPageView.newLine(locations: locations, options: options, deleteAfter: deleteAfter)
	}
	
	
	private var touchesOfLasso: [CGPoint] = []
	private var selection: UIBezierPath? = nil
	private var selectedLines: [LineData]? = nil
	private var isMovingLines: Bool = false
	func selectLines(_ touches: Set<UITouch>, with event: UIEvent?, options: SelectLineOptions) -> UIBezierPath? {
		let locations = self.getCoalescedLocations(from: touches, with: event)
		self.touchesOfLasso.append(contentsOf: locations)
		
		self.checkTouchesAndAddNewLine(touches, with: event, options: options.getLineOption(), deleteAfter: true)
		
		if options != .justFinishedSelecting {
			return nil
		}
		// Did finish selecting
		let selection = UIBezierPath.from(points: self.touchesOfLasso)
		return selection
	}
	
	func resetSelection() {
		self.selection = nil
		for line in self.selectedLines ?? [] {
			line.layerInSelf.shouldRasterize = false
			line.redrawLayer()
		}
		self.selectedLines = nil
		self.touchesOfLasso = []
		_ = LineData.getSelectedLines(with: nil, from: self.currentPageView.pageData!, and: self.currentPageView)
	}
	
	private var offsetAllAlong: CGPoint = .zero
	
	func moveSelectedLines(_ touches: Set<UITouch>, event: UIEvent?, didFinishSelection: Bool = false) {
		
		let coalesced = self.getCoalescedLocations(from: touches, with: event)
		self.touchesMovedOffset = coalesced.first!
		var offset = CGPoint.zero
		
		if let fv = self._touchesMovedOffset.firstValue {
			offset = self.touchesMovedOffset - fv
		}
		for line in self.selectedLines ?? [] {
			if didFinishSelection == false {
				CATransaction.begin()
				CATransaction.setDisableActions(true)
				line.setLayerTransform(transform: offset)
				CATransaction.commit()
				self.offsetAllAlong =  offset
			} else {
				line.points.translate(by: self.offsetAllAlong)
				CATransaction.begin()
				CATransaction.setDisableActions(true)
				line.redrawLayer()
				CATransaction.commit()
			}
			
		}
		if(didFinishSelection) {
			self.offsetAllAlong = .zero
			self.touchesMovedOffset = .zero
			self.touchesMovedOffset = .zero
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let pageView = PageView.hit(in: self, touches: touches, event: event)
		guard let pageView = pageView else {
			GLOBAL.currentLineDrawingLayer = nil
			return
		}
		self.currentPageView = pageView
		if let selection = self.selection, let _ = self.selectedLines {
			let firstTouchLocation = touches.first!.location(in: self.currentPageView)
			if selection.contains(firstTouchLocation) {
				self.isMovingLines = true
				self.offsetAllAlong = .zero
				self.touchesMovedOffset = .zero
				self.touchesMovedOffset = .zero
				self._touchesMovedOffset.resetFirstVal()
				
			} else {
				self.isMovingLines = false
				self.resetSelection()
				GLOBAL.currentTool = .move
			}
			return
		}
		if(GLOBAL.currentTool == .select) {
			let _ = self.selectLines(touches, with: event, options: .justBegunSelecting)
			return
		}
		if(touches.first!.type == .pencil) {
			self.checkTouchesAndAddNewLine(touches, with: event, options: .justBegunAdding)
		} else {
			GLOBAL.currentTool = .move
		}
	}
	
	@InstantaneousValue<CGPoint> var touchesMovedOffset: CGPoint = .zero
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if self.isMovingLines && GLOBAL.currentTool == .select {
			self.moveSelectedLines(touches, event: event)
			return
		}
		if(GLOBAL.currentTool == .select) {
			let _ = self.selectLines(touches, with: event, options: .isSelecting)
			return
		}
		if(touches.first!.type == .pencil) {
			self.checkTouchesAndAddNewLine(touches, with: event, options: .isAdding)
		} else {
			GLOBAL.currentTool = .move
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if(self.isMovingLines) {
			print("Yes")
			self.moveSelectedLines(touches, event: event, didFinishSelection: true)
			self.isMovingLines = false
			GLOBAL.currentTool = .select
			GLOBAL.currentLine = nil
			GLOBAL.currentLineDrawingLayer = nil
			self.touchesMovedOffset = .zero
			self.resetSelection()
			
		}
		if(GLOBAL.currentTool == .select) {
			let selectionPath = self.selectLines(touches, with: event, options: .justFinishedSelecting)
			self.selection = selectionPath
			let selectedLines = LineData.getSelectedLines(with: selectionPath!, from: self.currentPageView.pageData!, and: self.currentPageView)
			self.selectedLines = selectedLines
			
			return
		}
		if(touches.first!.type == .pencil) {
			self.checkTouchesAndAddNewLine(touches, with: event, options: .justFinishedAdding)
		} else {
			GLOBAL.currentTool = .move
		}
		GLOBAL.currentTool = .move
	}
}
