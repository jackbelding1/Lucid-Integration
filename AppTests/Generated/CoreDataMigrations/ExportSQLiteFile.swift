//
// ExportSQLiteFile.swift
//
// Generated automatically.
// Copyright © MyOrganization. All rights reserved.
//

import XCTest
@testable import App
import Lucid
@testable import AppTestSupport
import LucidTestKit

final class ExportSQLiteFile: XCTestCase {

    private let coreDataManager = CoreDataManager(modelName: "App",
                                                  in: Bundle(for: CoreManagerContainer.self),
                                                  migrations: CoreDataManager.migrations())

    private let projectDirectoryPath: String = {
        guard let projectDirectoryPath = ProcessInfo.processInfo.environment["LUCID_PROJECT_DIR"] else {
            fatalError("Environment variable 'LUCID_PROJECT_DIR' is not defined. Please define it to `$PROJECT_DIR` in the Scheme configuration.")
        }
        return projectDirectoryPath
    }()

    override func setUp() {
        super.setUp()

        LucidConfiguration.logger = LoggerMock()
    }

    override func tearDown() {
        defer { super.tearDown() }

        LucidConfiguration.logger = nil
    }

    func test_populate_database_and_export_sqlite_file() throws {

        let destinationDirectory = "\(projectDirectoryPath)/AppTests/Generated/SQLite/"
        let sqliteFileURL = URL(fileURLWithPath: "\(destinationDirectory)/App_1_0_0.sqlite")
        let descriptionsHashFileURL = URL(fileURLWithPath: "\(destinationDirectory)/App_1_0_0.sha256")

        guard let descriptionsHash = "3dc40aec01d5a1936437456fe3eaaca4".data(using: .utf8) else {
            XCTFail("Descriptions hash is not UTF-8")
            return
        }

        if FileManager.default.fileExists(atPath: descriptionsHashFileURL.path) {
            let currentDescriptionsHash = FileManager.default.contents(atPath: descriptionsHashFileURL.path)
            if currentDescriptionsHash == descriptionsHash {
                Logger.log(.info, "No change detected since sqlite file was last generated.", domain: "test")
                return
            }
            try FileManager.default.removeItem(at: descriptionsHashFileURL)
        }

        let expectation = self.expectation(description: "expectation")
        coreDataManager.clearDatabase { success in
            if success == false {
                XCTFail("Could not clear database.")
                expectation.fulfill()
                return
            }

            var didErrorOccur = false
            let dispatchGroup = DispatchGroup()

            // MyEntity
            let myEntityCoreDataStore = CoreDataStore<MyEntity>(coreDataManager: self.coreDataManager)
            dispatchGroup.enter()
            myEntityCoreDataStore.set(
                Array(arrayLiteral: MyEntityFactory(42).entity).any,
                in: WriteContext(dataTarget: .local)
            ) { (result) in
                defer { dispatchGroup.leave() }
                if result == nil {
                    didErrorOccur = true
                    XCTFail("Unexpectedly received nil.")
                    return
                } else if let error = result?.error {
                    didErrorOccur = true
                    XCTFail("Unexpected error: \(error)")
                    return
                }
            }

            dispatchGroup.notify(queue: .main) {
                let errorMessage = "Something wrong happened. SQLite file wasn't exported successfully."

                guard didErrorOccur == false else {
                    expectation.fulfill()
                    XCTFail(errorMessage)
                    return
                }

                self.coreDataManager.backupPersistentStore(to: sqliteFileURL) { success in
                    if success == false {
                        XCTFail(errorMessage)
                    }

                    if FileManager.default.createFile(atPath: descriptionsHashFileURL.path, contents: descriptionsHash, attributes: nil) == false {
                        XCTFail("Could not store descriptions hash file at \(descriptionsHashFileURL.path).")
                    }

                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 10)
    }
}
