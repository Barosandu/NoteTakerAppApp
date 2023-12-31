//
//  DrawLineInLayer.swift
//  NewNewNoteTakerApp
//
//  Created by Alexandru Ariton on 24.10.2023.
//

import Foundation
import UIKit
extension UIBezierPath {
	static func from(normalizedLine line: LineData) -> UIBezierPath? {
		let linepoints = line.points.toPoints
		if linepoints.count < 1 {
			return nil
		}
		let path = UIBezierPath()
		path.lineJoinStyle = .round
		path.lineCapStyle = .round
		path.miterLimit = 10
		path.lineWidth = 10
		path.move(to: linepoints[0])
		var points = [CGPoint]()
		if linepoints.count > 3 {
			for n in 1...linepoints.count-2 {
				points.append((linepoints[n-1] + linepoints[n] + linepoints[n+1]) / 3)
			}
		} else {
			points = linepoints
		}
		
		for point in points {
			path.addLine(to: point)
		}
		return path
	}
	
	static func from(points pts: [CGPoint]) -> UIBezierPath? {
		let linepoints = pts
		if linepoints.count < 1 {
			return nil
		}
		let path = UIBezierPath()
		path.lineJoinStyle = .round
		path.lineCapStyle = .round
		path.miterLimit = 10
		path.lineWidth = 10
		path.move(to: linepoints[0])
		var points = [CGPoint]()
		if linepoints.count > 3 {
			for n in 1...linepoints.count-2 {
				points.append((linepoints[n-1] + linepoints[n] + linepoints[n+1]) / 3)
			}
		} else {
			points = linepoints
		}
		
		for point in points {
			path.addLine(to: point)
		}
		return path
	}
	
	static func can(path: CGPath?, beSelectedBy selection: CGPath?) -> Bool {
		guard let path = path else {return false}
		guard let selection = selection else {return false}
		let contour = path.copy(strokingWithWidth: 1.5, lineCap: .round, lineJoin: .round, miterLimit: 10)
		if contour.intersects(selection) {
			return true
		}
		return false
	}
}

extension LineData {
	func draw(in drawingLayer: CALayer, ignoreMove: Bool = true) -> CAShapeLayer? {
		if GLOBAL.currentTool == .move && ignoreMove == true { return nil }
		let path = UIBezierPath.from(normalizedLine: self)
		let layer = CAShapeLayer()
		layer.path = path?.cgPath
		layer.strokeColor = .init(red: 0, green: 0.9, blue: 1, alpha: 1)
		layer.fillColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
		layer.rasterizationScale = 2
		layer.lineCap = .round
		layer.lineJoin = .round
		layer.lineWidth = 1.5
		drawingLayer.addSublayer(layer)
		self.layerInSelf = layer
		return layer
	}
	
	func redrawLayer() {
		self.layerInSelf.transform = CATransform3DMakeTranslation(0, 0, 0)
		self.layerInSelf.path = UIBezierPath.from(normalizedLine: self)?.cgPath
	}
	
	func setLayerTransform(transform: CGPoint) {
		self.layerInSelf.transform = CATransform3DMakeTranslation(transform.x, transform.y, 0)
	}
	
	
}

extension CALayer {
	static func gridPattern(in alayer: CALayer) -> CAShapeLayer {
		let path = UIBezierPath()
		
		let layer = CAShapeLayer()
		alayer.addSublayer(layer)
		
		path.move(to: .zero)
		
		let width = GLOBAL.pageDimensions.width
		let height = GLOBAL.pageDimensions.height
		let gridSize: CGFloat = height / 50
		
		for x in stride(from: 0, through: width, by: gridSize) {
			path.move(to: .init(x: x, y: 0))
			path.addLine(to: .init(x: x, y: height))
		}
		
		for y in stride(from: 0, through: height, by: gridSize) {
			path.move(to: .init(x: 0, y: y))
			path.addLine(to: .init(x: width, y: y))
		}
		
		
		layer.path = path.cgPath
		layer.strokeColor = .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.1)
		layer.fillColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
		layer.rasterizationScale = 1
		layer.lineCap = .round
		layer.lineJoin = .round
		layer.lineWidth = 1
		return layer
	}
}


extension LineData {
	static func getSelectedLines(with selection: UIBezierPath?, from page: PageData, and pageView: PageView) -> [LineData] {
		let lines = GLOBAL.allLinesOfCurrentPage(page: page)
		var answer: [LineData] = []
		
		for line in lines {
			let path = UIBezierPath.from(normalizedLine: line)
			let selected = UIBezierPath.can(path: path?.cgPath, beSelectedBy: selection?.cgPath)
			if selected {
				answer.append(line)
				line.layerInSelf.strokeColor = .init(red: 1, green: 0, blue: 0, alpha: 1)
			} else {
				line.layerInSelf.strokeColor = .init(red: 0, green: 0.9, blue: 1, alpha: 1)
			}
		}
		return answer
	}
}
