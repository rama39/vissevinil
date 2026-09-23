//
//  Disco.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import Foundation
import SwiftData

//print("\(version)")
/*
 MasterVersion(
 status: Optional("Accepted"),
 stats: Optional(VisseVinil.MasterVersionStats(
    user: Optional(VisseVinil.MasterVersionCommunity(inCollection: Optional(0), inWantlist: Optional(0))),
    community: Optional(VisseVinil.MasterVersionCommunity(inCollection: Optional(43), inWantlist: Optional(19))))),
 thumb: Optional("https://i.discogs.com/SBPlqdE6COhiFSUfu1euX_2TCcpGl-MZIwaKhYEzf8c/rs:fit/g:sm/q:40/h:150/w:150/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTM4Mjk0/MzUtMTM0NjA1NTY4/OS04MzM5LmpwZWc.jpeg"),
 thumbData: Optional(4639 bytes),
 format: Optional(""),
 country: Optional("Australia"),
 title: Optional("Crystal Theatre"),
 label: Optional("Dot Dash"),
 released: Optional("2011"),
 majorFormats: Optional(["Vinyl"]),
 catno: Optional("DASH018LP"),
 resourceURL: Optional("https://api.discogs.com/releases/3829435"),
 id: 3829435)
 */
/*
 MasterResponse(
 styles: Optional(["Psychedelic Rock", "Indie Rock"]),
 genres: Optional(["Rock"]),
 videos: nil,
 title: Optional("Crystal Theatre"),
 mainRelease: Optional(3829435),
 mainReleaseURL: Optional("https://api.discogs.com/releases/3829435"),
 uri: Optional("https://www.discogs.com/master/962085-Belles-Will-Ring-Crystal-Theatre"),
 artists: Optional([
    VisseVinil.MasterArtist(join: Optional(""), name: Optional("Belles Will Ring"), anv: Optional(""), tracks: Optional(""), role: Optional(""), resourceURL: Optional("https://api.discogs.com/artists/677863"), id: Optional(677863))
 ]),
 versionsURL: Optional("https://api.discogs.com/masters/962085/versions"),
 year: Optional(2011),
 images: Optional([
    VisseVinil.MasterImage(height: Optional(500), resourceURL: Optional("https://i.discogs.com/wE9T4W_cLw7pU1s8Dvi1C1JklI9VLvP2SL6zvoej9iM/rs:fit/g:sm/q:90/h:500/w:500/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTM4Mjk0/MzUtMTM0NjA1NTY4/OS04MzM5LmpwZWc.jpeg"), type: Optional("secondary"), uri: Optional("https://i.discogs.com/wE9T4W_cLw7pU1s8Dvi1C1JklI9VLvP2SL6zvoej9iM/rs:fit/g:sm/q:90/h:500/w:500/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTM4Mjk0/MzUtMTM0NjA1NTY4/OS04MzM5LmpwZWc.jpeg"), uri150: Optional("https://i.discogs.com/SBPlqdE6COhiFSUfu1euX_2TCcpGl-MZIwaKhYEzf8c/rs:fit/g:sm/q:40/h:150/w:150/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTM4Mjk0/MzUtMTM0NjA1NTY4/OS04MzM5LmpwZWc.jpeg"), width: Optional(500))
 ]),
 resourceURL: Optional("https://api.discogs.com/masters/962085"),
 tracklist: Optional([
    VisseVinil.MasterTracklist(duration: Optional(""), position: Optional("A1"), type: Optional("track"), title: Optional("Crystal Theatre"), extraartists: nil),
    VisseVinil.MasterTracklist(duration: Optional(""), position: Optional("A2"), type: Optional("track"), title: Optional("Come To The Village"), extraartists: nil),
    VisseVinil.MasterTracklist(duration: Optional(""), position: Optional("A3"), type: Optional("track"), title: Optional("Trouble In Deepwater"), extraartists: nil),
    VisseVinil.MasterTracklist(duration: Optional(""), position: Optional("A4"), type: Optional("track"), title: Optional("Street Lamp Stomp"), extraartists: nil),
    VisseVinil.MasterTracklist(duration: Optional(""), position: Optional("A5"), type: Optional("track"), title: Optional("I Hear Your Voice On The Wind"), extraartists: nil),
    VisseVinil.MasterTracklist(duration: Optional(""), position: Optional("A6"), type: Optional("track"), title: Optional("Like A Boxer"), extraartists: nil),
    VisseVinil.MasterTracklist(duration: Optional(""), position: Optional("A7"), type: Optional("track"), title: Optional("Do You Know What I See?"), extraartists: nil),
    VisseVinil.MasterTracklist(duration: Optional(""), position: Optional("B1"), type: Optional("track"), title: Optional("Come North With Me Baby, Wow"), extraartists: nil),
    VisseVinil.MasterTracklist(duration: Optional(""), position: Optional("B2"), type: Optional("track"), title: Optional("Pallisade Alley"), extraartists: nil),
    VisseVinil.MasterTracklist(duration: Optional(""), position: Optional("B3"), type: Optional("track"), title: Optional("The Green"), extraartists: nil),
    VisseVinil.MasterTracklist(duration: Optional(""), position: Optional("B4"), type: Optional("track"), title: Optional("Bald Mountain"), extraartists: nil),
    VisseVinil.MasterTracklist(duration: Optional(""), position: Optional("B5"), type: Optional("track"), title: Optional("The River"), extraartists: nil),
    VisseVinil.MasterTracklist(duration: Optional(""), position: Optional("B6"), type: Optional("track"), title: Optional("Redwood Hill"), extraartists: nil)
 ]),
 id: Optional(962085),
 numForSale: Optional(9),
 lowestPrice: Optional(22.03),
 dataQuality: Optional("Correct"))
 */

@Model
final class _DiscoModel {
    
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
    
    // posicao na coleção
    var posicao: Int
    var curtido: Bool = false  // disco curtido, aparece primeir na busca
    var favorito: Bool = false // disco aparece no carrossel do perfil de favs
    var wishlist: Bool = false
    
    // relacionamentos
    @Relationship(deleteRule: .cascade, inverse: \EventoModel.disco)
    var eventos: [EventoModel] = []
    var caixa: CaixaModel?
    
    init(genres: [String]? = nil, styles: [String]? = nil, master_title: String?, mainRelease: Int? = nil, mainReleaseURL: String? = nil, uri: String? = nil, artists: [MasterArtist]? = nil, versionsURL: String? = nil, images: [MasterImage]? = nil, master_resourceURL: String? = nil, tracklist: [MasterTracklist]? = nil, master_id: Int?, numForSale: Int? = nil, lowestPrice: Double? = nil, dataQuality: String? = nil, status: String? = nil, community: MasterVersionCommunity? = nil, thumb: String? = nil, thumbData: Data? = nil, format: String? = nil, country: String? = nil, title: String? = nil, label: String? = nil, released: String? = nil, majorFormats: [String]? = nil, catno: String? = nil, resourceURL: String? = nil, id: Int, posicao: Int) {
        self.genres = genres
        self.styles = styles
        self.master_title = master_title
        self.mainRelease = mainRelease
        self.mainReleaseURL = mainReleaseURL
        self.uri = uri
        self.artists = artists
        self.versionsURL = versionsURL
        self.images = images
        self.master_resourceURL = master_resourceURL
        self.tracklist = tracklist
        self.master_id = master_id
        self.numForSale = numForSale
        self.lowestPrice = lowestPrice
        self.dataQuality = dataQuality
        
        self.status = status
        //self.stats = stats
        self.community = community
        self.thumb = thumb
        self.thumbData = thumbData
        self.format = format
        self.country = country ?? ""
        self.title = title ?? ""
        self.label = label
        self.released = released ?? ""
        self.majorFormats = majorFormats
        self.catno = catno
        self.resourceURL = resourceURL
        self.id = id
        
        self.posicao = posicao
    }
    convenience init(master: MasterResponse, version: MasterVersion, posicao: Int) {
        self.init(
            genres: master.genres,
            styles: master.styles,
            master_title: master.title,
            mainRelease: master.mainRelease,
            mainReleaseURL: master.mainReleaseURL,
            uri: master.uri,
            artists: master.artists,
            versionsURL: master.versionsURL,
            images: master.images,
            master_resourceURL: master.resourceURL,
            tracklist: master.tracklist,
            master_id: master.id,
            numForSale: master.numForSale,
            lowestPrice: master.lowestPrice,
            dataQuality: master.dataQuality,
            
            status: version.status,
            community: version.stats?.community,
            thumb: version.thumb,
            thumbData: version.thumbData,
            format: version.format,
            country: version.country,
            title: version.title,
            label: version.label,
            released: version.released,
            majorFormats: version.majorFormats,
            catno: version.catno,
            resourceURL: version.resourceURL,
            id: version.id,
            
            posicao: posicao
        )
    }
}
