//
//  ContentView.swift
//  NewNewNoteTakerApp
//
//  Created by Alexandru Ariton on 24.10.2023.
//

import SwiftUI
import CoreData


struct ContentView: View {
	@State private var currentTool: LineType = .move
	@State private var allNotes = [NoteData]()
	@State private var showAddnotePopup: Bool = false
	var body: some View {
		NavigationStack {
			GeometryReader { geo in
				ScrollView {
					LazyVGrid(columns: [.init(.adaptive(minimum: GLOBAL.noteThumbnailDimensions.width, maximum: GLOBAL.noteThumbnailDimensions.width))]) {
						ForEach(self.allNotes, id: \.id) { note in
							NavigationLink {
								NoteView(currentNote: note)
									.ignoresSafeArea()
							} label: {
								Label(currentNote: note)
							}.buttonStyle(.plain)
						}
					}
				}
			}
				
				.toolbar {
					ToolbarItemGroup(placement: .automatic) {
						Button(.init("Add note"), systemImage: "square.and.pencil") {
							self.showAddnotePopup = true
						}
						.onAppear {
							self.allNotes = Database.getNotes()
						}
						.sheet(isPresented: self.$showAddnotePopup) {
							AddNote(allNotes: self.$allNotes)
						}
					}
					ToolbarItem(placement: .topBarLeading) {
						Text("Welcome to NoteTaker")
					}
				}
		}
	}
}

struct Label: View {
	@State var currentNote: NoteData
	var body: some View {
		Text(currentNote.name ?? "")
			.frame(width: GLOBAL.noteThumbnailDimensions.width, height: GLOBAL.noteThumbnailDimensions.height)
			.background(.thinMaterial)
			.clipShape(RoundedRectangle(cornerRadius: 10))
		
	}
}

struct AddNote: View {
	@State private var noteName = ""
	@Binding var allNotes: [NoteData]
	@Environment(\.dismiss) var dismiss
	var body: some View {
		NavigationStack {
			VStack {
				TextField("Add new note", text: $noteName)
					.textFieldStyle(.roundedBorder)
					.padding()
			}
			
				.toolbar {
					ToolbarItem(placement: .topBarLeading) {
						Button("Cancel") {
							self.dismiss()
						}
					}
					
					ToolbarItem(placement: .primaryAction) {
						Button("Add") {
							let note = NoteData.newNote(name: self.noteName)
							let _ = note
							Database.save()
							self.allNotes = Database.getNotes()
						}
					}
				}
		}
	}
}

struct NoteView: View {
	var currentNote: NoteData
	var body: some View {
		NoteCanvas(currentNote: currentNote)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Text(self.currentNote.name ?? "")
				}
				ToolbarItemGroup(placement: .secondaryAction) {
					Button(.init("Add page"), systemImage: "plus") {
						NotificationCenter.default.post(name: .addNewPage, object: nil)
					}
					Button(.init("Select tool"), systemImage: "lasso.and.sparkles") {
						GLOBAL.currentTool = .select
					}
				}
			}
			.toolbarRole(.editor)
	}
}


#Preview {
    ContentView()//.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
