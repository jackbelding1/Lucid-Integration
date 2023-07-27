//
// EntityGraph.swift
//
// Generated automatically.
// Copyright © MyOrganization. All rights reserved.
//

import Lucid
import Combine

typealias AppRelationshipController = RelationshipController<CoreManagerContainer, EntityGraph>

public enum AppAnyEntity: EntityIndexing, EntityConvertible {
    case myEntity(MyEntity)

    public var entityRelationshipIndices: Array<AppAnyEntityIndexName> {
        switch self {
        case .myEntity(let entity):
            return entity.entityRelationshipIndices.map { .myEntity($0) }
        }
    }

    public func entityIndexValue(for indexName: AppAnyEntityIndexName) -> EntityIndexValue<EntityRelationshipIdentifier, EntitySubtype> {
        switch (self, indexName) {
        case (.myEntity(let entity), .myEntity(let indexName)):
            return entity.entityIndexValue(for: indexName)
        default:
            return .none
        }
    }

    public init?<E>(_ entity: E) where E: Entity {
        switch entity {
        case let entity as MyEntity:
            self = .myEntity(entity)
        default:
            return nil
        }
    }

    public var description: String {
        switch self {
        case .myEntity(let entity):
            return entity.identifier.description
        }
    }
}

extension Sequence where Element: Entity {
    var anyEntities: Array<AppAnyEntity> {
        return compactMap(AppAnyEntity.init)
    }
}

public enum AppAnyEntityIndexName: Hashable, QueryResultConvertible {
    case myEntity(MyEntity.IndexName)

    public var requestValue: String {
        switch self {
        case .myEntity(let index):
            return index.requestValue
        }
    }
}

final class EntityGraph: MutableGraph {

    typealias AnyEntity = AppAnyEntity

    let isDataRemote: Bool

    private(set) var rootEntities: Array<AppAnyEntity>

    private(set) var _metadata: Optional<EndpointResultMetadata>
    private(set) var myEntities = OrderedDualHashDictionary<MyEntityIdentifier, MyEntity>()

    convenience init() { self.init(isDataRemote: false) }

    convenience init<P>(context: _ReadContext<P>) where P: ResultPayloadConvertible { self.init(isDataRemote: context.responseHeader != nil) }

    private init(isDataRemote: Bool) {
        self.isDataRemote = isDataRemote
        self.rootEntities = []
        self._metadata = nil
    }

    func setRoot<S>(_ entities: S) where S: Sequence, S.Element == AppAnyEntity { rootEntities = entities.array }

    func insert<S>(_ entities: S) where S: Sequence, S.Element == AppAnyEntity {
        entities.forEach {
            switch $0 {
            case .myEntity(let entity):
                myEntities[entity.identifier] = entity
            }
        }
    }

    func contains(_ identifier: AnyRelationshipIdentifierConvertible) -> Bool {
        switch identifier as? EntityRelationshipIdentifier {
        case .myEntity(let identifier):
            return myEntities[identifier] != nil
        case .none:
            return false
        }
    }

    func setEndpointResultMetadata(_ metadata: EndpointResultMetadata) { _metadata = metadata }

    func metadata<E>() -> Optional<Metadata<E>> where E : Entity { return _metadata.map { Metadata<E>($0) } }

    var entities: AnySequence<AppAnyEntity> {
        let myEntities = self.myEntities.lazy.elements.map { AppAnyEntity.myEntity($0.1) }.any
        return Array(arrayLiteral: myEntities).joined().any
    }

    func append(_ otherGraph: EntityGraph) {
        rootEntities.append(contentsOf: otherGraph.rootEntities)
        insert(otherGraph.entities)
    }
}

extension RelationshipController.RelationshipQuery where Graph == EntityGraph {

    func buildGraph() -> (once: AnyPublisher<EntityGraph, ManagerError>, continuous: AnyPublisher<EntityGraph, ManagerError>) {
        let publishers = perform(EntityGraph.self)
        return (
            publishers.once.map { $0 as EntityGraph }.eraseToAnyPublisher(),
            publishers.continuous.map { $0 as EntityGraph }.eraseToAnyPublisher()
        )
    }

    func buildGraph() async throws -> (once: EntityGraph, continuous: AsyncStream<EntityGraph>) {
        let result = try await perform(EntityGraph.self)

        return (
            result.once,
            result.continuous
        )
    }
}
