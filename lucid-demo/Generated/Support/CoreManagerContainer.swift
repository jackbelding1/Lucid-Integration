//
// CoreManagerContainer.swift
//
// Generated automatically.
// Copyright © MyOrganization. All rights reserved.
//

import Lucid
import Combine
import Foundation


// MARK: - Response Handler

public protocol CoreManagerContainerClientQueueResponseHandler: APIClientQueueResponseHandler {
    var managers: CoreManagerContainer? { get set } // Should be declared weak in order to avoid a retain cycle
}

// MARK: - Resolvers

typealias CoreManagerResolver = MyEntityCoreManagerProviding

protocol MyEntityCoreManagerProviding {
    var myEntityManager: CoreManaging<MyEntity, AppAnyEntity> { get }
}


// MARK: - Container

public final class CoreManagerContainer {

    public struct DiskStoreConfig {
        public let coreDataManager: CoreDataManager?
        public let custom: Any?

        public static var coreData: DiskStoreConfig {
            let coreDataManager = CoreDataManager(modelName: "App", in: Bundle(for: CoreManagerContainer.self), migrations: [])
            return DiskStoreConfig(coreDataManager: coreDataManager, custom: nil)
        }

        public init(coreDataManager: CoreDataManager?,
                    custom: Any?) {
            self.coreDataManager = coreDataManager
            self.custom = custom
        }
    }

    public struct CacheSize {
        public let small: Int
        public let medium: Int
        public let large: Int

        public static var `default`: CacheSize { return CacheSize(small: 100, medium: 500, large: 2000) }

        public init(small: Int,
                    medium: Int,
                    large: Int) {
            self.small = small
            self.medium = medium
            self.large = large
        }
    }

    private let _responseHandler: CoreManagerContainerClientQueueResponseHandler?
    public var responseHandler: APIClientQueueResponseHandler? {
        return _responseHandler
    }

    public let clientQueues: Set<APIClientQueue>
    public let mainClientQueue: APIClientQueue

    private let cancellable = CancellableBox()

    private let _myEntityManager: CoreManager<MyEntity>
    private lazy var _myEntityRelationshipManager = CoreManaging<MyEntity, AppAnyEntity>.RelationshipManager(self)
    var myEntityManager: CoreManaging<MyEntity, AppAnyEntity> {
        return _myEntityManager.managing(_myEntityRelationshipManager)
    }

    public init(cacheSize: CacheSize = .default,
                client: APIClient,
                diskStoreConfig: DiskStoreConfig = .coreData,
                responseHandler: Optional<CoreManagerContainerClientQueueResponseHandler> = nil) {

        _responseHandler = responseHandler
        var clientQueues = Set<APIClientQueue>()
        var clientQueue: APIClientQueue

        let mainClientQueue = APIClientQueue.clientQueue(
            for: "\(CoreManagerContainer.self)_api_client_queue",
            client: client,
            scheduler: APIClientQueueDefaultScheduler()
        )

        clientQueue = mainClientQueue
        _myEntityManager = CoreManager(
            stores: MyEntity.stores(
                with: client,
                clientQueue: &clientQueue,
                cacheLimit: cacheSize.medium,
                diskStoreConfig: diskStoreConfig
            )
        )
        clientQueues.insert(clientQueue)

        if let responseHandler = _responseHandler {
            clientQueues.forEach { $0.register(responseHandler) }
        }
        self.clientQueues = clientQueues
        self.mainClientQueue = mainClientQueue

        // Init of lazy vars for thread-safety.
        _ = _myEntityRelationshipManager

        _responseHandler?.managers = self
    }
}

extension CoreManagerContainer: CoreManagerResolver {
}

// MARK: - Relationship Manager

extension CoreManagerContainer: RelationshipCoreManaging {

    public func get(byIDs identifiers: AnySequence<AnyRelationshipIdentifierConvertible>,
                    entityType: String,
                    in context: _ReadContext<EndpointResultPayload>) -> AnyPublisher<AnySequence<AppAnyEntity>, ManagerError> {
        switch entityType {
        case MyEntityIdentifier.entityTypeUID:
            return myEntityManager.get(
                byIDs: identifiers.lazy.compactMap { $0.toRelationshipID() }.uniquified(),
                in: context
            ).once.map { $0.lazy.map { .myEntity($0) }.any }.eraseToAnyPublisher()
        default:
            return Fail(error: .notSupported).eraseToAnyPublisher()
        }
    }

    public func get(byIDs identifiers: AnySequence<AnyRelationshipIdentifierConvertible>,
                    entityType: String,
                    in context: _ReadContext<EndpointResultPayload>) async throws -> AnySequence<AppAnyEntity> {
        switch entityType {
        case MyEntityIdentifier.entityTypeUID:
            return try await myEntityManager.get(
                byIDs: identifiers.lazy.compactMap { $0.toRelationshipID() }.uniquified(),
                in: context
            ).once.lazy.map { .myEntity($0) }.any
        default:
            throw ManagerError.notSupported
        }
    }
}

// MARK: - Persistence Manager

extension CoreManagerContainer: RemoteStoreCachePayloadPersistenceManaging {

    public func persistEntities(from payload: AnyResultPayloadConvertible,
                                accessValidator: Optional<UserAccessValidating>) {

        myEntityManager
            .set(payload.allEntities(), in: WriteContext(dataTarget: .local, accessValidator: accessValidator))
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: cancellable)
    }
}

// MARK: - Default Entity Stores

/// Manually add the function:
/// ```
/// static func stores(with client: APIClient,
///                    clientQueue: inout APIClientQueue,
///                    cacheLimit: Int,
///                    diskStoreConfig: CoreManagerContainer.DiskStoreConfig) -> Array<Storing<Self>>
/// ```
/// to an individual class adopting the Entity protocol to provide custom functionality

extension LocalEntity {
    static func stores(with client: APIClient,
                       clientQueue: inout APIClientQueue,
                       cacheLimit: Int,
                       diskStoreConfig: CoreManagerContainer.DiskStoreConfig) -> Array<Storing<Self>> {
        let localStore = LRUStore<Self>(store: InMemoryStore().storing, limit: cacheLimit)
        return Array(arrayLiteral: localStore.storing)
    }
}

extension CoreDataEntity {
    static func stores(with client: APIClient,
                       clientQueue: inout APIClientQueue,
                       cacheLimit: Int,
                       diskStoreConfig: CoreManagerContainer.DiskStoreConfig) -> Array<Storing<Self>> {

        guard let coreDataManager = diskStoreConfig.coreDataManager else {
            Logger.log(.error, "\(Self.self): Cannot build \(CoreDataStore<Self>.self) without a \(CoreDataManager.self) instance.", assert: true)
            return Array()
        }

        let localStore = CacheStore<Self>(
            keyValueStore: LRUStore(store: InMemoryStore().storing, limit: cacheLimit).storing,
            persistentStore: CoreDataStore(coreDataManager: coreDataManager).storing
        )
        return Array(arrayLiteral: localStore.storing)
    }
}

extension RemoteEntity {
    static func stores(with client: APIClient,
                       clientQueue: inout APIClientQueue,
                       cacheLimit: Int,
                       diskStoreConfig: CoreManagerContainer.DiskStoreConfig) -> Array<Storing<Self>> {
        let remoteStore = RemoteStore<Self>(clientQueue: clientQueue)
        return Array(arrayLiteral: remoteStore.storing)
    }
}

extension RemoteEntity where Self : CoreDataEntity {
    static func stores(with client: APIClient,
                       clientQueue: inout APIClientQueue,
                       cacheLimit: Int,
                       diskStoreConfig: CoreManagerContainer.DiskStoreConfig) -> Array<Storing<Self>> {

        guard let coreDataManager = diskStoreConfig.coreDataManager else {
            Logger.log(.error, "\(Self.self): Cannot build \(CoreDataStore<Self>.self) without a \(CoreDataManager.self) instance.", assert: true)
            return Array()
        }

        let remoteStore = RemoteStore<Self>(clientQueue: clientQueue)
        let localStore = CacheStore<Self>(
            keyValueStore: LRUStore(store: InMemoryStore().storing, limit: cacheLimit).storing,
            persistentStore: CoreDataStore(coreDataManager: coreDataManager).storing
        )
        return Array(arrayLiteral: remoteStore.storing, localStore.storing)
    }
}
