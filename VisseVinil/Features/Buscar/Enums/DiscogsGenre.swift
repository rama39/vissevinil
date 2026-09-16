//
//  DiscogsGenre.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 15/09/26.
//

import Foundation
/// The fixed set of top-level genres used by Discogs.
/// Source:
/// https://support.discogs.com/hc/en-us/articles/360005055213-Database-Guidelines-9-Genres-Styles
enum DiscogsGenre: String, CaseIterable, Codable, Identifiable {
    case rock = "Rock"
    case electronic = "Electronic"
    case pop = "Pop"
    case hipHop = "Hip-Hop"
    case jazz = "Jazz"
    case funkSoul = "Funk / Soul"
    case latin = "Latin"
    case folkWorldCountry = "Folk, World, & Country"
    case reggae = "Reggae"
    case classical = "Classical"
    case blues = "Blues"
    case nonMusic = "Non-Music"
    case stageAndScreen = "Stage & Screen"
    case brassAndMilitary = "Brass & Military"
    case childrens = "Children's"

    var id: String { rawValue }
}

