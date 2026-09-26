//
//  UpdateStoreData.swift
//  VisseVinil
//
//  Created by Gabriel Alves Gadelha de Melo on 17/09/26.
//

import MapKit

@MainActor
class StoreSearch {
    
    //========================================================================
    /*
     ------------------------------------------------------------------------
     "_" evita redundâncias quando chamar a função, e o "async" avisa que
     essa função pode demorar para terminar e não deve travar o app por isso.
     ------------------------------------------------------------------------
    */
    
    // A cada quantos dias as informações de uma loja são buscadas de novo
    private let intervaloEntreAtualizacoes: TimeInterval = 60 * 60 * 24 * 20
    // Resultado mais longe que isso da posição cadastrada provavelmente é outro lugar
    private let distanciaMaximaAceita: CLLocationDistance = 300

    /**
     Busca a loja no Apple Maps e atualiza as informações (inclusive coordenada e nome oficial).
     - referencia: coordenada cadastrada à mão; o resultado só é aceito se estiver perto dela,
       pra atualizações seguidas não irem "arrastando" o pin pra longe.
     - Retorna true se algo mudou na loja (inclusive só a data da última verificação).
    */
    @discardableResult
    func atualizar(_ loja: Loja, referencia: CLLocationCoordinate2D) async -> Bool {
        //==========================================================================
        // Preparação para a pesquisa

        // Se a última atualização foi há menos de 20 dias, não faz nada
        if let ultima = loja.lastUpdate,
           Date().timeIntervalSince(ultima) < intervaloEntreAtualizacoes { return false }

        // Monta o "formulário de busca" do MapKit
        let request = MKLocalSearch.Request()
        // "Escreve" o nome na busca
        request.naturalLanguageQuery = loja.nameForSearch
        request.resultTypes = .pointOfInterest
        // Dá um "viés geográfico" pra busca em volta da posição cadastrada
        // (é só uma preferência, não um filtro; a validação de verdade é em melhorResultado)
        request.region = MKCoordinateRegion(
            center: referencia,
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        )
        //==========================================================================
        // Inicialização + Pesquisa
        let search = MKLocalSearch(request: request)

        do {
            // Envia a pesquisa, aguarda, mas não trava o app (await)
            let answer = try await search.start()
            // A busca funcionou: marca como verificada, mesmo sem resultado confiável,
            // pra não repetir a cada abertura do app
            loja.lastUpdate = Date()

            // Só usa um resultado com o mesmo nome e perto da posição cadastrada;
            // pegar o primeiro da lista às vezes traz outro lugar e moveria o pin
            if let item = melhorResultado(para: loja, referencia: referencia, em: answer.mapItems) {
                write(loja, com: item)
            }
            return true
        } catch {
            // Se algo falhar (ex: sem internet), só loga e tenta de novo na próxima abertura
            print("Erro ao buscar \(loja.nameForSearch): \(error)")
            return false
        }
        //==========================================================================
    }

    private func melhorResultado(para loja: Loja, referencia: CLLocationCoordinate2D, em itens: [MKMapItem]) -> MKMapItem? {
        let posicao = CLLocation(latitude: referencia.latitude, longitude: referencia.longitude)

        return itens
            .filter { item in
                let nomeBate = (item.name ?? "").pareceONomeDe(loja.nameForSearch)
                return nomeBate && item.location.distance(from: posicao) <= distanciaMaximaAceita
            }
            .min { $0.location.distance(from: posicao) < $1.location.distance(from: posicao) }
    }
    
    //=======================================================================================
    // Função auxiliar para organizar os dados
    /**
     ==========================================================================
      Pega o item encontrado (MKMapItem) e copia cada informação pra o objeto loja em questão.
     ==========================================================================
    */
    private func write(_ loja: Loja, com item: MKMapItem) {
        // nameForSearch fica como está (é o identificador da loja); o nome oficial vai aqui
        loja.officialName = item.name
        loja.category = item.pointOfInterestCategory?.rawValue
        loja.fone = item.phoneNumber
        loja.website = item.url?.absoluteString
        // Endereço já vem formatado como texto único, API atual não separa
        loja.address = item.address?.fullAddress
        loja.latitude = item.location.coordinate.latitude
        loja.longitude = item.location.coordinate.longitude
    }
    //=======================================================================================
}
