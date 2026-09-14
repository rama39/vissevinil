//
//  DiscogsViewModel.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 07/09/26.
//

import SwiftUI

@Observable
class DiscogsSearchViewModel {
    var releases: [DiscogsRelease] = []
    var isLoading = false
    var errorMessage: String? = nil
    
    private let personalAccessToken = "CEUvWbxdlZFYYLxbWqjzkGOQKbCEhHzHjJEHKFzE"
    private let userAgent = "VisseVinil/0.0 (iOS; SwiftUI)"
    
    private func getDiscogsRequest(query: String) -> URLRequest? {
        guard !query.isEmpty else { return nil }
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        
        let urlString =
        //"https://api.discogs.com/database/search?title=\(encodedQuery)&type=master&per_page=10&page=1"
        "https://api.discogs.com/database/search?q=\(encodedQuery)&type=master&format=vinyl&per_page=10&page=1"
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("Discogs token=\(personalAccessToken)", forHTTPHeaderField: "Authorization")
        
        return request
    }

    func searchVinyl(query: String) async throws {
        
        guard let request = getDiscogsRequest(query: query) else { return }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Valida o status HTTP do servidor
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            if httpResponse.statusCode == 200 {
                do {
                    let decodedResponse = try JSONDecoder().decode(DiscogsSearchResponse.self, from: data)
                    self.releases = decodedResponse.results
                } catch {
                    self.errorMessage = "Erro de mapeamento interno."
                    print("Erro ao decodificar sucesso: \(error)")
                }
            } else {
                do {
                    let errorResponse = try JSONDecoder().decode(DiscogsErrorResponse.self, from: data)
                    self.errorMessage = errorResponse.message
                } catch {
                    self.errorMessage = "Ocorreu um erro no servidor (Status \(httpResponse.statusCode))."
                    
                    print("Erro ao decodificar resposta de erro: \(error)")
                }
            }
        } catch {
            self.errorMessage = "Erro carregando discos"
        }
        
        self.isLoading = false
    }
}
