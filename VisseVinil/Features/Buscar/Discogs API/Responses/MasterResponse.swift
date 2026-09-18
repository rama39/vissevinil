//
//  DiscogsMasterResponse.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 17/09/26.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let discogsMasterResponse = try? JSONDecoder().decode(DiscogsMasterResponse.self, from: jsonData)

import Foundation

// MARK: - DiscogsMasterResponse
struct MasterResponse: Codable, Identifiable {
    let styles: [String]?
    let genres: [String]?
    let videos: [MasterVideo]?
    let title: String?
    let mainRelease: Int?
    let mainReleaseURL: String?
    let uri: String?
    let artists: [MasterArtist]?
    let versionsURL: String?
    let year: Int?
    let images: [MasterImage]?
    let resourceURL: String?
    let tracklist: [MasterTracklist]?
    let id: Int?
    let numForSale: Int?
    let lowestPrice: Double?
    let dataQuality: String?

    enum CodingKeys: String, CodingKey {
        case styles = "styles"
        case genres = "genres"
        case videos = "videos"
        case title = "title"
        case mainRelease = "main_release"
        case mainReleaseURL = "main_release_url"
        case uri = "uri"
        case artists = "artists"
        case versionsURL = "versions_url"
        case year = "year"
        case images = "images"
        case resourceURL = "resource_url"
        case tracklist = "tracklist"
        case id = "id"
        case numForSale = "num_for_sale"
        case lowestPrice = "lowest_price"
        case dataQuality = "data_quality"
    }
}

// MARK: - Artist
struct MasterArtist: Codable {
    let join: String?
    let name: String?
    let anv: String?
    let tracks: String?
    let role: String?
    let resourceURL: String?
    let id: Int?

    enum CodingKeys: String, CodingKey {
        case join = "join"
        case name = "name"
        case anv = "anv"
        case tracks = "tracks"
        case role = "role"
        case resourceURL = "resource_url"
        case id = "id"
    }
}

// MARK: - Image
struct MasterImage: Codable {
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
struct MasterTracklist: Codable {
    let duration: String?
    let position: String?
    let type: String?
    let title: String?
    let extraartists: [MasterArtist]?

    enum CodingKeys: String, CodingKey {
        case duration = "duration"
        case position = "position"
        case type = "type_"
        case title = "title"
        case extraartists = "extraartists"
    }
}

// MARK: - Video
struct MasterVideo: Codable {
    let duration: Int?
    let description: String?
    let embed: Bool?
    let uri: String?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case duration = "duration"
        case description = "description"
        case embed = "embed"
        case uri = "uri"
        case title = "title"
    }
}
