//
//  NewNewNoteTakerAppApp.swift
//  NewNewNoteTakerApp
//
//  Created by Alexandru Ariton on 24.10.2023.
//

import SwiftUI
import CoreData

@main
struct NewNewNoteTakerAppApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(\.managedObjectContext, appDelegate.persistenceContainer.viewContext)
				.onAppear {
					AppDelegate.shared = appDelegate
				}
        }
    }
}
