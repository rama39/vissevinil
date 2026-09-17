//
//  DiscogsMasterVersionResponse.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 17/09/26.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let discogsMasterVersionResponse = try? JSONDecoder().decode(DiscogsMasterVersionResponse.self, from: jsonData)

import Foundation

// MARK: - DiscogsMasterVersionResponse
struct DiscogsMasterVersionResponse: Codable {
    let pagination: MasterVersionPagination?
    let versions: [MasterVersionVersion]?

    enum CodingKeys: String, CodingKey {
        case pagination = "pagination"
        case versions = "versions"
    }
}

// MARK: - Pagination
struct MasterVersionPagination: Codable {
    let perPage: Int?
    let items: Int?
    let page: Int?
    let urls: MasterVersionUrls?
    let pages: Int?

    enum CodingKeys: String, CodingKey {
        case perPage = "per_page"
        case items = "items"
        case page = "page"
        case urls = "urls"
        case pages = "pages"
    }
}

// MARK: - Urls
struct MasterVersionUrls: Codable {
}

// MARK: - Version
struct MasterVersionVersion: Codable, Identifiable {
    let status: String?
    let stats: MasterVersionStats?
    let thumb: String?
    let format: String?
    let country: String?
    let title: String?
    let label: String?
    let released: String?
    let majorFormats: [String]?
    let catno: String?
    let resourceURL: String?
    let year: Int?
    let id: Int?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case stats = "stats"
        case thumb = "thumb"
        case format = "format"
        case country = "country"
        case title = "title"
        case label = "label"
        case released = "released"
        case majorFormats = "major_formats"
        case catno = "catno"
        case resourceURL = "resource_url"
        case year = "year"
        case id = "id"
    }
}

// MARK: - Stats
struct MasterVersionStats: Codable {
    let user: MasterVersionCommunity?
    let community: MasterVersionCommunity?

    enum CodingKeys: String, CodingKey {
        case user = "user"
        case community = "community"
    }
}

// MARK: - Community
struct MasterVersionCommunity: Codable {
    let inCollection: Int?
    let inWantlist: Int?

    enum CodingKeys: String, CodingKey {
        case inCollection = "in_collection"
        case inWantlist = "in_wantlist"
    }
}
