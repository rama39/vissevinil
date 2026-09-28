//
//  LocaisSalvosStore.swift
//  VisseVinil
//

import Foundation
import CoreLocation
import Observation

/*
 Locais que a pessoa guarda: favoritos, fixados e recentes (salvos no UserDefaults).
 Loja cadastrada é identificada pelo nome ("loja:<nome>"), porque a coordenada pode ser
 atualizada pela internet; local avulso, pela coordenada ("lat,lon").
*/
@MainActor
@Observable
final class LocaisSalvosStore {
    private enum Chave {
        static let favoritos = "favoritosSalvos"
        static let fixados = "fixadosSalvos"
        static let recentes = "recentesSalvos"
        // Versão antiga dos favoritos, que guardava só "lat,lon"
        static let favoritosAntigos = "coordenadasFavoritas"
    }

    let limiteDeRecentes = 15

    private(set) var favoritosSalvos: [LocalSalvo] = []
    private(set) var fixadosSalvos: [LocalSalvo] = []
    private(set) var recentes: [LocalSalvo] = []
    // Uma instância fixa pra cada local avulso favoritado e/ou fixado (a seleção do Map
    // compara pela identidade da Loja). Entram no cluster junto com as lojas.
    private(set) var locaisAvulsos: [Loja] = []

    /// Lojas cadastradas (vêm da @Query da tela); usadas pra montar as chaves
    var lojasCadastradas: [Loja] = []

    // MARK: - Consultas

    /// Lojas cadastradas + locais avulsos favoritados
    var favoritos: [Loja] {
        (lojasCadastradas + locaisAvulsos).filter(ehFavorito)
    }

    /// Lojas cadastradas + locais avulsos fixados
    var fixados: [Loja] {
        (lojasCadastradas + locaisAvulsos).filter(ehFixado)
    }

    var estaVazio: Bool {
        fixados.isEmpty && favoritos.isEmpty && recentes.isEmpty
    }

    func ehLojaCadastrada(_ loja: Loja) -> Bool {
        lojasCadastradas.contains(loja)
    }

    func ehLocalAvulsoSalvo(_ loja: Loja) -> Bool {
        locaisAvulsos.contains(loja)
    }

    func chave(para loja: Loja) -> String {
        ehLojaCadastrada(loja) ? "loja:\(loja.nameForSearch)" : "\(loja.latitude),\(loja.longitude)"
    }

    static func chave(de salvo: LocalSalvo) -> String {
        salvo.lojaID.map { "loja:\($0)" } ?? "\(salvo.latitude),\(salvo.longitude)"
    }

    func ehFavorito(_ loja: Loja) -> Bool {
        let chaveDaLoja = chave(para: loja)
        return favoritosSalvos.contains { Self.chave(de: $0) == chaveDaLoja }
    }

    func ehFixado(_ loja: Loja) -> Bool {
        let chaveDaLoja = chave(para: loja)
        return fixadosSalvos.contains { Self.chave(de: $0) == chaveDaLoja }
    }

    /// Recria uma Loja (não salva no SwiftData) a partir de um local salvo
    static func loja(de salvo: LocalSalvo) -> Loja {
        let loja = Loja(
            nameForSearch: salvo.nome,
            coordinate: CLLocationCoordinate2D(latitude: salvo.latitude, longitude: salvo.longitude)
        )
        loja.address = salvo.endereco
        return loja
    }

    // MARK: - Favoritos e fixados

    func alternarFavorito(_ loja: Loja) {
        alternar(loja, em: &favoritosSalvos)
        salvar(favoritosSalvos, em: Chave.favoritos)
        atualizarLocaisAvulsos(mudou: loja)
    }

    func alternarFixado(_ loja: Loja) {
        alternar(loja, em: &fixadosSalvos)
        salvar(fixadosSalvos, em: Chave.fixados)
        atualizarLocaisAvulsos(mudou: loja)
    }

    private func alternar(_ loja: Loja, em lista: inout [LocalSalvo]) {
        let chaveDaLoja = chave(para: loja)
        if lista.contains(where: { Self.chave(de: $0) == chaveDaLoja }) {
            lista.removeAll { Self.chave(de: $0) == chaveDaLoja }
        } else {
            lista.append(LocalSalvo(
                id: UUID(),
                nome: loja.officialName ?? loja.nameForSearch,
                latitude: loja.latitude,
                longitude: loja.longitude,
                endereco: loja.address,
                lojaID: ehLojaCadastrada(loja) ? loja.nameForSearch : nil
            ))
        }
    }

    // Mantém locaisAvulsos = avulsos que são favoritos e/ou fixados
    private func atualizarLocaisAvulsos(mudou loja: Loja) {
        guard !ehLojaCadastrada(loja) else { return }

        let deveFicar = ehFavorito(loja) || ehFixado(loja)
        if deveFicar, !locaisAvulsos.contains(loja) {
            // Usa a mesma instância que está selecionada, pro pin só mudar de visual
            locaisAvulsos.append(loja)
        } else if !deveFicar {
            // Se estiver selecionado, continua no mapa como local pesquisado
            locaisAvulsos.removeAll { $0 == loja }
        }
    }

    // MARK: - Recentes

    func registrarRecente(_ loja: Loja) {
        guard loja.latitude != 0, loja.longitude != 0 else { return }

        recentes.removeAll { $0.latitude == loja.latitude && $0.longitude == loja.longitude }
        recentes.insert(LocalSalvo(
            id: UUID(),
            nome: loja.nameForSearch,
            latitude: loja.latitude,
            longitude: loja.longitude,
            endereco: loja.address
        ), at: 0)

        if recentes.count > limiteDeRecentes {
            recentes.removeLast(recentes.count - limiteDeRecentes)
        }
        salvar(recentes, em: Chave.recentes)
    }

    func removerRecentes(em indices: IndexSet) {
        // Do fim pro começo, pra remover um não deslocar os índices dos outros
        for indice in indices.sorted(by: >) where recentes.indices.contains(indice) {
            recentes.remove(at: indice)
        }
        salvar(recentes, em: Chave.recentes)
    }

    func limparRecentes() {
        recentes.removeAll()
        salvar(recentes, em: Chave.recentes)
    }

    // MARK: - Carregamento

    func carregar() {
        recentes = carregarLista(de: Chave.recentes) ?? []

        if let salvos = carregarLista(de: Chave.favoritos) {
            favoritosSalvos = salvos
        } else {
            migrarFavoritosAntigos()
        }
        fixadosSalvos = carregarLista(de: Chave.fixados) ?? []

        // Favoritos/fixados salvos antes de existir lojaID: descobre pela coordenada se é loja
        if identificarLojas(em: &favoritosSalvos) { salvar(favoritosSalvos, em: Chave.favoritos) }
        if identificarLojas(em: &fixadosSalvos) { salvar(fixadosSalvos, em: Chave.fixados) }

        // Uma Loja fixa por local avulso (sem repetir quem é favorito E fixado)
        var vistos = Set<String>()
        locaisAvulsos = (favoritosSalvos + fixadosSalvos).compactMap { salvo in
            guard salvo.lojaID == nil, vistos.insert(Self.chave(de: salvo)).inserted else { return nil }
            return Self.loja(de: salvo)
        }
    }

    // Retorna true se alguma entrada foi atualizada
    private func identificarLojas(em lista: inout [LocalSalvo]) -> Bool {
        var mudou = false
        for indice in lista.indices where lista[indice].lojaID == nil {
            if let nome = CatalogoDeLojas.nomeDaLoja(latitude: lista[indice].latitude,
                                                     longitude: lista[indice].longitude) {
                lista[indice].lojaID = nome
                mudou = true
            }
        }
        return mudou
    }

    // Versão antiga guardava só "lat,lon"; recupera o nome pelo catálogo ou pelos recentes
    private func migrarFavoritosAntigos() {
        let antigas = UserDefaults.standard.stringArray(forKey: Chave.favoritosAntigos) ?? []
        guard !antigas.isEmpty else { return }

        favoritosSalvos = antigas.compactMap { chaveAntiga in
            let partes = chaveAntiga.split(separator: ",").compactMap { Double($0) }
            guard partes.count == 2 else { return nil }
            let nomeDaLoja = CatalogoDeLojas.nomeDaLoja(latitude: partes[0], longitude: partes[1])
            let recente = recentes.first { Self.chave(de: $0) == chaveAntiga }
            return LocalSalvo(
                id: UUID(),
                nome: nomeDaLoja ?? recente?.nome ?? "Local favorito",
                latitude: partes[0],
                longitude: partes[1],
                endereco: recente?.endereco,
                lojaID: nomeDaLoja
            )
        }
        salvar(favoritosSalvos, em: Chave.favoritos)
        UserDefaults.standard.removeObject(forKey: Chave.favoritosAntigos)
    }

    // MARK: - UserDefaults

    private func salvar(_ lista: [LocalSalvo], em chave: String) {
        if let dados = try? JSONEncoder().encode(lista) {
            UserDefaults.standard.set(dados, forKey: chave)
        }
    }

    private func carregarLista(de chave: String) -> [LocalSalvo]? {
        guard let dados = UserDefaults.standard.data(forKey: chave) else { return nil }
        return try? JSONDecoder().decode([LocalSalvo].self, from: dados)
    }
}
