//
//  SincronizacaoDeLojas.swift
//  VisseVinil
//

import SwiftData

/// Mantém as lojas do SwiftData em dia com o catálogo e com a internet.
@MainActor
enum SincronizacaoDeLojas {
    /// Grava no SwiftData as lojas do catálogo que ainda não estão lá (e remove as que saíram)
    static func sincronizarCatalogo(em contexto: ModelContext) {
        let existentes = (try? contexto.fetch(FetchDescriptor<Loja>())) ?? []
        let nomesDoCatalogo = Set(CatalogoDeLojas.itens.map(\.nome))
        var nomesGravados = Set<String>()

        for loja in existentes {
            // Remove lojas que saíram do catálogo e duplicadas
            if !nomesDoCatalogo.contains(loja.nameForSearch) || !nomesGravados.insert(loja.nameForSearch).inserted {
                contexto.delete(loja)
            }
        }

        for item in CatalogoDeLojas.itens where !nomesGravados.contains(item.nome) {
            contexto.insert(Loja(nameForSearch: item.nome, coordinate: item.coordenada))
        }

        // Salva já: o ID de um objeto recém-inserido é temporário e muda no save, o que
        // quebraria a seleção e os clusters (Loja é comparada pelo persistentModelID)
        try? contexto.save()
    }

    /// Busca na internet as lojas não atualizadas há 20 dias (coordenada, nome, contato...).
    /// Retorna true se alguma loja mudou.
    static func atualizarPelaInternet(em contexto: ModelContext) async -> Bool {
        let busca = StoreSearch()
        let referencias = CatalogoDeLojas.referencias
        // Busca direto no contexto: na primeira abertura a @Query da tela ainda pode estar vazia
        let lojasGravadas = (try? contexto.fetch(FetchDescriptor<Loja>())) ?? []

        var mudouAlgo = false
        for loja in lojasGravadas {
            guard let referencia = referencias[loja.nameForSearch] else { continue }
            if await busca.atualizar(loja, referencia: referencia) {
                mudouAlgo = true
            }
        }

        if mudouAlgo {
            try? contexto.save()
        }
        return mudouAlgo
    }
}
