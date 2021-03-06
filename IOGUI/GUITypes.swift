//
//  GUITypes.swift
//  IORunner/IOGUI
//
//  Created by ilker özcan on 12/07/16.
//
//

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif
import Foundation

public enum WidgetUIColor: Int32 {
	
	case Background = 1
	case FooterBackground = 2
	case Title = 3
	case Border = 4
	case WarningLevelSuccess = 5
	case WarningLevelDanger = 6
	case WarningLevelCool = 7
	case ButtonDanger = 8
	case ButtonCool = 9
	case ButtonDangerSelected = 10
	case CyanBackground = 11
	case Progress = 12
	case ProgressBar = 13
	case ProgressText = 14
}

public struct GUIConstants {
	
	public static let MenuButtons = "Q/ESC -- exit                  ENTER   -- select"
	public static let ModuleButtons = "B   -- back                  ENTER   -- select"
	public static let ArrowsUpDown = "Arrow keys move up/down between fields"
	public static let ArrowsLeftRight = "Arrow keys move left/right between fields"
	public static let ArrowsAll = "Arrow keys move left/right within a field, up/down between fields"
}

public enum MainGuiActions {
	case NONE
	case EXIT
	case BACK
}

public typealias MainGuiDelegate = (_ action: MainGuiActions) -> ()
public typealias MainGuiKeyDelegate = (_ keyCode: Int32) -> Bool

public struct GUIWidgets {
	
	private var delegate: MainGuiDelegate
#if os(Linux)
	public var mainWindow: UnsafeMutablePointer<WINDOW>
#else
	public var mainWindow: OpaquePointer
#endif
	
	public var titleAndFooter: TitleAndFooterWidget?
	public var appInfo: AppInfoWidget?
	public var menu: MenuWidget?
	public var popup: PopupWidget?
	public var modules: ModulesWidget?
	public var background: BackgroundWidget?
	public var inputPopup: InputPopupWidget?
	public var textWidgets: [TextWidget]?
	public var formWidget: FormWidget?
	public var keyDelegate: MainGuiKeyDelegate?
	
	public var getLines: Int32 {
		
		get {
			return LINES
		}
	}
	
	public var getCols: Int32 {
		
		get {
			return COLS
		}
	}
	
	public init(delegate: @escaping MainGuiDelegate) {
		
		self.delegate = delegate
		
		setenv("LANG", "C.UTF-8", 1)
		
		setenv("LC_COLLATE", "C.UTF-8", 1)
		setlocale(LC_COLLATE, "C.UTF-8")
		
		setenv("LC_MESSAGES", "C.UTF-8", 1)
		setlocale(LC_MESSAGES, "C.UTF-8")
		
		setenv("LC_MONETARY", "C", 1)
		setlocale(LC_MONETARY, "C")
		
		setenv("LC_NUMERIC", "C", 1)
		setlocale(LC_NUMERIC, "C")
		
		setenv("LC_TIME", "C", 1)
		setlocale(LC_TIME, "C")
		
		setenv("LC_CTYPE", "en_US.UTF-8", 1)
		setlocale(LC_CTYPE, "en_US.UTF-8")
		setenv("LC_ALL", "en_US.UTF-8", 1)
		setlocale(LC_ALL, "en_US.UTF-8")
		
		mainWindow = initscr()
		cbreak()
		noecho()
		
		if(has_colors()) {
			
			start_color()
			init_pair(Int16(WidgetUIColor.Background.rawValue), Int16(COLOR_WHITE),
			          Int16(use_default_colors()))
			init_pair(Int16(WidgetUIColor.FooterBackground.rawValue), Int16(COLOR_MAGENTA),
			          Int16(COLOR_WHITE))
			init_pair(Int16(WidgetUIColor.Title.rawValue), Int16(COLOR_BLACK),
			          Int16(COLOR_WHITE))
			init_pair(Int16(WidgetUIColor.Border.rawValue), Int16(COLOR_WHITE),
			          Int16(COLOR_CYAN))
			init_pair(Int16(WidgetUIColor.WarningLevelSuccess.rawValue), Int16(COLOR_GREEN),
			          Int16(COLOR_BLACK))
			init_pair(Int16(WidgetUIColor.WarningLevelDanger.rawValue), Int16(COLOR_RED),
			          Int16(COLOR_BLACK))
			init_pair(Int16(WidgetUIColor.WarningLevelCool.rawValue), Int16(COLOR_BLUE),
			          Int16(COLOR_BLACK))
			init_pair(Int16(WidgetUIColor.ButtonDanger.rawValue), Int16(COLOR_WHITE),
			          Int16(COLOR_RED))
			init_pair(Int16(WidgetUIColor.ButtonCool.rawValue), Int16(COLOR_WHITE),
			          Int16(COLOR_BLUE))
			init_pair(Int16(WidgetUIColor.ButtonDangerSelected.rawValue), Int16(COLOR_RED),
			          Int16(COLOR_RED))
			init_pair(Int16(WidgetUIColor.CyanBackground.rawValue), Int16(use_default_colors()),
			          Int16(COLOR_CYAN))
			init_pair(Int16(WidgetUIColor.ButtonCool.rawValue), Int16(COLOR_WHITE),
			          Int16(COLOR_BLUE))
			init_pair(Int16(WidgetUIColor.Progress.rawValue), Int16(COLOR_GREEN),
			          Int16(COLOR_RED))
			init_pair(Int16(WidgetUIColor.ProgressBar.rawValue), Int16(COLOR_RED),
			          Int16(COLOR_GREEN))
			init_pair(Int16(WidgetUIColor.ProgressText.rawValue), Int16(COLOR_WHITE),
			          Int16(COLOR_GREEN))
		#if os(Linux)
			bkgd(UInt(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
		#else
			bkgd(UInt32(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
		#endif
		}
		
		nonl()
		intrflush(stdscr, true)
		keypad(stdscr, true)
		curs_set(0)
	}
	
	public mutating func initTitleWidget(widget: TitleAndFooterWidget) {
		
		if(self.titleAndFooter != nil) {
			deinitTitleWidget()
		}
		
		self.titleAndFooter = widget
		self.titleAndFooter?.draw()
		wrefresh(mainWindow)
	}
	
	public mutating func deinitTitleWidget() {
		
		if(titleAndFooter != nil) {
			
			titleAndFooter?.deinitWidget()
			titleAndFooter = nil
			wrefresh(mainWindow)
		}
	}
	
	public func hasTitleWidget() -> Bool {
		
		return (titleAndFooter != nil) ? true : false
	}
	
	public mutating func initAppInfoWidget(widget: AppInfoWidget) {
		
		if(self.appInfo != nil) {
			deinitAppInfoWidget()
		}
		
		self.appInfo = widget
		self.appInfo?.draw()
		wrefresh(mainWindow)
	}
	
	public mutating func deinitAppInfoWidget() {
		
		if(appInfo != nil) {
			
			appInfo?.deinitWidget()
			appInfo = nil
			wrefresh(mainWindow)
		}
	}
	
	public func hasAppInfoWidget() -> Bool {
		
		return (appInfo != nil) ? true : false
	}
	
	public mutating func initMenuWidget(widget: MenuWidget) {
		
		if(self.menu != nil) {
			deinitMenuWidget()
		}
		
		self.menu = widget
		self.menu?.draw()
		wrefresh(mainWindow)
	}
	
	public mutating func deinitMenuWidget() {
		
		if(menu != nil) {
			
			menu?.deinitWidget()
			menu = nil
			wrefresh(mainWindow)
		}
	}
	
	public func hasMenuWidget() -> Bool {
		
		return (menu != nil) ? true : false
	}
	
	public mutating func initPopupWidget(widget: PopupWidget) {
		
		if(self.popup != nil) {
			deinitPopupWidget()
		}
		
		self.popup = widget
		self.popup?.draw()
		wrefresh(mainWindow)
	}
	
	public mutating func deinitPopupWidget() {
		
		if(popup != nil) {
			
			popup?.deinitWidget()
			popup = nil
			wrefresh(mainWindow)
		}
		
		resizeAll()
	}
	
	public func hasPopupWidget() -> Bool {
		
		return (popup != nil) ? true : false
	}
	
	public mutating func initInputPopupWidget(widget: InputPopupWidget) {
	
		if(self.inputPopup != nil) {
			deinitInputPopupWidget()
		}
		
		self.inputPopup = widget
		self.inputPopup?.draw()
		wrefresh(mainWindow)
	}
	
	public mutating func deinitInputPopupWidget() {
		
		if(inputPopup != nil) {
			
			inputPopup?.deinitWidget()
			inputPopup = nil
			wrefresh(mainWindow)
		}
		
		resizeAll()
	}
	
	public func hasInputPopupWidget() -> Bool {
		
		return (inputPopup != nil) ? true : false
	}
	
	public mutating func initModuleWidget(widget: ModulesWidget) {
		
		if(self.modules != nil) {
			deinitModuleWidget()
		}
		
		self.modules = widget
		self.modules?.draw()
		wrefresh(mainWindow)
	}
	
	public mutating func deinitModuleWidget() {
		
		if(modules != nil) {
			
			modules?.deinitWidget()
			modules = nil
			wrefresh(mainWindow)
		}
	}
	
	public func hasModuleWidget() -> Bool {
		
		return (modules != nil) ? true : false
	}
	
	public mutating func initBackgroundWidget(widget: BackgroundWidget) {
		
		if(self.background != nil) {
			deinitBackgroundWidget()
		}
		
		self.background = widget
		self.background?.draw()
		wrefresh(mainWindow)
	}
	
	public mutating func deinitBackgroundWidget() {
		
		if(background != nil) {
			
			background?.deinitWidget()
			background = nil
			wrefresh(mainWindow)
		}
	}
	
	public func hasBackgroundWidget() -> Bool {
		
		return (background != nil) ? true : false
	}
	
	public mutating func initTextWidget(widget: TextWidget) -> Int {
		
		if(self.textWidgets == nil) {
			
			self.textWidgets = [TextWidget]()
		}
		
		let widgetIdx = self.textWidgets!.count
		self.textWidgets!.append(widget)
		widget.draw()
		wrefresh(mainWindow)
		
		return widgetIdx
	}
	
	public mutating func deinitTextWidget() {
		
		if(self.textWidgets != nil) {
		
			wclear(mainWindow)
			for var tWidget in self.textWidgets! {
				
				tWidget.deinitWidget()
			}
			
			self.textWidgets = nil
			wrefresh(mainWindow)
		}
	}
	
	public func hasTextWidget() -> Bool {
		
		return (textWidgets != nil) ? true : false
	}
	
	public mutating func initFormWidget(widget: FormWidget) {
		
		if(self.formWidget != nil) {
			deinitFormWidget()
		}
		
		self.formWidget = widget
		self.formWidget?.draw()
		wrefresh(mainWindow)
	}
	
	public mutating func deinitFormWidget() {
		
		if(formWidget != nil) {
			
			formWidget?.deinitWidget()
			formWidget = nil
			wrefresh(mainWindow)
		}
	}
	
	public func hasFormWidget() -> Bool {
		
		return (formWidget != nil) ? true : false
	}
	
	mutating func resizeAll() {
		
		wclear(self.mainWindow)
		
		if(background != nil) {
			
			background?.resize()
		}
		
		if(titleAndFooter != nil) {
			
			titleAndFooter?.resize()
		}
		
		if(appInfo != nil) {
			
			appInfo?.resize()
		}
		
		if(self.textWidgets != nil) {
			
			for var tWidget in self.textWidgets! {
				
				tWidget.resize()
			}
		}
		
		if(menu != nil) {
			
			menu?.resize()
		}
		
		if(modules != nil) {
			
			modules?.resize()
		}
		
		if(formWidget != nil) {
			
			formWidget?.resize()
		}
		
		if(popup != nil) {
			
			popup?.resize()
		}
		
		if(inputPopup != nil) {
			
			inputPopup?.resize()
		}
		
		wrefresh(self.mainWindow)
	}
	
	public mutating func deinitAll() {
		
		deinitTitleWidget()
		deinitAppInfoWidget()
		deinitTextWidget()
		deinitMenuWidget()
		deinitModuleWidget()
		deinitFormWidget()
		deinitPopupWidget()
		deinitBackgroundWidget()
		deinitInputPopupWidget()
		wrefresh(self.mainWindow)
	}
	
	mutating func sendKeyEventToWidget(keycode: Int32) {
		
		if(popup != nil) {
			
			popup?.keyEvent(keyCode: keycode)
			return
		}
		
		if(inputPopup != nil) {
			
			inputPopup?.keyEvent(keyCode: keycode)
			return
		}
		
		if(menu != nil) {
			

			menu?.keyEvent(keyCode: keycode)
		}
		
		if(modules != nil) {
			
			modules?.keyEvent(keyCode: keycode)
		}
		
		if(formWidget != nil) {
			
			formWidget?.keyEvent(keyCode: keycode)
		}
	}
	
	public mutating func onGUI() {
		
		let currentKey = getch()
	#if os(Linux)
		if(currentKey == KEY_RESIZE) {
			
			self.resizeAll()
		}else if(currentKey == 113 || currentKey == 27 || currentKey == 81) {
			
			if(self.hasInputPopupWidget()) {
				
				self.sendKeyEventToWidget(keycode: currentKey)
			}else{
				
				self.delegate(MainGuiActions.EXIT)
			}
			
		}else if(currentKey == 98 || currentKey == 66) {
			
			if(self.hasInputPopupWidget()) {
				
				self.sendKeyEventToWidget(keycode: currentKey)
			}else{
				
				self.delegate(MainGuiActions.BACK)
			}
			
		}else{
			
			if(self.keyDelegate != nil) {
				
				if(self.keyDelegate!(currentKey)) {
					self.sendKeyEventToWidget(keycode: currentKey)
				}
			}else{
				self.sendKeyEventToWidget(keycode: currentKey)
			}
		}
	#else
		if(currentKey == KEY_RESIZE) {
			
			self.resizeAll()
		}else if(currentKey == Int32(UnicodeScalar("q").value) || currentKey == 27 || currentKey == Int32(UnicodeScalar("Q").value)) {
			
			if(self.hasInputPopupWidget() || self.hasFormWidget()) {

				self.sendKeyEventToWidget(keycode: currentKey)
			}else{
				self.delegate(MainGuiActions.EXIT)
			}
			
		}else if(currentKey == Int32(UnicodeScalar("b").value) || currentKey == Int32(UnicodeScalar("B").value)) {
			
			if(self.hasInputPopupWidget() || self.hasFormWidget()) {

				self.sendKeyEventToWidget(keycode: currentKey)
			}else{
				self.delegate(MainGuiActions.BACK)
			}

		}else{
			
			if(self.keyDelegate != nil) {
				if(self.keyDelegate!(currentKey)) {
					
					self.sendKeyEventToWidget(keycode: currentKey)
				}
			}else{
				self.sendKeyEventToWidget(keycode: currentKey)
			}
		}
	#endif
	}
	
	public mutating func exitGui(status: Int32) {
		
		self.deinitAll()
		endwin()
		exit(status)
	}
	
	public mutating func waitPopup(waitForSecond: UInt) {
		
		let loopStartDate: UInt = UInt(Date().timeIntervalSince1970)
		repeat {
		
			let currentDate: UInt = UInt(Date().timeIntervalSince1970)
			let dateDif = currentDate - loopStartDate
			
			if(dateDif > waitForSecond) {
				break
			}
			
		} while(true)
	}
	
	public mutating func refreshMainWindow() {
		
		self.resizeAll()
	}
}
