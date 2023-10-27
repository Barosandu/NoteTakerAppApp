//
//  LineData+CoreDataProperties.swift
//  NewNewNoteTakerApp
//
//  Created by Alexandru Ariton on 27.10.2023.
//
//

import Foundation
import CoreData


extension LineData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LineData> {
        return NSFetchRequest<LineData>(entityName: "LineData")
    }

    @NSManaged public var lineID: UUID?
    @NSManaged public var type: String?
    @NSManaged public var points: [String]
    @NSManaged public var parentPage: PageData?
	
	
}

extension LineData : Identifiable {

}

extension Array<String> {
	mutating func append(contentsOf s: [CGPoint]) {
		let a = s.map { pt in
			NSCoder.string(for: pt)
		}
		self.append(contentsOf: a)
	}
}
