//
// EndpointResultPayload.swift
//
// Generated automatically.
// Copyright © MyOrganization. All rights reserved.
//

import Lucid
import Foundation

public final class EndpointResultPayload: ResultPayloadConvertible {

    // MARK: - Content

    public enum Endpoint {
    }

    // MARK: - Precached Entities

    public let myEntities: OrderedDualHashDictionary<MyEntityIdentifier, MyEntity>

    // MARK: - Metadata

    public let metadata: EndpointResultMetadata

    // MARK: - Init

    public init(from data: Data,
                endpoint: Endpoint,
                decoder: JSONDecoder) throws {

        var myEntities = OrderedDualHashDictionary<MyEntityIdentifier, MyEntity>(optimizeWriteOperation: true)
        let entities: AnySequence<AppAnyEntity>

        switch endpoint {
        }

        for entity in entities {
            switch entity {
            case .myEntity(let value):
                myEntities[value.identifier] = value
            }
        }

        self.myEntities = myEntities
    }

    public func getEntity<E>(for identifier: E.Identifier) -> Optional<E> where E : Entity {

        switch identifier {
        case let entityIdentifier as MyEntityIdentifier:
            return myEntities[entityIdentifier] as? E
        default:
            return nil
        }
    }

    public func allEntities<E>() -> AnySequence<E> where E : Entity {

        switch E.self {
        case is MyEntity.Type:
            return myEntities.orderedValues.any as? AnySequence<E> ?? [].any
        default:
            return [].any
        }
    }
}
