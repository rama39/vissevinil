//
//  info.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 02/10/26.
//

let titleEstados: [EstadoCapa: String] = [
    .SemCapa: "Sem Capa",
    .Generica: "Genérica",
    .P: "Poor / Pobre (P)",
    .F: "Fair / Razoável (F)",
    .G: "Good / Boa (G)",
    .GP: "Good Plus / Mais que Boa (G+)",
    .VG: "Very Good / Muito Boa (VG)",
    .VGP: "Very Good Plus / Mais que Muito Boa (VG+)",
    .NM: "Near Mint / Quase _ (NM ou M-)",
    .M: "Mint / _ (M)"
]

let nomeEstados: [EstadoCapa: String] = [
    .SemCapa: "Sem Capa",
    .Generica: "Genérica",
    .P: "P",
    .F: "F",
    .G: "G",
    .GP: "G+",
    .VG: "VG",
    .VGP: "VG+",
    .NM: "NM",
    .M: "M"
]

let infoTextCapa: [EstadoCapa: String] = [
    .SemCapa: "Sem capa alguma. Disco solto",
    .Generica: "Capa diferente da original (mesmo que de outra versão do mesmo albúm)",
    .M: "Perfeita. Sem dobras ou rasgos.",
    .NM: "Praticamente nova. Sinais mínimos.",
    .VGP: "Excelente. Desgaste leve nos cantos.",
    .VG: "Marcas de uso, escritas ou etiquetas.",
    .GP: "Bordas gastas ou abertas e marcas de fita.",
    .G: "Muito desgastada. Grandes rasgos ou manchas.",
    .F: "Severamente danificada ou rasgada.",
    .P: "Destruída ou incompleta."
]

let infoTextDisco: [EstadoCapa: String] = [
    .M: "Impecável. Sem uso e sem marcas.",
    .NM: "Quase perfeito. Sem chiados.",
    .VGP: "Excelente. Marcas superficiais leves.",
    .VG: "Marcas visíveis e chiado leve (não pula).",
    .GP: "Desgastado. Chiados contínuos, mas audível.", 
    .G: "Muito usado. Ruído constante de fundo.",
    .F: "Mau estado. Riscos que fazem a agulha pular.",
    .P: "Danificado/Empenado. Inaudível."
]
