//
//  PageView.swift
//  NewNewNoteTakerApp
//
//  Created by Alexandru Ariton on 25.10.2023.
//

import Foundation
import SwiftUI
import UIKit

enum AddNewLineOptions {
	case justBegunAdding
	case isAdding
	case justFinishedAdding
}

enum SelectLineOptions {
	case justBegunSelecting
	case isSelecting
	case justFinishedSelecting
	func getLineOption() -> AddNewLineOptions {
		if self == .justBegunSelecting {
			return .justBegunAdding
		} else if self == .isSelecting {
			return .isAdding
		} else {
			return .justFinishedAdding
		}
	}
}

class PageView: UIView {
	var pageData: PageData?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.layer.borderWidth = 0.5
		self.layer.borderColor = .init(red: 0, green: 1, blue: 1, alpha: 0.2)
		self.layer.cornerRadius = 5
		let _ = CALayer.gridPattern(in: self.layer)
	}
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	func newLine(locations: [CGPoint], options: AddNewLineOptions, deleteAfter: Bool = false) {
		if options == .justBegunAdding {
			if(Database.context() == nil) {
				return
			}
			let line = LineData(context: Database.context()!)
			line.type = LineType.straightline.rawValue
			line.points = []
			line.parentPage = self.pageData
			
			let currentLineLayer = line.draw(in: self.layer)
			GLOBAL.currentLineDrawingLayer = currentLineLayer
			GLOBAL.currentLine = line
		} else if options == .isAdding {
			guard let drawingLayer = GLOBAL.currentLineDrawingLayer else { return }
			guard let currentLine = GLOBAL.currentLine else { return }
			GLOBAL.currentLine!.points.append(contentsOf: locations)
			drawingLayer.path = UIBezierPath.from(normalizedLine: currentLine)?.cgPath
			if deleteAfter {
				drawingLayer.fillColor = .init(red: 0, green: 1, blue: 1, alpha: 0.2)
			}
		} else if options == .justFinishedAdding {
			guard  let currentLine = GLOBAL.currentLine else { return }
			if deleteAfter {
				GLOBAL.currentLineDrawingLayer?.path = nil
				Database.context()?.delete(GLOBAL.currentLine!)
				Database.save()
			} else {
				self.pageData?.addToLines(currentLine)
			}
			GLOBAL.currentLine = nil
		}
	}
	
	func addLines() {
		for line in GLOBAL.allLinesOfCurrentPage(page: self.pageData) {
			let x = line
			var _ = x.draw(in: self.layer, ignoreMove: false)
			line.layerInSelf = x.layerInSelf
			
		}
	}
	
	static func hit(in view: UIView, touches: Set<UITouch>, event: UIEvent?) -> PageView? {
		let hittest = view.hitTest(touches.first!.location(in: view), with: event)
		if let hitPageView = hittest as? PageView {
			return hitPageView
		}
		return nil
	}
}

extension UIView {
	func imageFromSelf() -> UIImage {
		let renderer = UIGraphicsImageRenderer(bounds: bounds)
		return renderer.image { rendererContext in
			layer.render(in: rendererContext.cgContext)
		}
	}
}
