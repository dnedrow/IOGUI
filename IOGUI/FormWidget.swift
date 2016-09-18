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
			
			if(formType != nil) {
				
				if(formType! == .INT) {
					
					self.formValue = "0"
				}else if(formType! == .REAL) {
					
					self.formValue = "0.0"
				}else if(formType! == .DATE_TIME) {
					self.formValue = "MM/DD/YYYY"
				}else{
					self.formValue = ""
				}
			}else{
				self.formValue = ""
			}
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
	
	public mutating func appendChar(appendStr: String, isNum: Bool) {
		
		switch self.formType {
		case .INT:
			
			if(isNum) {
				
				if(self.formValue.characters.count == 0 || self.formValue == "0") {
				
					if(appendStr != "0") {
					
						self.formValue = appendStr
					}
				}else{
				
					self.formValue += appendStr
				}
			}
			break
		case .REAL:
			
			if(isNum){
				self.formValue += appendStr
			}
			
			break
		case .DATE_TIME:
			// PASS
			break
		default:
			self.formValue += appendStr
			break
		}
	}
	
	public mutating func replaceChar(replaceStr: String, index: Int, isNum: Bool) {
		
		var replaceStatus = false
		var realIdx = index
		
		switch self.formType {
		case .INT:
			
			if(isNum) {
				
				if(replaceStr == "0" && index == 1) {
					replaceStatus = false
				}else{
					replaceStatus = true
				}
			}else{
				replaceStatus = false
			}
			
			break
		case .REAL:
			
			let splittedRealVal = self.formValue.components(separatedBy: ".")
			if(splittedRealVal.count > 0) {
				
				var intvalStr = splittedRealVal[0]
				let decimalvalStr = splittedRealVal[1]
				let intvalLen = intvalStr.characters.count
				
				if(intvalLen + 1 == index) {
					
					realIdx = index - 1
					replaceStatus = false
					if(intvalLen == 1) {
						
						if(intvalStr == "0") {
							
							if(replaceStr == "0") {
								replaceStatus = false
							}else if(isNum){
								replaceStatus = true
							}
						}else if(isNum) {
							replaceStatus = false
							intvalStr += replaceStr
						}
					}else if(isNum) {
						replaceStatus = false
						intvalStr += replaceStr
					}

					if(!replaceStatus) {
						self.formValue = "\(intvalStr).\(decimalvalStr)"
					}
					
				}else{
					
					if(isNum) {
						
						if(replaceStr == "0" && index == 1) {
							replaceStatus = false
						}else{
							replaceStatus = true
						}
					}else{
						replaceStatus = false
					}
				}
				
			}else{
				replaceStatus = false
			}
			break
		case .DATE_TIME:
			replaceStatus = false
			
			if(realIdx == 1 || realIdx == 2 || realIdx == 4 || realIdx == 5 || realIdx > 6) {
				
				if(isNum) {
					replaceStatus = true
				}
			}
			
			break
		default:
			replaceStatus = true
			break
		}
		
		if(replaceStatus) {
			let characterCount = self.formValue.characters.count
			let startIdx = self.formValue.startIndex
			let strStartIdx = self.formValue.index(startIdx, offsetBy: 0)
			let strEndIdx = self.formValue.index(startIdx, offsetBy: realIdx - 1)
			let strBeginRange = Range<String.Index>(strStartIdx..<strEndIdx)
			let strBegin = self.formValue.substring(with: strBeginRange)
		
			let strEnd: String
			if(realIdx >= characterCount) {
				strEnd = ""
			}else{
				let strEndStartIdx = self.formValue.index(startIdx, offsetBy: realIdx)
				let strEndEndIdx = self.formValue.index(startIdx, offsetBy: characterCount)
				let strEndRange = Range<String.Index>(strEndStartIdx..<strEndEndIdx)
				strEnd = self.formValue.substring(with: strEndRange)
			}
		
			self.formValue = "\(strBegin)\(replaceStr)\(strEnd)"
		}
	}
	
	public mutating func replaceValue(replaceStr: String) {
		
		self.formValue = replaceStr
	}
	
	public mutating func removeLastChar() {
		
		if(self.formType == .DATE_TIME) {
			return
		}
		
		if(self.formValue.characters.count > 0) {
			
			let startIdx = self.formValue.startIndex
			let endIdx = self.formValue.endIndex
			let startRange = self.formValue.index(startIdx, offsetBy: 0)
			let endRange = self.formValue.index(endIdx, offsetBy: -1)
			let range = Range<String.Index>(startRange..<endRange)
			self.formValue = self.formValue.substring(with: range)
		}
		
		if(self.formType == .INT) {
			
			if(self.formValue.characters.count == 0) {
				
				self.formValue = "0"
			}
		}else if(self.formType == .REAL) {
		
			let splittedRealVal = self.formValue.components(separatedBy: ".")
			var intval = "0"
			var decimalval = "0"
			
			if(splittedRealVal.count > 0){
				
				if(splittedRealVal[0].characters.count > 0) {
					
					intval = splittedRealVal[0]
				}
			}
			
			if(splittedRealVal.count > 1){
			
				if(splittedRealVal[1].characters.count > 0) {
					
					decimalval = splittedRealVal[1]
				}
			}
			
			self.formValue = "\(intval).\(decimalval)"
		}
	}
	
	public mutating func removeCharAt(index: Int) {
		
		var removeStatus = false
		
		switch self.formType {
		case .INT:
			
			if(index == 1) {
				
				if(self.formValue.characters.count > 1) {
					
					let seconCharacterStartIdx = self.formValue.index(self.formValue.startIndex, offsetBy: 1)
					let seconCharacterEndIdx = self.formValue.index(self.formValue.startIndex, offsetBy: 2)
					let secondCharacterRange = Range<String.Index>(seconCharacterStartIdx..<seconCharacterEndIdx)
					let secondCharacter = self.formValue.substring(with: secondCharacterRange)
					if(secondCharacter == "0") {
						removeStatus = false
					}else{
						removeStatus = true
					}
				}else{
					
					self.formValue = "0"
					removeStatus = false
				}
				
			}else{
				removeStatus  = true
			}
			break
		case .REAL:
			
			let splittedRealVal = self.formValue.components(separatedBy: ".")
			var intval = "0"
			var decimalval = "0"
			
			if(splittedRealVal.count > 0){
				
				if(splittedRealVal[0].characters.count > 0) {
					
					intval = splittedRealVal[0]
				}
			}
			
			if(splittedRealVal.count > 1){
				
				if(splittedRealVal[1].characters.count > 0) {
					
					decimalval = splittedRealVal[1]
				}
			}
			
			if(index == 1) {
				
				if(intval.characters.count > 1) {
					
					let seconCharacterStartIdx = intval.index(intval.startIndex, offsetBy: 1)
					let seconCharacterEndIdx = intval.index(intval.startIndex, offsetBy: 2)
					let secondCharacterRange = Range<String.Index>(seconCharacterStartIdx..<seconCharacterEndIdx)
					let secondCharacter = intval.substring(with: secondCharacterRange)
					
					if(secondCharacter == "0") {
						removeStatus = false
					}else{
						removeStatus = true
					}
				}else{
					
					intval = "0"
					removeStatus = false
				}
			
			}else if(index == (intval.characters.count + 1)) {
			
				removeStatus = false
			}else{
				removeStatus  = true
			}
			
			self.formValue = "\(intval).\(decimalval)"
			
			break
		case .DATE_TIME:
			// PASS
			break
		default:
			removeStatus = true
			break
		}
		
		if(removeStatus) {
			
			let characterCount = self.formValue.characters.count
			let startIdx = self.formValue.startIndex
			let strStartIdx = self.formValue.index(startIdx, offsetBy: 0)
			let strEndIdx = self.formValue.index(startIdx, offsetBy: index - 1)
			let strBeginRange = Range<String.Index>(strStartIdx..<strEndIdx)
			let strBegin = self.formValue.substring(with: strBeginRange)
		
			let strEnd: String
			if(index >= characterCount) {
				strEnd = ""
			}else{
				let strEndStartIdx = self.formValue.index(startIdx, offsetBy: index)
				let strEndEndIdx = self.formValue.index(startIdx, offsetBy: characterCount)
				let strEndRange = Range<String.Index>(strEndStartIdx..<strEndEndIdx)
				strEnd = self.formValue.substring(with: strEndRange)
			}
		
			self.formValue = "\(strBegin)\(strEnd)"
		}
	}
}

public struct FormWidget {
	
	var widgetRows: Int
	
	private var startRow: Int
	
	#if os(Linux)
	private var mainWindow: UnsafeMutablePointer<WINDOW>
	#else
	private var mainWindow: OpaquePointer
	#endif

	private var formFields: [GUI_FORM_FIELD]
	private var formAreaWidth: Int32
	#if os(Linux)
	private var formWindow: UnsafeMutablePointer<WINDOW>!
	#else
	private var formWindow: OpaquePointer!
	#endif

	private var currentFormIdx = 0
	private var firstFormIdx = 0
	private var formLineCount = 0
	private var formKeyWidth = 0
	private var currentCursorPos = -1
	
	public var getCurrentFormField: GUI_FORM_FIELD {
		
		get {
			return self.formFields[currentFormIdx]
		}
	}
	
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
			
			if(currentFormIdx == idx) {
				wattrset(formWindow, COLOR_PAIR(WidgetUIColor.FooterBackground.rawValue))
				
				if(self.currentCursorPos == -1 && formFields[idx].formType == .REAL) {
					
					let splittedRealVal = formFields[idx].formValue.components(separatedBy: ".")
					var firstBlockLen = 0
					if(splittedRealVal.count > 0) {
						firstBlockLen = splittedRealVal[0].characters.count
					}
					
					self.currentCursorPos = firstBlockLen + 1
				}else if(self.currentCursorPos == -1 && formFields[idx].formType == .DATE_TIME) {
					self.currentCursorPos = 1
				}
				
				let splittedStr = self.splitString(text: formFields[idx].formValue, textWidth: valueWidth)
				AddStringToWindow(normalString: splittedStr.0, window: formWindow)
				wattrset(formWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
				AddStringToWindow(normalString: splittedStr.1, window: formWindow)
				wattrset(formWindow, COLOR_PAIR(WidgetUIColor.FooterBackground.rawValue))
				AddStringToWindow(normalString: splittedStr.2, window: formWindow)
			}else{
				wattrset(formWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
				
				if(formFields[idx].formValue.characters.count > valueWidth - 1) {
				
					let endIdx = formFields[idx].formValue.endIndex
					let range1StartIdx = formFields[idx].formValue.index(endIdx, offsetBy: (-1 * (valueWidth - 4)))
					let range1EndtIdx = formFields[idx].formValue.index(endIdx, offsetBy: 0)
					let range1 = Range<String.Index>(range1StartIdx..<range1EndtIdx)
					let text1RangeStr = formFields[idx].formValue.substring(with: range1)
					let text1 = "<\(text1RangeStr)"
					AddStringToWindow(normalString: text1, window: self.formWindow)
					
				}else{
					AddStringToWindow(normalString: formFields[idx].formValue, window: self.formWindow)
				}
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
				self.currentCursorPos = -1
				drawFormArea()
			}
			
		}else{
			
			if(currentFormIdx < formLineCount) {
				
				currentFormIdx += 1
				wclear(formWindow)
				self.currentCursorPos = -1
				drawFormArea()
				
			}else if(currentFormIdx >= firstFormIdx && currentFormIdx < (formFields.count - 1)) {
				
				firstFormIdx += 1
				currentFormIdx += 1
				wclear(formWindow)
				self.currentCursorPos = -1
				drawFormArea()
			}
		}
	}
	
	private mutating func formSelected() {
		
		let currentFormField = self.formFields[self.currentFormIdx]
		var goToNextField = false
		
		if(currentFormField.formType == .INT || currentFormField.formType == .STRING) {
			
			goToNextField = true
			
		}else if(currentFormField.formType == .REAL) {
			
			let splittedRealValue = currentFormField.formValue.components(separatedBy: ".")
			let intval: String
			
			if(splittedRealValue.count > 0) {
				
				intval = splittedRealValue[0]
			}else{
				intval = "0"
			}
			
			if(self.currentCursorPos > (intval.characters.count + 1)) {
				
				goToNextField = true
			}else{
				
				goToNextField = false
				self.currentCursorPos = currentFormField.formValue.characters.count
			}
		}else if(currentFormField.formType == .DATE_TIME) {
			
			if(self.currentCursorPos <= 3) {
				
				goToNextField = false
				self.currentCursorPos = 4
				
			}else if(self.currentCursorPos <= 6) {
				
				goToNextField = false
				self.currentCursorPos = 7
				
			}else if(self.currentCursorPos >= 7) {
				
				goToNextField = true
			}
		}
		
		if(goToNextField) {
			
			if(currentFormIdx + 1 > self.formFields.count) {
				
				self.currentFormIdx = 0
				self.currentCursorPos = -1
			}else{
				
				self.updateSelectedChoice()
			}
		}
		
		wclear(self.formWindow)
		drawFormArea()
	}
	
	private mutating func appendValueToCurrentField(keycode: Int32) {
		
		var isDelete = false
		var isNum = false
		
		if(keycode == 127) {
			
			isDelete = true
		}else if(keycode >= 48 && keycode <= 57) {
			
			isNum = true
		}
		
		var currentField = self.formFields[self.currentFormIdx]
		var updateData = false
		
		if(currentField.formType == .REAL) {
			
			if(keycode == 46) {
				
				updateData = false
				let splittedRealVal = currentField.formValue.components(separatedBy: ".")
				var intval = "0"
				var doubleVal = "0"
				
				if(splittedRealVal.count > 0 && splittedRealVal[0].characters.count > 0) {
				
					intval = splittedRealVal[0]
				}
				
				if(splittedRealVal.count > 1 && splittedRealVal[1].characters.count > 0) {
					
					doubleVal = splittedRealVal[1]
				}
				
				if(self.currentCursorPos < intval.characters.count && self.currentCursorPos > 1) {
					
					let intvalStartIndex = currentField.formValue.index(currentField.formValue.startIndex, offsetBy: 0)
					let intvalEndIndex = currentField.formValue.index(currentField.formValue.startIndex, offsetBy: self.currentCursorPos - 1)
					let intvalRange = Range<String.Index>(intvalStartIndex..<intvalEndIndex)
					intval = currentField.formValue.substring(with: intvalRange)
					currentField.formValue = "\(intval).\(doubleVal)"
				}
				
				
				
			}else{
				updateData = true
			}
			
		}else{
			updateData = true
		}
		
		if(isDelete && updateData) {
				
			self.currentCursorPos -= 1
				
			if(self.currentCursorPos < 1) {
				self.currentCursorPos = 1
			}
				
			if(self.currentCursorPos > currentField.formValue.characters.count) {
					
				currentField.removeLastChar()
			}else{
					
				currentField.removeCharAt(index: self.currentCursorPos)
			}
		}else if(updateData) {
				
			var addOrReplace = false
			if((currentField.maxLength > 0) && (self.currentCursorPos < currentField.maxLength)) {
					
				addOrReplace = true
					
			}else if(currentField.maxLength == -1){
				addOrReplace = true
			}
				
			if(addOrReplace) {
				
				let oldvalueLen = currentField.formValue.characters.count
				let currentChar = Character(UnicodeScalar(Int(keycode))!)
				if(self.currentCursorPos > oldvalueLen) {
				
					self.currentCursorPos += 1
					currentField.appendChar(appendStr: "\(currentChar)", isNum: isNum)
				}else{
					
					currentField.replaceChar(replaceStr: "\(currentChar)", index: self.currentCursorPos, isNum: isNum)
					
					if(currentField.formType == .REAL) {
						
						let newValueLen = currentField.formValue.characters.count
						if(newValueLen > oldvalueLen) {
							self.currentCursorPos += 1
						}
					}
				}
			}
		}
		
		self.formFields[self.currentFormIdx] = currentField
		
		if(currentField.formType == .DATE_TIME) {
			
			self.currentCursorPos += 1
			if(self.currentCursorPos == 3) {
				
				self.currentCursorPos = 4
			}
			
			if(self.currentCursorPos == 6) {
				
				self.currentCursorPos = 7
			}
			
			if(!checkDateTimeValue()) {
				
				wclear(self.formWindow)
				drawFormArea()
			}
		}else{
			
			wclear(self.formWindow)
			drawFormArea()
		}
	}
	
	mutating func keyEvent(keyCode: Int32) {
		
		switch keyCode {
		case KEY_ENTER, 13:
			self.formSelected()
			break
		case KEY_UP:
			self.updateSelectedChoice(isUp: true)
			break
		case KEY_DOWN:
			self.updateSelectedChoice()
			break
		case KEY_LEFT:
			
			self.currentCursorPos -= 1
			if(self.currentCursorPos < 1) {
				
				self.currentCursorPos = 1
			}else{
				
				wclear(self.formWindow)
				drawFormArea()
			}
			
			break
		case KEY_RIGHT:
			
			self.currentCursorPos += 1
			let selectedFormField = self.formFields[self.currentFormIdx]
			let expectMaxLeft = selectedFormField.formValue.characters.count
			if(self.currentCursorPos > (expectMaxLeft + 1)) {
				
				self.currentCursorPos = expectMaxLeft + 1
			}else{
			
				wclear(self.formWindow)
				drawFormArea()
			}
			break
		default:
			self.appendValueToCurrentField(keycode: keyCode)
			break
		}
	}
	
	private mutating func splitString(text: String, textWidth: Int) -> (String, String, String) {
		
		let charCount = text.characters.count
		
		if(self.currentCursorPos == -1) {
			self.currentCursorPos = charCount + 1
		}
		
		if(self.currentCursorPos > (charCount + 1)) {
			self.currentCursorPos = charCount + 1
		}
		
		if(charCount >= (textWidth - 1)) {
			
			if(self.currentCursorPos > charCount) {
				
				let endIdx = text.endIndex
				
				let range1StartIdx = text.index(endIdx, offsetBy: (-1 * (textWidth - 4)))
				let range1EndtIdx = text.index(endIdx, offsetBy: 0)
				let range1 = Range<String.Index>(range1StartIdx..<range1EndtIdx)
				let text1RangeStr = text.substring(with: range1)
				let text1 = "<\(text1RangeStr)"
				
				let text2 = " "
				let text3 = " "
				
				return (text1, text2, text3)
			}else{
				
				if(self.currentCursorPos > (textWidth - 1)) {
					
					let rangeStart = self.currentCursorPos - charCount
					let endIdx = text.endIndex
					
					let text3: String
					if(rangeStart == 0) {
						
						text3 = " "
					}else{
						
						let range3StartIdx = text.index(endIdx, offsetBy: rangeStart)
						let range3EndtIdx = text.index(endIdx, offsetBy: rangeStart + 1)
						let range3 = Range<String.Index>(range3StartIdx..<range3EndtIdx)
						text3 = text.substring(with: range3)
					}
					
					let range2StartIdx = text.index(endIdx, offsetBy: rangeStart - 1)
					let range2EndtIdx = text.index(endIdx, offsetBy: rangeStart)
					let range2 = Range<String.Index>(range2StartIdx..<range2EndtIdx)
					let text2 = text.substring(with: range2)
					
					let charLeft = rangeStart - textWidth + 3
					let range1StartIdx = text.index(endIdx, offsetBy: charLeft)
					let range1EndtIdx = text.index(endIdx, offsetBy: rangeStart - 1)
					let range1 = Range<String.Index>(range1StartIdx..<range1EndtIdx)
					let text1SubStr = text.substring(with: range1)
					let text1 = "<\(text1SubStr)"
					
					return (text1, text2, text3)
					
				}else{
					
					let startIdx = text.startIndex
					
					let range1StartIdx = text.index(startIdx, offsetBy: 0)
					let range1EndtIdx = text.index(startIdx, offsetBy: self.currentCursorPos - 1)
					let range1 = Range<String.Index>(range1StartIdx..<range1EndtIdx)
					let text1 = text.substring(with: range1)
					
					let range2StartIdx = text.index(startIdx, offsetBy: self.currentCursorPos - 1)
					let range2EndtIdx = text.index(startIdx, offsetBy: self.currentCursorPos)
					let range2 = Range<String.Index>(range2StartIdx..<range2EndtIdx)
					let text2 = text.substring(with: range2)
					
					let displayEnd = textWidth - self.currentCursorPos
					let range3StartIdx = text.index(startIdx, offsetBy: self.currentCursorPos)
					let range3EndtIdx = text.index(startIdx, offsetBy: self.currentCursorPos + displayEnd)
					let range3 = Range<String.Index>(range3StartIdx..<range3EndtIdx)
					let text3 = text.substring(with: range3)
					
					return (text1, text2, text3)
				}
			}
		}else{
			
			if(self.currentCursorPos > charCount) {
				
				let repeatSize = textWidth - 2 - charCount
				let retvalSpace: String
				
				if(repeatSize > 0) {
					retvalSpace = String.init(repeating: " ", count: repeatSize)
				}else{
					retvalSpace = ""
				}
				
				return (text, " ", retvalSpace)
			}else{
				
				let startIdx = text.startIndex
				let cursorPos = self.currentCursorPos - 1
				
				let range1StartIdx = text.index(startIdx, offsetBy: 0)
				let range1EndtIdx = text.index(startIdx, offsetBy: cursorPos)
				let range1 = Range<String.Index>(range1StartIdx..<range1EndtIdx)
				let text1 = text.substring(with: range1)
				
				let rabge2StartIdx = text.index(startIdx, offsetBy: cursorPos)
				let range2EndtIdx = text.index(startIdx, offsetBy: cursorPos + 1)
				let range2 = Range<String.Index>(rabge2StartIdx..<range2EndtIdx)
				let text2 = text.substring(with: range2)
				
				let rabge3StartIdx = text.index(startIdx, offsetBy: (cursorPos + 1))
				let range3EndtIdx = text.index(text.endIndex, offsetBy: 0)
				let range3 = Range<String.Index>(rabge3StartIdx..<range3EndtIdx)
				var text3 = text.substring(with: range3)
				
				let repeatSize = textWidth - (1 + text1.characters.count + text3.characters.count)
				let retvalSpace = String.init(repeating: " ", count: repeatSize)
				text3 += retvalSpace
				return (text1, text2, text3)
			}
		}
	}
	
	private mutating func checkDateTimeValue() -> Bool {
		
		var currentField = self.formFields[self.currentFormIdx]
		var isUpdated = false
		
		if(currentField.formType == .DATE_TIME) {
			
			let splittedDatetime = currentField.formValue.components(separatedBy: "/")
			
			if(splittedDatetime.count == 3) {
				
				var monthval = splittedDatetime[0]
				var dayval = splittedDatetime[1]
				var yearval = splittedDatetime[2]
				
				if(self.currentCursorPos >= 3) {
					
					if let monthIntVal = Int(monthval) {
					
						if(monthIntVal > 12 || monthIntVal <= 0) {
							isUpdated = true
							monthval = "MM"
						}
					
					}else{
						isUpdated = true
						monthval = "MM"
					}
				}
				
				if(self.currentCursorPos >= 6) {
					
					if let dayIntVal = Int(dayval) {
					
						if(dayIntVal > 31 || dayIntVal <= 0) {
							isUpdated = true
							dayval = "DD"
						}
					
					}else{
						isUpdated = true
						dayval = "DD"
					}
				}
				
				if(self.currentCursorPos >= 11) {
					
					if let yearIntVal = Int(yearval) {
					
						if(yearIntVal > 9999 || yearIntVal < 1800) {
							isUpdated = true
							yearval = "YYYY"
						}
					
					}else{
						isUpdated = true
						yearval = "YYYY"
					}
				}
				
				currentField.formValue = "\(monthval)/\(dayval)/\(yearval)"
				
				if(isUpdated) {
				
					self.formFields[self.currentFormIdx] = currentField
					wclear(self.formWindow)
					drawFormArea()
				}
			}
		}
		
		return isUpdated
	}
}
