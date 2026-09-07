//
//  DiscogsViewModel.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 07/09/26.
//

import SwiftUI
import SwiftData

@Observable
class DiscogsViewModel {
    var releases: [DiscogsRelease] = []
    var isLoading = false
    var errorMessage: String? = nil
    
    private let personalAccessToken = "CEUvWbxdlZFYYLxbWqjzkGOQKbCEhHzHjJEHKFzE"
    private let userAgent = "VisseVinil/0.0 (iOS; SwiftUI)"

    func searchVinyl(query: String) async throws {
        guard !query.isEmpty else { return }
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        let urlString =
        //"https://discogs.com\(encodedQuery)&format=vinyl&per_page=25"
        //"https://api.discogs.com\(encodedQuery)&format=vinyl&per_page=25"
        //"https://api.discogs.com/database/search?release_title=nevermind&per_page=3&page=1"
        //"https://api.discogs.com/database/search?release_title=nevermind&artist=nirvana&per_page=3&page=1"
        "https://api.discogs.com/database/search?release_title=\(encodedQuery)&per_page=3&page=1"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("Discogs token=\(personalAccessToken)", forHTTPHeaderField: "Authorization")
        
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
