//
//  WishlistModel.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 01/10/26.
//

import Foundation
import SwiftData

@Model
final class WishlistModel {
    
    // MARK: - version data
    var status: String?
    // let stats: MasterVersionStats? <- removed user stats (my stats)
    var community: MasterVersionCommunity?
    var thumb: String?
    @Attribute(.externalStorage) var thumbData: Data? // not in response, added later if let thumb
    var format: String?
    var country: String
    var title: String
    var label: String?
    var released: String
    var majorFormats: [String]?
    var catno: String?
    var resourceURL: String?
    var id: Int
    
    init(version: MasterVersion) {
        self.status = version.status
        self.community = version.stats?.community
        self.thumb = version.thumb
        self.thumbData = version.thumbData
        self.format = version.format
        self.country = version.country ?? ""
        self.title = version.title ?? ""
        self.label = version.label
        self.released = version.released ?? ""
        self.majorFormats = version.majorFormats
        self.catno = version.catno
        self.resourceURL = version.resourceURL
        self.id = version.id
    }
}
