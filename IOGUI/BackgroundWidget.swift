//
//  BackgroundWidget.swift
//  IORunner/IOGUI
//
//  Created by ilker özcan on 18/07/16.
//
//

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif
import Foundation

public struct BackgroundWidget {
	
	private var bgColor: WidgetUIColor!
	
#if swift(>=3)
#if os(Linux)
	private var mainWindow: UnsafeMutablePointer<WINDOW>
	
	private var mainBgWindow: UnsafeMutablePointer<WINDOW>!
	
	public init(mainWindow: UnsafeMutablePointer<WINDOW>, bgColor: WidgetUIColor) {
	
		self.mainWindow = mainWindow
		self.bgColor = bgColor
		initWindows()
	}
#else
	private var mainWindow: OpaquePointer
	
	private var mainBgWindow: OpaquePointer!
	
	public init(mainWindow: OpaquePointer, bgColor: WidgetUIColor) {
	
		self.mainWindow = mainWindow
		self.bgColor = bgColor
		initWindows()
	}
#endif
#elseif swift(>=2.2) && os(OSX)
	
	private var mainWindow: COpaquePointer
	
	private var mainBgWindow: COpaquePointer!
	
	public init(mainWindow: COpaquePointer, bgColor: WidgetUIColor) {
	
		self.mainWindow = mainWindow
		self.bgColor = bgColor
		initWindows()
	}
#endif
	
	mutating func initWindows() {
		
		wmove(mainWindow, 0, 0)
		self.mainBgWindow = subwin(mainWindow, LINES, COLS, 0, 0)
		
	#if os(Linux)
		wbkgd(self.mainBgWindow, UInt(COLOR_PAIR(self.bgColor.rawValue)))
	#else
		wbkgd(self.mainBgWindow, UInt32(COLOR_PAIR(self.bgColor.rawValue)))
	#endif
		keypad(self.mainBgWindow, true)
	}
	
	mutating func draw() {
		
		if(self.mainBgWindow == nil) {
			
			return
		}
		
		wmove(self.mainBgWindow, 0, 0)
		wborder(self.mainBgWindow, 0, 0, 0, 0, 0, 0, 0, 0)
		touchwin(self.mainBgWindow)
		wrefresh(self.mainBgWindow)
	}
	
	mutating func resize() {
		
		deinitWidget()
		initWindows()
		draw()
	}
	
	mutating func deinitWidget() {
		
		if(self.mainBgWindow != nil) {
			
			wclear(mainBgWindow)
			delwin(mainBgWindow)
			self.mainBgWindow = nil
		}
		
		wrefresh(mainWindow)
	}
}
