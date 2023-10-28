
import UIKit
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
	
	static var shared: AppDelegate? = nil
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		return true
	}
	
	func save() {
		Database.save()
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		save()
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		save()
	}
	
	var persistenceContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "NewNewNoteTakerApp")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

				/*
				 Typical reasons for an error here include:
				 * The parent directory does not exist, cannot be created, or disallows writing.
				 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
				 * The device is out of space.
				 * The store could not be migrated to the current model version.
				 Check the error message to determine what the actual problem was.
				 */
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	func saveContext() {
		let context = persistenceContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let error = error as NSError
				fatalError("Error ")
			}
		}
	}
}
