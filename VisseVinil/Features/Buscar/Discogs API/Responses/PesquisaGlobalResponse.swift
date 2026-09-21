//
//  DiscogsSearchResponse.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 07/09/26.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let discogsSearchResponse = try? JSONDecoder().decode(DiscogsSearchResponse.self, from: jsonData)

import Foundation

// MARK: - DiscogsSearchResponse
/// Response do endpoint search do Discogs
struct PesquisaGlobalResponse: Codable {
    let pagination: SearchPagination
    let results: [DiscogsRelease]

    enum CodingKeys: String, CodingKey {
        case pagination = "pagination"
        case results = "results"
    }
}

// MARK: - Pagination
struct SearchPagination: Codable {
    let perPage: Int
    let pages: Int
    let page: Int
    let urls: Urls
    let items: Int

    enum CodingKeys: String, CodingKey {
        case perPage = "per_page"
        case pages = "pages"
        case page = "page"
        case urls = "urls"
        case items = "items"
    }
}

// MARK: - Urls
struct Urls: Codable {
    let last: String
    let next: String

    enum CodingKeys: String, CodingKey {
        case last = "last"
        case next = "next"
    }
}

// MARK: - DiscogsRelease
struct DiscogsRelease: Codable, Identifiable {
    let style: [String]?
    let thumb: String?
    let title: String?
    let country: String?
    let format: [String]?
    let uri: String?
    let community: Community?
    let label: [String]?
    let catno: String?
    let year: String?
    let genre: [String]?
    let resourceURL: String?
    let type: String?
    let id: Int
    let barcode: [String]?

    enum CodingKeys: String, CodingKey {
        case style = "style"
        case thumb = "thumb"
        case title = "title"
        case country = "country"
        case format = "format"
        case uri = "uri"
        case community = "community"
        case label = "label"
        case catno = "catno"
        case year = "year"
        case genre = "genre"
        case resourceURL = "resource_url"
        case type = "type"
        case id = "id"
        case barcode = "barcode"
    }
}

// MARK: - Community
struct Community: Codable {
    let want: Int
    let have: Int

    enum CodingKeys: String, CodingKey {
        case want = "want"
        case have = "have"
    }
}
