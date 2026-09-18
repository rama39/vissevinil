//
//  DiscogsReleaseViewModel.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 07/09/26.
//

import SwiftUI

/// Deprecated. Prefer use of MasterViewModel to display
@Observable
class _ReleaseViewModel {
    var release: _ReleaseResponse? = nil
    var isLoading = false
    var errorMessage: String? = nil
    
    private let personalAccessToken = "zdAKBXOdFlUYuBVvMALPDcuQjKZoEDvvudzmwLYm"
    private let userAgent = "VisseVinil/0.0 (iOS; SwiftUI)"
    
    private func getDiscogsRequest(
        id: Int
    ) -> URLRequest? {
        guard let url =
            URL(string: "https://api.discogs.com/releases/\(id)?curr_abbr=BRL")
        else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("Discogs token=\(personalAccessToken)", forHTTPHeaderField: "Authorization")
        
        return request
    }

    func requestVinyl(
        id: Int
    ) async {
        
        guard let request =
            getDiscogsRequest(id: id) else { return }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Valida o status HTTP do servidor
            guard let httpResponse = response as? HTTPURLResponse else {
                self.errorMessage = "Resposta inválida do servidor."
                self.isLoading = false
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let decodedResponse = try JSONDecoder().decode(_ReleaseResponse.self, from: data)
                    self.release = decodedResponse
                } catch {
                    self.errorMessage = "Erro de mapeamento interno."
                    print("Erro ao decodificar sucesso: \(error)")
                }
            } else {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    self.errorMessage = errorResponse.message
                } catch {
                    self.errorMessage = "Ocorreu um erro no servidor (Status \(httpResponse.statusCode))."
                    
                    print("Erro ao decodificar resposta de erro: \(error)")
                }
            }
        } catch {
            self.errorMessage = "Erro carregando disco"
        }
        
        self.isLoading = false
    }
}
