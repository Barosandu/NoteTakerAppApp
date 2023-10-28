//
//  Globals.swift
//  NewNewNoteTakerApp
//
//  Created by Alexandru Ariton on 24.10.2023.
//

import Foundation
import UIKit
import CoreData

class GLOBAL {
	static var noteThumbnailDimensions = GLOBAL.pageDimensions / 3
	static var currentNote: NoteData? = nil {
		willSet {
			if self.currentNote?.id != newValue?.id {
				NotificationCenter.default.post(name: .changedSelectedNote, object: nil)
			}
		}
	}
	static var currentLineDrawingLayer: CAShapeLayer? = nil
	static var currentLine: LineData? = nil
	static func allLinesOfCurrentPage(page: PageData?) -> [LineData] {
		if page == nil {
			return []
		}
		return Array(page!.lines)
	}
	static var pageDimensions = CGSize.init(width: 210 * 2.5, height: 297 * 2.5)
	static private var _currentTool: LineType = .move
	static var currentTool: LineType {
		get {
			return self._currentTool
		}
		set {
			self._currentTool = newValue
			if self._currentTool == .move {
				NotificationCenter.default.post(name: .toggleScrollingBehaviour, object: true)
			} else {
				NotificationCenter.default.post(name: .toggleScrollingBehaviour, object: false)
			}
		}
	}
}

@propertyWrapper class InstantaneousValue<T: AdditiveArithmetic> {
	private var presentValue: T
	private(set) var oldValue: T?
	private(set) var firstValue: T?
	var instantaneousChange: T? {
		get {
			if(self.oldValue == nil) {
				return nil
			}
			return presentValue - oldValue!
		}
	}
	var wrappedValue: T {
		get {
			return presentValue
		}
		set(val) {
			if self.wrappedValue != .zero && self.firstValue == nil {
				self.firstValue = val
			}
			self.oldValue = self.presentValue
			self.presentValue = val
		}
	}
	
	init(wrappedValue: T) {
		self.presentValue = wrappedValue
		self.oldValue = T.zero
		self.firstValue = nil
		self.wrappedValue = wrappedValue
	}
	
	func resetFirstVal() {
		self.firstValue = nil
	}
	
}

class Database {
	static func context() -> NSManagedObjectContext? {
		let context = AppDelegate.shared?.persistenceContainer.viewContext
		return context
	}
	
	static func save() {
		do {
			try Database.context()?.save()
		} catch {
			print(error.localizedDescription)
		}
	}
	
}

