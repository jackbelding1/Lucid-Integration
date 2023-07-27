//
// MyEntityCoreDataTests.swift
//
// Generated automatically.
// Copyright © MyOrganization. All rights reserved.
//

import XCTest
import Lucid
@testable import App
import LucidTestKit
@testable import AppTestSupport

final class MyEntityCoreDataTests: XCTestCase {

    private var store: CoreDataStore<MyEntity>!

    override func setUp() {
        super.setUp()

        LucidConfiguration.logger = LoggerMock()
        store = CoreDataStore(coreDataManager: CoreDataManager(modelName: "App",
                                                               in: Bundle(for: CoreManagerContainer.self),
                                                               storeType: .memory))
    }

    override func tearDown() {
        defer { super.tearDown() }

        store = nil
        LucidConfiguration.logger = nil
    }

    // MARK: - Tests

    func test_my_entity_should_be_stored_then_restored_from_core_data() {
        let expectation = self.expectation(description: "my_entity")
        let initialEntity = MyEntityFactory(42).entity

        store.set(initialEntity, in: WriteContext(dataTarget: .local)) { result in
            guard let result = result else {
                XCTFail("Unexpectedly received nil.")
                return
            }

            switch result {
            case .success(let entity):

                self.store.get(byID: entity.identifier, in: _ReadContext<EndpointResultPayload>()) { result in
                    switch result {
                    case .success(let result):
                        XCTAssertEqual(
                            result.entity?.identifier.remoteSynchronizationState,
                            initialEntity.identifier.remoteSynchronizationState
                        )
                        XCTAssertEqual(result.entity?.myBoolProperty, initialEntity.myBoolProperty)
                        XCTAssertEqual(result.entity?.myStringProperty, initialEntity.myStringProperty)
                        XCTAssertEqual(result.entity?.identifier, MyEntityIdentifier(value: .remote(Int(42), nil)))

                    case .failure(let error):
                        XCTFail("Unexpected error: \(error).")
                    }
                    expectation.fulfill()
                }

            case .failure(let error):
                XCTFail("Unexpected error: \(error).")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }
}
