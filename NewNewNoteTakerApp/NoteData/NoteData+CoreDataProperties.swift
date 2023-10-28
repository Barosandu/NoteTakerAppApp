//
//  NoteData+CoreDataProperties.swift
//  NewNewNoteTakerApp
//
//  Created by Alexandru Ariton on 27.10.2023.
//
//

import Foundation
import CoreData
import UIKit


extension NoteData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteData> {
        return NSFetchRequest<NoteData>(entityName: "NoteData")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: UUID?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var pageCount: Int64
    @NSManaged public var pages: Set<PageData>
	@NSManaged public var thumbnail: UIImage
	
	func getSortedPages() -> [PageData] {
		return pages.sorted { a, b in
			a.pageNumber < b.pageNumber
		}
	}
	
	static func newNote(name: String) -> NoteData? {
		if Database.context() == nil {
			return nil
		}
		let note = NoteData(context: Database.context()!)
		note.name = name
		note.id = UUID()
		note.dateCreated = Date()
		note.thumbnail = UIImage.init()
		return note
		
	}

}

// MARK: Generated accessors for pages
extension NoteData {

    @objc(insertObject:inPagesAtIndex:)
    @NSManaged public func insertIntoPages(_ value: PageData, at idx: Int)

    @objc(removeObjectFromPagesAtIndex:)
    @NSManaged public func removeFromPages(at idx: Int)

    @objc(insertPages:atIndexes:)
    @NSManaged public func insertIntoPages(_ values: [PageData], at indexes: NSIndexSet)

    @objc(removePagesAtIndexes:)
    @NSManaged public func removeFromPages(at indexes: NSIndexSet)

    @objc(replaceObjectInPagesAtIndex:withObject:)
    @NSManaged public func replacePages(at idx: Int, with value: PageData)

    @objc(replacePagesAtIndexes:withPages:)
    @NSManaged public func replacePages(at indexes: NSIndexSet, with values: [PageData])

    @objc(addPagesObject:)
    @NSManaged public func addToPages(_ value: PageData)

    @objc(removePagesObject:)
    @NSManaged public func removeFromPages(_ value: PageData)

    @objc(addPages:)
    @NSManaged public func addToPages(_ values: NSOrderedSet)

    @objc(removePages:)
    @NSManaged public func removeFromPages(_ values: NSOrderedSet)

}

extension NoteData : Identifiable {

}
