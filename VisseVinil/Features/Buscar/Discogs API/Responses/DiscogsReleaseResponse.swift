//
//  DiscogsReleaseResponse.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 17/09/26.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let discogsReleaseResponse = try? JSONDecoder().decode(DiscogsReleaseResponse.self, from: jsonData)

import Foundation

// MARK: - DiscogsReleaseResponse
struct DiscogsReleaseResponse: Codable {
    let title: String?
    let id: Int?
    let artists: [ReleaseArtist]?
    let dataQuality: String?
    let thumb: String?
    let community: ReleaseCommunity?
    let companies: [ReleaseCompany]?
    let country: String?
    let dateAdded: Date?
    let dateChanged: Date?
    let estimatedWeight: Int?
    let extraartists: [ReleaseArtist]?
    let formatQuantity: Int?
    let formats: [ReleaseFormat]?
    let genres: [String]?
    let identifiers: [ReleaseIdentifier]?
    let images: [ReleaseImage]?
    let labels: [ReleaseCompany]?
    let lowestPrice: Double?
    let masterID: Int?
    let masterURL: String?
    let notes: String?
    let numForSale: Int?
    let released: String?
    let releasedFormatted: String?
    let resourceURL: String?
    let series: [JSONAny]?
    let status: String?
    let styles: [String]?
    let tracklist: [ReleaseTracklist]?
    let uri: String?
    let videos: [ReleaseVideo]?
    let year: Int?

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case id = "id"
        case artists = "artists"
        case dataQuality = "data_quality"
        case thumb = "thumb"
        case community = "community"
        case companies = "companies"
        case country = "country"
        case dateAdded = "date_added"
        case dateChanged = "date_changed"
        case estimatedWeight = "estimated_weight"
        case extraartists = "extraartists"
        case formatQuantity = "format_quantity"
        case formats = "formats"
        case genres = "genres"
        case identifiers = "identifiers"
        case images = "images"
        case labels = "labels"
        case lowestPrice = "lowest_price"
        case masterID = "master_id"
        case masterURL = "master_url"
        case notes = "notes"
        case numForSale = "num_for_sale"
        case released = "released"
        case releasedFormatted = "released_formatted"
        case resourceURL = "resource_url"
        case series = "series"
        case status = "status"
        case styles = "styles"
        case tracklist = "tracklist"
        case uri = "uri"
        case videos = "videos"
        case year = "year"
    }
}

// MARK: - Artist
struct ReleaseArtist: Codable {
    let anv: String?
    let id: Int?
    let join: String?
    let name: String?
    let resourceURL: String?
    let role: String?
    let tracks: String?

    enum CodingKeys: String, CodingKey {
        case anv = "anv"
        case id = "id"
        case join = "join"
        case name = "name"
        case resourceURL = "resource_url"
        case role = "role"
        case tracks = "tracks"
    }
}

// MARK: - Community
struct ReleaseCommunity: Codable {
    let contributors: [ReleaseSubmitter]?
    let dataQuality: String?
    let have: Int?
    let rating: ReleaseRating?
    let status: String?
    let submitter: ReleaseSubmitter?
    let want: Int?

    enum CodingKeys: String, CodingKey {
        case contributors = "contributors"
        case dataQuality = "data_quality"
        case have = "have"
        case rating = "rating"
        case status = "status"
        case submitter = "submitter"
        case want = "want"
    }
}

// MARK: - Submitter
struct ReleaseSubmitter: Codable {
    let resourceURL: String?
    let username: String?

    enum CodingKeys: String, CodingKey {
        case resourceURL = "resource_url"
        case username = "username"
    }
}

// MARK: - Rating
struct ReleaseRating: Codable {
    let average: Double?
    let count: Int?

    enum CodingKeys: String, CodingKey {
        case average = "average"
        case count = "count"
    }
}

// MARK: - Company
struct ReleaseCompany: Codable {
    let catno: String?
    let entityType: String?
    let entityTypeName: String?
    let id: Int?
    let name: String?
    let resourceURL: String?

    enum CodingKeys: String, CodingKey {
        case catno = "catno"
        case entityType = "entity_type"
        case entityTypeName = "entity_type_name"
        case id = "id"
        case name = "name"
        case resourceURL = "resource_url"
    }
}

// MARK: - Format
struct ReleaseFormat: Codable {
    let descriptions: [String]?
    let name: String?
    let qty: String?

    enum CodingKeys: String, CodingKey {
        case descriptions = "descriptions"
        case name = "name"
        case qty = "qty"
    }
}

// MARK: - Identifier
struct ReleaseIdentifier: Codable {
    let type: String?
    let value: String?

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case value = "value"
    }
}

// MARK: - Image
struct ReleaseImage: Codable {
    let height: Int?
    let resourceURL: String?
    let type: String?
    let uri: String?
    let uri150: String?
    let width: Int?

    enum CodingKeys: String, CodingKey {
        case height = "height"
        case resourceURL = "resource_url"
        case type = "type"
        case uri = "uri"
        case uri150 = "uri150"
        case width = "width"
    }
}

// MARK: - Tracklist
struct ReleaseTracklist: Codable {
    let duration: String?
    let position: String?
    let title: String?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case duration = "duration"
        case position = "position"
        case title = "title"
        case type = "type_"
    }
}

// MARK: - Video
struct ReleaseVideo: Codable {
    let description: String?
    let duration: Int?
    let embed: Bool?
    let title: String?
    let uri: String?

    enum CodingKeys: String, CodingKey {
        case description = "description"
        case duration = "duration"
        case embed = "embed"
        case title = "title"
        case uri = "uri"
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public func hash(into hasher: inout Hasher) {
        // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

class JSONAny: Codable {

    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}
