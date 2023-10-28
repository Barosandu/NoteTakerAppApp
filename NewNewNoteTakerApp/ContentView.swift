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
	@State var path: NavigationPath = .init()
	@Environment(\.isPresented) var isPresented
	var body: some View {
		NavigationStack(path: self.$path) {
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
							Database.getNotes()
							self.allNotes = Database.notes
						}
						.sheet(isPresented: self.$showAddnotePopup) {
							AddNote(allNotes: self.$allNotes)
						}
					}
					ToolbarItem(placement: .topBarLeading) {
						Text("Welcome to NoteTaker")
					}
				}
				.onAppear {
					Database.getNotes()
					self.allNotes = Database.notes
				}
		}
	}
}

extension Date {
	func toString() -> String {
		let df = DateFormatter()
		df.dateFormat = "YY/MM/dd"
		return df.string(from: self)
	}
}

struct Label: View {
	@State var currentNote: NoteData
	var body: some View {
		ZStack {
			
			if currentNote.thumbnail == UIImage.init() {
				Color(.systemGray6)
			} else {
				Image(uiImage: currentNote.thumbnail).resizable()
			}
			VStack {
				Spacer()
				HStack {
					VStack(alignment: .leading, spacing: 0) {
						Text(currentNote.name ?? "No name")
							.bold()
							.padding(0)
						Text(currentNote.dateCreated?.toString() ?? "no date")
							.foregroundStyle(Color(.systemGray))
							.padding(0)
							.font(.system(size: 10))
						
					}
						.padding()
					Spacer()
				}.background(Color(.systemGray5))
					.shadow(radius: 50)
			}
		}
		
			.frame(width: GLOBAL.noteThumbnailDimensions.width, height: GLOBAL.noteThumbnailDimensions.height)
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
				Spacer()
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
							Database.getNotes()
							self.allNotes = Database.notes
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
					Button(.init("Select tool"), systemImage: "lasso") {
						GLOBAL.currentTool = .select
					}
					
					Button(.init("Pencil tool"), systemImage: "pencil.line") {
						GLOBAL.currentTool = .pencil
					}
				}
			}
			.toolbarRole(.editor)
	}
}


#Preview {
    ContentView()//.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
