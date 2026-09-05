import XCTest

final class FlowConteUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCreateEditTagAndReleaseContent() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-UITest_ResetStore"]
        app.launch()

        let newItemButton = app.buttons["newItemButton"]
        XCTAssertTrue(newItemButton.waitForExistence(timeout: 5))
        newItemButton.tap()

        let titleField = app.textFields["contentTitleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.replaceText(with: "UIテストコンテンツ")

        let bodyEditor = app.textViews["contentBodyEditor"]
        XCTAssertTrue(bodyEditor.waitForExistence(timeout: 5))
        bodyEditor.tap()
        bodyEditor.typeText("これはUIテストで入力した本文です。三十文字以上になるように十分な長さの文章にしています。")

        let tagField = app.textFields["tagDraftField"]
        XCTAssertTrue(tagField.waitForExistence(timeout: 5))
        tagField.tap()
        tagField.typeText("テスト")
        app.buttons["tagAddButton"].tap()

        let releaseButton = app.buttons["releaseButton"]
        XCTAssertTrue(releaseButton.waitForExistence(timeout: 5))
        releaseButton.tap()
        XCTAssertTrue(app.buttons["releaseButton"].label.contains("リリース済み"))

        let editSaveButton = app.buttons["editSaveButton"]
        XCTAssertEqual(editSaveButton.label, "保存")
        editSaveButton.tap()
        XCTAssertEqual(app.buttons["editSaveButton"].label, "編集")

        app.navigationBars.buttons.firstMatch.tap()

        let row = app.descendants(matching: .any)["contentRow_UIテストコンテンツ"]
        if !row.waitForExistence(timeout: 5) {
            XCTFail(app.debugDescription)
        }
    }
}
