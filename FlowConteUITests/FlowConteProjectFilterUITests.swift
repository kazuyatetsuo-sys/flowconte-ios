import XCTest

final class FlowConteProjectFilterUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testProjectAndOrFiltering() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-UITest_ResetStore"]
        app.launch()

        createContent(app, title: "コンテンツA", tags: ["赤", "丸"])
        createContent(app, title: "コンテンツB", tags: ["赤"])

        // Switch to the Projects tab and create a new project.
        app.buttons["プロジェクト"].tap()
        app.buttons["newItemButton"].tap()

        let nameField = app.textFields["projectNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.replaceText(with: "プロジェクトX")

        addTag(app, "赤")
        addTag(app, "丸")

        // Default filter mode is OR; switch to AND so only the content with both tags matches.
        app.buttons["すべて一致 (AND)"].tap()
        app.buttons["projectEditSaveButton"].tap()

        let countLabel = app.staticTexts["projectMatchCountLabel"]
        XCTAssertTrue(countLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(countLabel.label, "該当コンテンツ (1)")
        XCTAssertTrue(app.buttons["projectContentRow_コンテンツA"].exists)
        XCTAssertFalse(app.buttons["projectContentRow_コンテンツB"].exists)

        // Switch to OR: both contents share the "赤" tag, so both should match now.
        app.buttons["projectEditSaveButton"].tap()
        app.buttons["いずれか一致 (OR)"].tap()
        app.buttons["projectEditSaveButton"].tap()

        XCTAssertEqual(app.staticTexts["projectMatchCountLabel"].label, "該当コンテンツ (2)")
        XCTAssertTrue(app.buttons["projectContentRow_コンテンツA"].exists)
        XCTAssertTrue(app.buttons["projectContentRow_コンテンツB"].exists)
    }

    private func createContent(_ app: XCUIApplication, title: String, tags: [String]) {
        app.buttons["newItemButton"].tap()

        let titleField = app.textFields["contentTitleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.replaceText(with: title)

        for tag in tags {
            addTag(app, tag)
        }

        app.buttons["editSaveButton"].tap()
        app.navigationBars.buttons.firstMatch.tap()
    }

    private func addTag(_ app: XCUIApplication, _ tag: String) {
        let tagField = app.textFields["tagDraftField"]
        XCTAssertTrue(tagField.waitForExistence(timeout: 5))
        tagField.tap()
        tagField.typeText(tag)
        app.buttons["tagAddButton"].tap()
    }
}
