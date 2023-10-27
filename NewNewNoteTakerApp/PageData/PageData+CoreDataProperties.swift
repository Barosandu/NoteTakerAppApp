//
//  PageData+CoreDataProperties.swift
//  NewNewNoteTakerApp
//
//  Created by Alexandru Ariton on 27.10.2023.
//
//

import Foundation
import CoreData


extension PageData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PageData> {
        return NSFetchRequest<PageData>(entityName: "PageData")
    }

    @NSManaged public var id: String?
    @NSManaged public var pageNumber: Int64
    @NSManaged public var parentNote: NoteData?
    @NSManaged public var lines: Set<LineData>
	
	static func newPage(id: String, number: Int, parentNote: NoteData?) -> PageData? {
		if Database.context() == nil {
			return nil
		}
		let page = PageData(context: Database.context()!)
		page.id = id
		page.pageNumber = Int64(number)
		page.parentNote = parentNote
		parentNote?.addToPages(page)
		
		return page
	}

}

// MARK: Generated accessors for lines
extension PageData {

    @objc(addLinesObject:)
    @NSManaged public func addToLines(_ value: LineData)

    @objc(removeLinesObject:)
    @NSManaged public func removeFromLines(_ value: LineData)

    @objc(addLines:)
    @NSManaged public func addToLines(_ values: NSSet)

    @objc(removeLines:)
    @NSManaged public func removeFromLines(_ values: NSSet)

}

extension PageData : Identifiable {

}
