//
//  GestureViewRecogniser.swift
//  NewNewNoteTakerApp
//
//  Created by Alexandru Ariton on 24.10.2023.
//

import Foundation
import UIKit
import SwiftUI

struct NoteCanvas: UIViewControllerRepresentable {
	var currentNote: NoteData
	func makeUIViewController(context: Context) -> UIViewController {
		GLOBAL.currentNote = currentNote
		let cvc = CanvasViewController()
		cvc.noteInSelf = self.currentNote
		
		return cvc
	}
	
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
	}
	
}

class RootMainContent: UIView {
	
}

class CanvasViewController: UIViewController, UIScrollViewDelegate {
	private(set) var canvasView: CanvasView!
	private(set) var firstPageView: PageView!
	private(set) var rootMainContent: RootMainContent!
	
	var noteInSelf: NoteData!
	
	var lastPage: PageView! 
	var currentPage: PageView!
	var pagesCount: Int = 0
	
	private var heightConstraint: NSLayoutConstraint?
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	var addNewpageObserver: NSObjectProtocol?
	override func viewDidLoad() {
		super.viewDidLoad()
		self.firstPageView = PageView.init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
		let secondPageView = PageView.init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
		let thirdPageView = PageView.init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
		self.rootMainContent = RootMainContent.init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
		self.canvasView = CanvasView()
		canvasView.delegate = self
		self.canvasView.parent = self
		
		self.view.addSubview(self.canvasView)
		self.canvasView.translatesAutoresizingMaskIntoConstraints = false
		self.canvasView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		self.canvasView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
		self.canvasView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
		self.canvasView.maximumZoomScale = 1000
		self.canvasView.minimumZoomScale = 0.75
		
		// Screen View (background and needed for scrolling)
		self.canvasView.addSubview(self.rootMainContent)
		self.rootMainContent.translatesAutoresizingMaskIntoConstraints = false
		self.rootMainContent.leftAnchor.constraint(equalTo: self.canvasView.leftAnchor).isActive = true
		self.rootMainContent.topAnchor.constraint(equalTo: self.canvasView.topAnchor, constant: 30).isActive = true
		self.rootMainContent.widthAnchor.constraint(greaterThanOrEqualToConstant: GLOBAL.pageDimensions.width).isActive = true
		self.rootMainContent.widthAnchor.constraint(greaterThanOrEqualTo: self.canvasView.widthAnchor).isActive = true
		self.canvasView.rootMainView = self.rootMainContent
		self.lastPage = self.firstPageView
		self.currentPage = self.firstPageView
		self.canvasView.currentPageView = self.firstPageView
		GLOBAL.currentTool = .move
		self.rootMainContent.backgroundColor = .clear
		if (GLOBAL.currentNote?.pages) == [] {
			let id = "\(UUID()) \(GLOBAL.currentNote?.name ?? ":")"
			self.firstPageView.pageData = PageData.newPage(id: id, number: 1, parentNote: GLOBAL.currentNote)
			self.add(page: self.firstPageView, isFirst: true, isLast: true, color: .systemGray6, pageData: self.firstPageView.pageData)
			
		} else {
			self.firstPageView.pageData = GLOBAL.currentNote?.pages.first
			self.add(page: self.firstPageView, isFirst: true, isLast: true, color: .systemGray6, pageData: self.firstPageView.pageData)
			for page in GLOBAL.currentNote?.pages ?? Set([]) {
				if page.id == self.firstPageView.pageData?.id {
					continue
				}
				self.add(pageFromCoreData: page)
			}
		}


		let observer = NotificationCenter.default.addObserver(forName: .addNewPage, object: nil, queue: nil, using: self.addNewPageAtBottom(notification:))
		self.addNewpageObserver = observer
		self.setContentSize()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		GLOBAL.currentNote?.thumbnail = self.firstPageView.imageFromSelf()
		Database.getNotes()
		NotificationCenter.default.removeObserver(self.addNewpageObserver as Any)
	}
	
	func setContentSize() {
		let w = max(self.firstPageView.frame.width, self.rootMainContent.frame.width / self.canvasView.zoomScale) * self.canvasView.zoomScale
		let maxXInset = max(self.canvasView.frame.width - w, 0) * 0.5
		self.canvasView.contentSize = .init(width: w, height: self.firstPageView.frame.height * CGFloat(self.pagesCount) * self.canvasView.zoomScale)
		self.canvasView.contentInset = .init(top: 0, left: maxXInset, bottom: 0, right: 0)
	}
	func addNewPageAtBottom(notification: Notification) {
		if self.noteInSelf == GLOBAL.currentNote {
			let pageView = PageView.init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
			let pageData = PageData.newPage(id: "\(UUID()) \(GLOBAL.currentNote?.name ?? "")", number: self.pagesCount, parentNote: GLOBAL.currentNote)
			pageView.pageData = pageData
			self.add(page: pageView, isLast: true, color: .systemGray6, pageData: pageData)
			self.setContentSize()
		}
	}
	
	
	func add(pageFromCoreData p: PageData) {
		let pageView = PageView.init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
		self.add(page: pageView, isLast: true, color: .systemGray6, pageData: p)
		self.setContentSize()
	}
	
	
	func add(page: PageView, isFirst: Bool = false, isLast: Bool, color: UIColor? = .init(.systemGray6), pageData: PageData? = nil) {
		self.rootMainContent.addSubview(page)
		page.translatesAutoresizingMaskIntoConstraints = false
		page.centerXAnchor.constraint(equalTo: self.rootMainContent.centerXAnchor).isActive = true
		if isFirst {
			page.topAnchor.constraint(equalTo: self.rootMainContent.topAnchor, constant: 0).isActive = true
		} else {
			page.topAnchor.constraint(equalTo: self.lastPage.bottomAnchor, constant: 0).isActive = true
		}
		page.widthAnchor.constraint(equalToConstant: GLOBAL.pageDimensions.width).isActive = true
		page.heightAnchor.constraint(equalToConstant: GLOBAL.pageDimensions.height).isActive = true
		page.backgroundColor = color
		page.clipsToBounds = true
		if isLast {
			self.lastPage = page
		}
		if pageData == nil {
			page.pageData = PageData.newPage(id: "\(UUID()) \(GLOBAL.currentNote?.name ?? ":")", number: self.pagesCount, parentNote: GLOBAL.currentNote)
		} else {
			page.pageData = pageData
		}
		page.addLines()
		self.pagesCount += 1
		self.heightConstraint?.isActive = false
		self.heightConstraint = self.rootMainContent.heightAnchor.constraint(equalTo: self.firstPageView.heightAnchor, multiplier: CGFloat(self.pagesCount))
		self.heightConstraint?.isActive = true
	}
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		self.rootMainContent
	}
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		self.setContentSize()
	}
	
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		self.setContentSize()
	}
	
}
