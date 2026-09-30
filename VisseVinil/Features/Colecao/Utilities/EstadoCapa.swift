//
//  Estado.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 30/09/26.
//

enum EstadoCapa: Int, Codable {
    case SemCapa = 0
    case Generica = 1
    case P = 2
    case F = 3
    case NM = 4
    case M = 5
    case G = 6
    case GP = 7
    case VG = 8
    case VGP = 9
}

let descricaoEstados: [EstadoCapa: String] = [
    .SemCapa: "Sem Capa",
    .Generica: "Genérica",
    .P: "Poor / Pobre (P)",
    .F: "Fair / Razoável (F)",
    .NM: "Near Mint / Quase _ (NM ou M-)",
    .M: "Mint / _ (M)",
    .G: "Good / Boa (G)",
    .GP: "Good Plus / Mais que Boa (G+)",
    .VG: "Very Good / Muito Boa (VG)",
    .VGP: "Very Good Plus / Mais que Muito Boa (VG+)"
]

let titleEstados: [EstadoCapa: String] = [
    .SemCapa: "Sem Capa",
    .Generica: "Genérica",
    .P: "P",
    .F: "F",
    .NM: "NM",
    .M: "M",
    .G: "G",
    .GP: "G+",
    .VG: "VG",
    .VGP: "VG+"
]
