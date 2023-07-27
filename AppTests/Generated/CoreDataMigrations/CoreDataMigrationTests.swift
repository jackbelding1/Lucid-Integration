//
// CoreDataMigrationTests.swift
//
// Generated automatically.
// Copyright © MyOrganization. All rights reserved.
//

import XCTest
@testable import App
import Lucid
@testable import AppTestSupport
import LucidTestKit

final class CoreDataMigrationTests: XCTestCase {

    private let fileManager: FileManager = .default

    private let projectDirectoryPath: String = {
        guard let projectDirectoryPath = ProcessInfo.processInfo.environment["LUCID_PROJECT_DIR"] else {
            fatalError("Environment variable 'LUCID_PROJECT_DIR' is not defined. Please define it to `$PROJECT_DIR` in the Scheme configuration.")
        }
        return projectDirectoryPath
    }()

    override func setUp() {
        super.setUp()
        LucidConfiguration.logger = LoggerMock(shouldCauseFailures: false)
    }

    override func tearDown() {
        defer { super.tearDown() }
        LucidConfiguration.logger = nil
    }

    private func runTest(for sqliteFile: String, version: Version) throws {
        guard let appSupportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first else {
            XCTFail("Could not find app support directory")
            return
        }

        var expectations: [XCTestExpectation] = []

        let sourceURL = URL(fileURLWithPath: "\(projectDirectoryPath)/AppTests/Generated/SQLite/\(sqliteFile)")
        let destinationURL = URL(fileURLWithPath: "\(appSupportDirectory)/\(sqliteFile)")

        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        } else if fileManager.fileExists(atPath: appSupportDirectory) == false {
            try fileManager.createDirectory(atPath: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        try fileManager.copyItem(at: sourceURL, to: destinationURL)

        let bundle = Bundle(for: CoreManagerContainer.self)
        guard let modelURL = bundle.url(forResource: "App", withExtension: "momd") else {
            XCTFail("Could not build model URL.")
            return
        }

        let coreDataManager = CoreDataManager(modelURL: modelURL,
                                              persistentStoreURL: destinationURL,
                                              migrations: CoreDataManager.migrations(),
                                              forceMigration: true)

        let myEntityExpectation = self.expectation(description: "MyEntity")
        expectations.append(myEntityExpectation)

        let myEntityCoreDataStore = CoreDataStore<MyEntity>(coreDataManager: coreDataManager)
        myEntityCoreDataStore.search(withQuery: .all, in: _ReadContext<EndpointResultPayload>()) { result in
            defer { myEntityExpectation.fulfill() }
            switch result {
            case .success(let result):
                XCTAssertNotNil(result.entity)
                XCTAssertNotNil(result.entity?.myBoolProperty)
                XCTAssertNotNil(result.entity?.myStringProperty)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }

        guard expectations.isEmpty == false else { return }

        waitForExpectations(timeout: 10) { (_: Error?) in
            if self.fileManager.fileExists(atPath: destinationURL.path) {
                try! self.fileManager.removeItem(at: destinationURL)
            }
            let expectation = self.expectation(description: "database_cleanup")
            coreDataManager.clearDatabase { (_) in
                expectation.fulfill()
            }
            self.waitForExpectations(timeout: 1, handler: nil)
        }
    }

    func test_app_versions() {
        XCTAssertNotNil(AppVersions.version1_0_0)
    }

}

final class AppVersions {
    static let version1_0_0: Version! = try? Version("1.0.0")

    static var currentVersion: Version {
        return version1_0_0
    }
}
