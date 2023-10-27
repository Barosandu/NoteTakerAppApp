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
	
	func checkTouchesAndAddNewLine(_ touches: Set<UITouch>, with event: UIEvent?, options: AddNewLineOptions) {
		if GLOBAL.currentTool == .move {
			GLOBAL.currentTool = .pencil
		}
		let locations = self.getCoalescedLocations(from: touches, with: event)
		self.currentPageView.newLine(locations: locations, options: options)
	}
	
	
	private var touchesOfLasso: [CGPoint] = []
	func selectLines(_ touches: Set<UITouch>, with event: UIEvent?, options: AddNewLineOptions) {
		let locations = self.getCoalescedLocations(from: touches, with: event)
		self.touchesOfLasso.append(contentsOf: locations)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let pageView = PageView.hit(in: self, touches: touches, event: event)
		guard let pageView = pageView else {
			GLOBAL.currentLineDrawingLayer = nil
			return
		}
		self.currentPageView = pageView
		if(touches.first!.type == .pencil) {
			self.checkTouchesAndAddNewLine(touches, with: event, options: .justBegunAdding)
		} else {
			GLOBAL.currentTool = .move
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if(touches.first!.type == .pencil) {
			self.checkTouchesAndAddNewLine(touches, with: event, options: .isAdding)
		} else {
			GLOBAL.currentTool = .move
		}
		
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if(touches.first!.type == .pencil) {
			self.checkTouchesAndAddNewLine(touches, with: event, options: .justFinishedAdding)
		} else {
			GLOBAL.currentTool = .move
		}
		GLOBAL.currentTool = .move
	}
}
