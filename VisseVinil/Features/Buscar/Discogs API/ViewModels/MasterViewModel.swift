//
//  DiscogsMasterViewModel.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 17/09/26.
//

import SwiftUI

@Observable
class MasterViewModel {
    var master: MasterResponse? = nil
    var isLoading = false
    var errorMessage: String? = nil
    
    private func getDiscogsMasterRequest(
        id: Int
    ) -> URLRequest? {
        guard let url =
            URL(string: "https://api.discogs.com/masters/\(id)")
        else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func performRequest(request: URLRequest) async {
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
                    let decodedResponse =
                    try JSONDecoder().decode(MasterResponse.self, from: data)
                    self.master = decodedResponse
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
    }
    

    func requestMaster(
        id: Int
    ) async {
        
        guard let request = getDiscogsMasterRequest(id: id) else { return }
        
        self.isLoading = true
        self.errorMessage = nil
        
        await performRequest(request: request)
        
        self.isLoading = false
    }
}
