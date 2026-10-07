//
//  CacheDeCapas.swift
//  VisseVinil
//

import UIKit

/// Capa grande do disco (Discogs), guardada em memória pra não baixar de novo a cada rolagem.
/// A miniatura salva no disco (thumbData) tem só 150 px e fica borrada em capas grandes.
/// Usada na caixa (folhear) e no carrossel de favoritos do Perfil.
@MainActor
enum CacheDeCapas {
    private static let cache = NSCache<NSURL, UIImage>()

    static func imagemGrande(de disco: DiscoModel) async -> UIImage? {
        guard let url = urlDaImagemGrande(de: disco) else { return nil }
        if let guardada = cache.object(forKey: url as NSURL) {
            return guardada
        }
        guard let (dados, _) = try? await URLSession.shared.data(from: url),
              let imagem = UIImage(data: dados) else { return nil }
        cache.setObject(imagem, forKey: url as NSURL)
        return imagem
    }

    // Capa principal do disco no Discogs (a "primary"), na maior resolução disponível
    private static func urlDaImagemGrande(de disco: DiscoModel) -> URL? {
        let imagens = disco.images ?? []
        let principal = imagens.first { $0.type == "primary" } ?? imagens.first
        return (principal?.uri ?? principal?.resourceURL).flatMap(URL.init(string:))
    }
}
