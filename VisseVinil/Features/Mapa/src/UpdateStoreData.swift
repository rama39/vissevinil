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
    
    func updade(_ loja: Loja) async {
        /*
        --------------------------------------------------------------
        Para evitar que seja feita uma pesquisa toda vez que o app é
        aberto, vamos atualizar apenas de 20 em 20 dias.
        --------------------------------------------------------------
        */
        
        //==========================================================================
        // Preparação para a pesquisa
        
        // Se a última atualização foi anterior a 20 dias, não faz nada
        if let ultima = loja.lastUpdate,
            Date().timeIntervalSince(ultima) < 60 * 60 * 24 * 20 { return }

        // Monta o "formulário de busca" do MapKit
        let request = MKLocalSearch.Request()
        // "Escreve" o nome na busca
        request.naturalLanguageQuery = loja.nameForSearch
        // Dá um "viés geográfico" pra busca, limitando o espaço 200mx200m
        request.region = MKCoordinateRegion(
            center: loja.coordinate,
            latitudinalMeters: 200,
            longitudinalMeters: 200
        )
        //==========================================================================
        // Inicialização + Pesquisa
        let search = MKLocalSearch(request: request)

        do {
            
            // Envia a pesquisa, aguarda, mas não trava o app (await)
            let answer = try await search.start()
            // Pega o primeiro resultado encontrado na lista de resultados
            // Se tiver vazia, sai da função sem alterar a loja
            guard let item = answer.mapItems.first else { return }
            // Usa o resultado pra preencher os campos da loja
            write(loja, com: item)
            // Caso a busca não tenha dado nenhum erro, atualiza
            loja.lastUpdate = Date()
            
        } catch {
            // Se algo falhar, só loga no console.
            print("Erro ao buscar \(loja.nameForSearch): \(error)")
        }
        
        //==========================================================================
    }
    
    //=======================================================================================
    // Função auxiliar para organizar os dados
    /**
     ==========================================================================
      Pega o item encontrado (MKMapItem) e copia cada informação pra o objeto loja em questão.
     ==========================================================================
    */
    private func write(_ loja: Loja, com item: MKMapItem) {
        loja.officialName = item.name
        loja.category = item.pointOfInterestCategory?.rawValue
        loja.fone = item.phoneNumber
        loja.website = item.url?.absoluteString
        // Endereço já vem formatado como texto único, API atual não separa
        loja.address = item.address?.fullAddress
    }
    //=======================================================================================
}
