//
//  FormWidget.swift
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

public struct GUI_FORM_FIELD {
	
	public enum GUI_FORM_TYPES {
		case STRING
		case INT
		case REAL
		case DATE_TIME
	}
	
	var formName: String
	var formValue: String
	var maxLength: Int
	var formType = GUI_FORM_TYPES.STRING
	
	
	public var getValue: String {
		
		get {
			return self.formValue
		}
	}
	
	public init(formName: String, formDefaultValue: String?, formType: GUI_FORM_TYPES?, maxLength: Int?) {
		
		self.formName = formName
		
		if(formDefaultValue != nil) {
			self.formValue = formDefaultValue!
		}else{
			self.formValue = ""
		}
		
		if(formType != nil) {
			self.formType = formType!
		}
		
		if(maxLength != nil) {
			self.maxLength = maxLength!
		}else{
			self.maxLength = -1
		}
	}
}

public struct FormWidget {
	
	var widgetRows: Int
	
	private var startRow: Int
	#if swift(>=3)
	
	#if os(Linux)
	private var mainWindow: UnsafeMutablePointer<WINDOW>
	#else
	private var mainWindow: OpaquePointer
	#endif
	#elseif swift(>=2.2) && os(OSX)
	
	private var mainWindow: COpaquePointer
	#endif
	private var formFields: [GUI_FORM_FIELD]
	private var formAreaWidth: Int32
	#if swift(>=3)
	#if os(Linux)
	private var formWindow: UnsafeMutablePointer<WINDOW>!
	#else
	private var formWindow: OpaquePointer!
	#endif
	#elseif swift(>=2.2) && os(OSX)
	
	private var formWindow: COpaquePointer!
	#endif
	private var currentFormIdx = 0
	private var firstFormIdx = 0
	private var formLineCount = 0
	private var formKeyWidth = 0
	
	public var getCurrentFormField: GUI_FORM_FIELD {
		
		get {
			return self.formFields[currentFormIdx]
		}
	}
	
	#if swift(>=3)
	
	#if os(Linux)
	public init(startRow: Int, widgetSize: Int, fields: [GUI_FORM_FIELD], mainWindow: UnsafeMutablePointer<WINDOW>) {
	
		self.startRow = startRow
		self.widgetRows = widgetSize
		self.formFields = fields
		self.mainWindow = mainWindow
		self.formAreaWidth = 2
	
		for field in fields {
	
			let fieldWidth = field.formName.characters.count + 2
	
			if(formKeyWidth < fieldWidth) {
				formKeyWidth = fieldWidth
			}
		}
	
		initWindows()
	}
	#else
	public init(startRow: Int, widgetSize: Int, fields: [GUI_FORM_FIELD], mainWindow: OpaquePointer) {
		
		self.startRow = startRow
		self.widgetRows = widgetSize
		self.formFields = fields
		self.mainWindow = mainWindow
		self.formAreaWidth = 2
		
		for field in fields {
			
			let fieldWidth = field.formName.characters.count + 2
			
			if(formKeyWidth < fieldWidth) {
				formKeyWidth = fieldWidth
			}
		}
		
		initWindows()
	}
	#endif
	#elseif swift(>=2.2) && os(OSX)
	
	public init(startRow: Int, widgetSize: Int, fields: [GUI_FORM_FIELD], mainWindow: COpaquePointer) {
	
		self.startRow = startRow
		self.widgetRows = widgetSize
		self.formFields = fields
		self.mainWindow = mainWindow
		self.formAreaWidth = 2
	
		for field in fields {
	
			let fieldWidth = field.formName.characters.count + 2
	
			if(formKeyWidth < fieldWidth) {
				formKeyWidth = fieldWidth
			}
		}
	
		initWindows()
	}
	#endif
	
	mutating func initWindows() {
		
		wmove(mainWindow, 0, 0)
		self.formWindow = subwin(self.mainWindow, LINES - Int32(self.widgetRows), COLS - formAreaWidth, Int32(startRow), 1)
		#if os(Linux)
			wbkgd(self.formWindow,UInt(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
		#else
			wbkgd(self.formWindow,UInt32(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
		#endif
		keypad(self.formWindow, true)
	}
	
	mutating func draw() {
		
		if(self.formWindow == nil) {
			return
		}
		
		drawFormArea()
	}
	
	mutating func resize() {
		
		deinitWidget()
		initWindows()
		draw()
	}
	
	mutating func deinitWidget() {
		
		if(self.formWindow != nil) {
			
			wclear(formWindow)
			delwin(formWindow)
			self.formWindow = nil
		}
		
		wrefresh(mainWindow)
	}
	
	private mutating func drawFormArea() {
		
		var currentLine: Int32 = 1
		var lineLeft = LINES - widgetRows - 1
		formLineCount = -2
		
		for idx in 0..<formFields.count {
			
			if(idx < firstFormIdx) {
				continue
			}
			
			if(lineLeft <= 0) {
				break
			}
			
			wmove(formWindow, currentLine, 2)
			wattrset(formWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
			AddStringToWindow(paddingString: formFields[idx].formName, textWidth: (self.formKeyWidth - 2), textStartSpace: 0, window: self.formWindow)
			AddStringToWindow(normalString: " :", window: self.formWindow)
			
			let valueWidth = COLS - formAreaWidth - self.formKeyWidth - 2
			
			let formWal: String
			if(formFields[idx].formType == .INT) {
				
				formWal = (formFields[idx].formValue == "") ? "0" : formFields[idx].formValue
			}else if(formFields[idx].formType == .REAL) {
				formWal = (formFields[idx].formValue == "") ? "0.0" : formFields[idx].formValue
			}else if(formFields[idx].formType == .DATE_TIME) {
				formWal = (formFields[idx].formValue == "") ? "GG/AA/YYYY" : formFields[idx].formValue
			}else{
				formWal = formFields[idx].formValue
			}
			
			if(currentFormIdx == idx) {
				wattrset(formWindow, COLOR_PAIR(WidgetUIColor.FooterBackground.rawValue))
				AddStringToWindow(paddingString: formWal, textWidth: valueWidth, textStartSpace: 0, window: self.formWindow)
			}else{
				wattrset(formWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
				//mvwhline(self.formWindow, currentLine, (self.formKeyWidth + 2), 113, Int32(valueWidth - 4))
				mvwhline(self.formWindow, currentLine, (self.formKeyWidth + 2), Character("q").value, Int32(valueWidth - 4))
				//AddStringToWindow(normalString: formWal, window: self.formWindow)
			}
			
			AddStringToWindow(normalString: "\n", window: formWindow)
			currentLine += 1
			
			lineLeft -= 1
			formLineCount += 1
		}
		
		wattrset(formWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
		AddStringToWindow(normalString: "\t", window: formWindow)
		wborder(formWindow, 0, 0, 0, 0, 0, 0, 0, 0)
		touchwin(formWindow)
		wrefresh(formWindow)
	}
	
	mutating func updateSelectedChoice(isUp: Bool = false) {
		
		if(isUp) {
			
			if(currentFormIdx > 0) {
				
				currentFormIdx -= 1
				if(currentFormIdx < firstFormIdx) {
					firstFormIdx -= 1
				}
				
				wclear(formWindow)
				drawFormArea()
			}
			
		}else{
			
			if(currentFormIdx < formLineCount) {
				
				currentFormIdx += 1
				wclear(formWindow)
				drawFormArea()
			}else if(currentFormIdx >= firstFormIdx && currentFormIdx < (formFields.count - 1)) {
				
				firstFormIdx += 1
				currentFormIdx += 1
				wclear(formWindow)
				drawFormArea()
			}
		}
	}
	
	func formSelected() {
		
	}
	
	mutating func keyEvent(keyCode: Int32) {
		
		
		switch keyCode {
		case KEY_ENTER, 13:
			self.formSelected()
			break
		case KEY_UP:
			#if swift(>=3)
				
				self.updateSelectedChoice(isUp: true)
			#elseif swift(>=2.2) && os(OSX)
				
				self.updateSelectedChoice(true)
			#endif
			break
		case KEY_DOWN:
			self.updateSelectedChoice()
			break
		default:
			break
		}
	}
}
