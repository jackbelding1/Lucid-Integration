//
// MyEntity.swift
//
// Generated automatically.
// Copyright © MyOrganization. All rights reserved.
//

import Lucid
import CoreData

// MARK: - Identifier

public final class MyEntityIdentifier: Codable, CoreDataIdentifier, RemoteIdentifier {

    public typealias LocalValueType = String
    public typealias RemoteValueType = Int

    public let _remoteSynchronizationState: PropertyBox<RemoteSynchronizationState>

    fileprivate let property: PropertyBox<IdentifierValueType<String, Int>>
    public var value: IdentifierValueType<String, Int> {
        return property.value
    }

    public static let entityTypeUID = "my_entity"
    public let identifierTypeID: String

    public init(from decoder: Decoder) throws {
        _remoteSynchronizationState = PropertyBox(.synced, atomic: false)
        switch decoder.context {
        case .payload, .clientQueueRequest:
            let container = try decoder.singleValueContainer()
            property = PropertyBox(try container.decode(IdentifierValueType<String, Int>.self), atomic: false)
            identifierTypeID = MyEntity.identifierTypeID
        case .coreDataRelationship:
            let container = try decoder.container(keyedBy: EntityIdentifierCodingKeys.self)
            property = PropertyBox(
                try container.decode(IdentifierValueType<String, Int>.self, forKey: .value),
                atomic: false
            )
            identifierTypeID = try container.decode(String.self, forKey: .identifierTypeID)
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch encoder.context {
        case .payload, .clientQueueRequest:
            var container = encoder.singleValueContainer()
            try container.encode(property.value)
        case .coreDataRelationship:
            var container = encoder.container(keyedBy: EntityIdentifierCodingKeys.self)
            try container.encode(property.value, forKey: .value)
            try container.encode(identifierTypeID, forKey: .identifierTypeID)
        }
    }

    public convenience init(value: IdentifierValueType<String, Int>,
                            identifierTypeID: Optional<String> = nil,
                            remoteSynchronizationState: Optional<RemoteSynchronizationState> = nil) {
        self.init(
            value: value,
            identifierTypeID: identifierTypeID,
            remoteSynchronizationState: remoteSynchronizationState ?? .synced
        )
    }

    public init(value: IdentifierValueType<String, Int>,
                identifierTypeID: Optional<String>,
                remoteSynchronizationState: RemoteSynchronizationState) {
        property = PropertyBox(value, atomic: false)
        self.identifierTypeID = identifierTypeID ?? MyEntity.identifierTypeID
        self._remoteSynchronizationState = PropertyBox(remoteSynchronizationState, atomic: false)
    }

    public static func == (_ lhs: MyEntityIdentifier,
                           _ rhs: MyEntityIdentifier) -> Bool { return lhs.value == rhs.value && lhs.identifierTypeID == rhs.identifierTypeID }

    public func hash(into hasher: inout DualHasher) {
        hasher.combine(value)
        hasher.combine(identifierTypeID)
    }

    public var description: String {
        return "\(identifierTypeID):\(value.description)"
    }
}

// MARK: - Identifiable

public protocol MyEntityIdentifiable {
    var myEntityIdentifier: MyEntityIdentifier { get }
}

extension MyEntityIdentifier: MyEntityIdentifiable {
    public var myEntityIdentifier: MyEntityIdentifier {
        return self
    }
}

// MARK: - MyEntity

public final class MyEntity: Codable {

    public typealias Metadata = VoidMetadata
    public typealias ResultPayload = EndpointResultPayload
    public typealias RelationshipIdentifier = EntityRelationshipIdentifier
    public typealias Subtype = EntitySubtype
    public typealias QueryContext = Never
    public typealias RelationshipIndexName = VoidRelationshipIndexName<AppAnyEntity>

    // IdentifierTypeID
    public static let identifierTypeID = "my_entity"

    // identifier
    public let identifier: MyEntityIdentifier

    // properties
    public let myBoolProperty: Bool

    public let myStringProperty: String

    init(identifier: MyEntityIdentifiable,
         myBoolProperty: Bool,
         myStringProperty: String) {

        self.identifier = identifier.myEntityIdentifier
        self.myBoolProperty = myBoolProperty
        self.myStringProperty = myStringProperty
    }
}

// MARK: - MyEntityPayload Initializer

extension MyEntity {
    convenience init(payload: MyEntityPayload) {
        self.init(
            identifier: payload.identifier,
            myBoolProperty: payload.myBoolProperty,
            myStringProperty: payload.myStringProperty
        )
    }
}

// MARK: - LocalEntiy, RemoteEntity

extension MyEntity: LocalEntity, RemoteEntity {

    public func entityIndexValue(for indexName: MyEntityIndexName) -> EntityIndexValue<EntityRelationshipIdentifier, EntitySubtype> {
        switch indexName {
        case .myBoolProperty:
            return .bool(myBoolProperty)
        case .myStringProperty:
            return .string(myStringProperty)
        }
    }

    public var entityRelationshipIndices: Array<MyEntityIndexName> {
        return []
    }

    public static func == (lhs: MyEntity,
                           rhs: MyEntity) -> Bool {
        guard lhs.identifier == rhs.identifier else { return false }
        guard lhs.myBoolProperty == rhs.myBoolProperty else { return false }
        guard lhs.myStringProperty == rhs.myStringProperty else { return false }
        return true
    }
}

// MARK: - CoreDataIndexName

extension MyEntityIndexName: CoreDataIndexName {

    public var predicateString: String {
        switch self {
        case .myBoolProperty:
            return "_my_bool_property"
        case .myStringProperty:
            return "_my_string_property"
        }
    }

    public var isOneToOneRelationship: Bool {
        switch self {
        case .myBoolProperty:
            return false
        case .myStringProperty:
            return false
        }
    }

    public var identifierTypeIDRelationshipPredicateString: Optional<String> {
        switch self {
        case .myBoolProperty:
            return nil
        case .myStringProperty:
            return nil
        }
    }
}

// MARK: - CoreDataEntity

extension MyEntity: CoreDataEntity {

    public static func entity(from coreDataEntity: ManagedMyEntity_1_0_0) -> Optional<MyEntity> {
        do {
            return try MyEntity(coreDataEntity: coreDataEntity)
        } catch {
            Logger.log(.error, "\(MyEntity.self): \(error)", domain: "Lucid", assert: true)
            return nil
        }
    }

    public func merge(into coreDataEntity: ManagedMyEntity_1_0_0) {
        coreDataEntity.setProperty(
            MyEntityIdentifier.remotePredicateString,
            value: identifier.remoteCoreDataValue()
        )
        coreDataEntity.setProperty(MyEntityIdentifier.localPredicateString, value: identifier.localCoreDataValue())
        coreDataEntity.__type_uid = identifier.identifierTypeID
        coreDataEntity._remote_synchronization_state = identifier._remoteSynchronizationState.value.coreDataValue()
        coreDataEntity._my_bool_property = myBoolProperty.coreDataValue()
        coreDataEntity._my_string_property = myStringProperty.coreDataValue()
    }

    private convenience init(coreDataEntity: ManagedMyEntity_1_0_0) throws {
        self.init(
            identifier: try coreDataEntity.identifierValueType(
                MyEntityIdentifier.self,
                identifierTypeID: coreDataEntity.__type_uid,
                remoteSynchronizationState: coreDataEntity._remote_synchronization_state?.synchronizationStateValue
            ),
            myBoolProperty: coreDataEntity._my_bool_property.boolValue(),
            myStringProperty: try coreDataEntity._my_string_property.stringValue(propertyName: "_my_string_property")
        )
    }
}

// MARK: - Cross Entities CoreData Conversion Utils

extension Data {
    func myEntityArrayValue() -> Optional<AnySequence<MyEntityIdentifier>> {
        guard let values: AnySequence<IdentifierValueType<String, Int>> = identifierValueTypeArrayValue(MyEntityIdentifier.self) else {
            return nil
        }
        return values.lazy.map { MyEntityIdentifier(value: $0) }.any
    }
}

extension Optional where Wrapped == Data {
    func myEntityArrayValue(propertyName: String) throws -> AnySequence<MyEntityIdentifier> {
        guard let values = self?.myEntityArrayValue() else {
            throw CoreDataConversionError.corruptedProperty(name: propertyName)
        }
        return values
    }

    func myEntityArrayValue() -> Optional<AnySequence<MyEntityIdentifier>> { return self?.myEntityArrayValue() }
}

// MARK: - Entity Merging

extension MyEntity {
    public func merging(_ updated: MyEntity) -> MyEntity { return updated }
}

// MARK: - IndexName

public enum MyEntityIndexName {
    case myBoolProperty
    case myStringProperty
}

extension MyEntityIndexName: QueryResultConvertible {
    public var requestValue: String {
        switch self {
        case .myBoolProperty:
            return "my_bool_property"
        case .myStringProperty:
            return "my_string_property"
        }
    }
}
