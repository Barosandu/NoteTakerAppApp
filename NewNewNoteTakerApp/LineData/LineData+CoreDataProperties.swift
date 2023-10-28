//
//  LineData+CoreDataProperties.swift
//  NewNewNoteTakerApp
//
//  Created by Alexandru Ariton on 27.10.2023.
//
//

import Foundation
import CoreData

import UIKit
extension LineData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LineData> {
        return NSFetchRequest<LineData>(entityName: "LineData")
    }

    @NSManaged public var lineID: UUID?
    @NSManaged public var type: String?
    @NSManaged public var points: [String]
    @NSManaged public var parentPage: PageData?
	@NSManaged public var layerInSelf: CAShapeLayer
	
	
	
}

extension LineData : Identifiable {

}

extension String {
	func add(cgPoint: CGPoint) -> String {
		let r = NSCoder.cgPoint(for: self) + cgPoint
		return NSCoder.string(for: r)
	}
}

extension Array<String> {
	mutating func append(contentsOf s: [CGPoint]) {
		let a = s.map { pt in
			NSCoder.string(for: pt)
		}
		self.append(contentsOf: a)
	}
	
	mutating func translate(by: CGPoint) {
		for i in 0..<self.count {
			self[i] = self[i].add(cgPoint: by)
		}
	}
}
