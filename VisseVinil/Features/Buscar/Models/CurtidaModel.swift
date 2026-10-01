//
//  CurtidaModel.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 01/10/26.
//

import Foundation
import SwiftData

@Model
final class CurtidaModel {
    
    // MARK: - master data
    var genres: [String]?
    var styles: [String]?
    var master_title: String?
    var mainRelease: Int?
    var mainReleaseURL: String?
    var uri: String?
    var artists: [MasterArtist]?
    var versionsURL: String?
    var images: [MasterImage]?
    var master_resourceURL: String?
    var tracklist: [MasterTracklist]?
    var master_id: Int?
    var numForSale: Int?
    var lowestPrice: Double?
    var dataQuality: String?
    
    var artistsListed: String { (artists ?? []).map{$0.name ?? ""}.joined(separator: ", ")}
    var genresListed: String { (genres ?? []).joined(separator: ", ")}
    var stylesListed: String { (styles ?? []).joined(separator: ", ")}
    
    init(master: MasterResponse) {
        self.genres = master.genres
        self.styles = master.styles
        self.master_title = master.title
        self.mainRelease = master.mainRelease
        self.mainReleaseURL = master.mainReleaseURL
        self.uri = master.uri
        self.artists = master.artists
        self.versionsURL = master.versionsURL
        self.images = master.images
        self.master_resourceURL = master.resourceURL
        self.tracklist = master.tracklist
        self.master_id = master.id
        self.numForSale = master.numForSale
        self.lowestPrice = master.lowestPrice
        self.dataQuality = master.dataQuality
    }
}
