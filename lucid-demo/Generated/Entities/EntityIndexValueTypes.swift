//
// EntityIndexValueTypes.swift
//
// Generated automatically.
// Copyright © MyOrganization. All rights reserved.
//

import Lucid

// MARK: - EntityRelationshipIdentifier

public enum EntityRelationshipIdentifier: AnyCoreDataRelationshipIdentifier {
    case myEntity(MyEntityIdentifier)
}

// MARK: - Comparable

extension EntityRelationshipIdentifier {

    public static func < (lhs: EntityRelationshipIdentifier,
                          rhs: EntityRelationshipIdentifier) -> Bool {
        switch (lhs, rhs) {
        case (.myEntity(let lhs), .myEntity(let rhs)):
            return lhs < rhs
        default:
            return false
        }
    }
}

// MARK: - DualHashable

extension EntityRelationshipIdentifier {

    public func hash(into hasher: inout DualHasher) {
        switch self {
        case .myEntity(let identifier):
            hasher.combine(identifier)
        }
    }
}

// MARK: - Conversions

extension EntityRelationshipIdentifier {

    public func toRelationshipID<ID>() -> Optional<ID> where ID : EntityIdentifier {
        switch self {
        case .myEntity(let myEntity as ID):
            return myEntity
        case .myEntity:
            return nil
        }
    }

    public var coreDataIdentifierValue: CoreDataRelationshipIdentifierValueType {
        switch self {
        case .myEntity(let myEntity):
            return myEntity.coreDataIdentifierValue
        }
    }

    public var identifierTypeID: String {
        switch self {
        case .myEntity(let myEntity):
            return myEntity.identifierTypeID
        }
    }

    public static var entityTypeUID: String {
        return ""
    }

    public var entityTypeUID: String {
        switch self {
        case .myEntity(let myEntity):
            return myEntity.entityTypeUID
        }
    }

    public var description: String {
        switch self {
        case .myEntity(let myEntity):
            return myEntity.description
        }
    }
}

// MARK: - EntitySubtype

public enum EntitySubtype: AnyCoreDataSubtype {
}

// MARK: - Conversions

extension EntitySubtype {

    public var predicateValue: Optional<Any> {
        switch self {
        }
    }
}

// MARK: - Comparable

extension EntitySubtype: Comparable {

    public static func < (lhs: EntitySubtype,
                          rhs: EntitySubtype) -> Bool {
        switch (lhs, rhs) {
        default:
            return false
        }
    }
}
