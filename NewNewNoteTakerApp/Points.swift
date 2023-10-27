//
//  Points.swift
//  NewNewNoteTakerApp
//
//  Created by Alexandru Ariton on 24.10.2023.
//

import Foundation
import CoreGraphics
extension Array<CGPoint> {
	func revert(fromScale scale: CGFloat, andOffset offset: CGPoint) -> Self {
		let newPoints = self.map { pt -> CGPoint in
			let pdef = (pt - offset) / scale
			return pdef
		}
		return newPoints
	}
	
	func convert(toScale scale: CGFloat, andOffset offset: CGPoint) -> Self {
		let newPoints = self.map { pt -> CGPoint in
			let pdef = pt * scale - offset
			return pdef
		}
		return newPoints
	}
	
	mutating func translate(by offset: CGPoint) {
		for i in 0..<self.count {
			self[i] = self[i] + offset
		}
	}
}


infix operator +: AdditionPrecedence
infix operator -: AdditionPrecedence
infix operator *: MultiplicationPrecedence
infix operator /: MultiplicationPrecedence

extension CGPoint: AdditiveArithmetic {
	public static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}
	
	public static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}
	
	public static func *(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
		CGPoint(x: lhs * rhs.x, y: lhs * rhs.y)
	}
	
	public static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
		CGPoint(x: rhs * lhs.x, y: rhs * lhs.y)
	}
	
	public static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
		CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
	}
}

extension CGSize: AdditiveArithmetic {
	public static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
		CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
	}
	
	public static func -(lhs: CGSize, rhs: CGSize) -> CGSize {
		CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
	}
	
	public static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
		CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
	}
	
	public static func *(lhs: CGFloat, rhs: CGSize) -> CGSize {
		CGSize(width: rhs.width * lhs, height: rhs.height * lhs)
	}
	
	public static func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
		CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
	}
}
