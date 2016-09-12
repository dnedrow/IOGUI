//
//  TextWidget.swift
//  IOGUI
//
//  Created by ilker özcan on 13/09/16.
//  Copyright © 2016 ilkerozcan. All rights reserved.
//

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif
import Foundation

public struct TextWidget {
	
	static let WidgetHeight = 1
	
	private var startRow: Int
	private var text: String
	private var color: WidgetUIColor
	
	#if swift(>=3)
	#if os(Linux)
	private var mainWindow: UnsafeMutablePointer<WINDOW>
	
	private var textWindow: UnsafeMutablePointer<WINDOW>!
	#else
	private var mainWindow: OpaquePointer
	
	private var textWindow: OpaquePointer!
	#endif
	#elseif swift(>=2.2) && os(OSX)
	
	private var mainWindow: COpaquePointer
	
	private var textWindow: COpaquePointer!
	#endif
	
	
	public var widgetRows: Int {
		
		get {
			return TextWidget.WidgetHeight
		}
	}
	
	#if swift(>=3)
	#if os(Linux)
	public init(startRow: Int, text: String, mainWindow: UnsafeMutablePointer<WINDOW>, color: WidgetUIColor) {
	
		self.startRow = startRow
		self.text = text
		self.mainWindow = mainWindow
		self.color = color
		self.initWindows()
	}
	#else
	public init(startRow: Int, text: String, mainWindow: OpaquePointer, color: WidgetUIColor) {
		
		self.startRow = startRow
		self.text = text
		self.mainWindow = mainWindow
		self.color = color
		self.initWindows()
	}
	#endif
	#elseif swift(>=2.2) && os(OSX)
	
	public init(startRow: Int, text: String, mainWindow: COpaquePointer, color: WidgetUIColor) {
	
		self.startRow = startRow
		self.text = text
		self.mainWindow = mainWindow
		self.color = color
		self.initWindows()
	}
	#endif
	
	mutating func initWindows() {
		
		wmove(mainWindow, 0, 0)
		self.textWindow = subwin(mainWindow, 1, COLS, Int32(self.startRow), 0)
		#if os(Linux)
			wbkgd(textWindow, UInt(COLOR_PAIR(self.color.rawValue)))
		#else
			wbkgd(textWindow, UInt32(COLOR_PAIR(self.color.rawValue)))
		#endif
		keypad(textWindow, true)
	}
	
	func draw() {
		
		drawText()
	}
	
	mutating func resize() {
		
		deinitWidget()
		initWindows()
		draw()
	}
	
	private func drawText() {
		
		if(self.textWindow == nil) {
			return
		}
		
		let textString = "   \(self.text)"
		AddStringToWindow(normalString: textString, window: textWindow)
		wrefresh(textWindow)
	}
	
	public mutating func updateText(textString: String) {
		
		self.text = textString
		wclear(textWindow)
		drawText()
	}
	
	mutating func deinitWidget() {
		
		if(self.textWindow != nil) {
			
			wclear(textWindow)
			delwin(textWindow)
			self.textWindow = nil
		}
		
		wrefresh(mainWindow)
	}
}
