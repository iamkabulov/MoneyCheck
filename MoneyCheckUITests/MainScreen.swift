//
//  MainScreen.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 19.04.2026.
//
import XCTest

enum TestContext {
    static var app = XCUIApplication()
}

class BaseScreen {
    let app = TestContext.app
}

class MainScreen: BaseScreen {
    var finance: XCUIElement { app.tabBars.buttons["TESTID_Finance"] }
    var analytics: XCUIElement { app.tabBars.buttons["TESTID_Analytics"] }
    var expenses: XCUIElement { app.staticTexts["testik0"] }

    @discardableResult
    func step(_ name: String, block: (MainScreen) -> Void) -> MainScreen {
        XCTContext.runActivity(named: name) { _ in
            block(self)
        }
        return self
    }
}

extension XCUIElement {
    func check(isSelected: Bool) {
        XCTAssertEqual(self.isSelected, isSelected)
    }

    func check(text: String) {
        XCTAssertEqual(self.label, text)
    }

    func check(existance: Bool) {
        XCTAssertEqual(self.exists, existance)
    }
}
