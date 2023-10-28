//
//  Lines.swift
//  NewNewNoteTakerApp
//
//  Created by Alexandru Ariton on 24.10.2023.
//

import Foundation
import CoreGraphics
import UIKit
enum LineType: String {
	case pencil = "pencil"
	case straightline = "straightline"
	case move = "move.tool"
	case select = "select.tool"
}

@objc(CALayerValueTransformer)
final class CALayerValueTransformer: NSSecureUnarchiveFromDataTransformer {
	override class var allowedTopLevelClasses: [AnyClass] {
		return super.allowedTopLevelClasses + [CALayer.self]
	}
}

@objc(UIImageValueTransformer)
final class UIImageValueTransformer: NSSecureUnarchiveFromDataTransformer {
	override class var allowedTopLevelClasses: [AnyClass] {
		return super.allowedTopLevelClasses + [UIImage.self]
	}
}
