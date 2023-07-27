//
// MyEntityPayloads.swift
//
// Generated automatically.
// Copyright © MyOrganization. All rights reserved.
//

import Lucid

final class MyEntityPayload: ArrayConvertable {

    // identifier
    let id: Int

    // properties
    let myBoolProperty: Bool
    let myStringProperty: String

    init(id: Int,
         myBoolProperty: Bool,
         myStringProperty: String) {

        self.id = id
        self.myBoolProperty = myBoolProperty
        self.myStringProperty = myStringProperty
    }
}

extension MyEntityPayload: PayloadIdentifierDecodableKeyProvider {

    static let identifierKey = "id"
    var identifier: MyEntityIdentifier {
        return MyEntityIdentifier(value: .remote(id, nil))
    }
}

// MARK: - Default Endpoint Payload

final class DefaultEndpointMyEntityPayload: Decodable, PayloadConvertable, ArrayConvertable {

    let rootPayload: MyEntityPayload
    let entityMetadata: Optional<VoidMetadata>

    private enum Keys: String, CodingKey {
        case id
        case myBoolProperty
        case myStringProperty
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let excludedProperties = decoder.excludedPropertiesAtCurrentPath
        let rootPayload = MyEntityPayload(
            id: try container.decode(
                Int.self,
                forKey: .id,
                defaultValue: nil,
                excludedProperties: excludedProperties,
                logError: true
            ),
            myBoolProperty: try container.decode(
                Bool.self,
                forKeys: [.myBoolProperty],
                defaultValue: nil,
                excludedProperties: excludedProperties,
                logError: true
            ),
            myStringProperty: try container.decode(
                String.self,
                forKeys: [.myStringProperty],
                defaultValue: nil,
                excludedProperties: excludedProperties,
                logError: true
            )
        )
        let entityMetadata = try FailableValue<VoidMetadata>(from: decoder).value()
        self.rootPayload = rootPayload
        self.entityMetadata = entityMetadata
    }
}

extension DefaultEndpointMyEntityPayload: PayloadIdentifierDecodableKeyProvider {

    static let identifierKey = MyEntityPayload.identifierKey
    var identifier: MyEntityIdentifier {
        return rootPayload.identifier
    }
}
