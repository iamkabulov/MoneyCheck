//
//  MainTests.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 19.04.2026.
//

import XCTest

@MainActor
final class MainTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    @MainActor
    func testMainScreenTab() {
        precondition {
            TestContext.app.launch()
            TestContext.app.launchArguments
        }

        MainScreen()
            .step("step1") {
                $0.finance.tap()
                $0.analytics.check(isSelected: false)
                $0.finance.check(isSelected: true)
                $0.finance.check(text: "Finance")
                $0.finance.check(existance: true)
                $0.expenses.check(existance: false)
            }
            .step("step2") {
                $0.analytics.tap()
                $0.analytics.check(isSelected: true)
                $0.finance.check(isSelected: false)
                $0.expenses.tap()
                $0.expenses.check(existance: true)
            }
    }
}


extension XCTestCase {
    func precondition(block: () -> Void) {
        XCTContext.runActivity(named: "Precondition:") { _ in
            block()
        }
    }
}
