//
//  DiscogsMasterViewModel.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 17/09/26.
//

import SwiftUI

@Observable
class DiscogsMasterViewModel {
    var master: DiscogsMasterResponse? = nil
    //var masterversion: DiscogsMasterVersionResponse? = nil
    var isLoading = false
    var errorMessage: String? = nil
    
    private let personalAccessToken = "zdAKBXOdFlUYuBVvMALPDcuQjKZoEDvvudzmwLYm"
    private let userAgent = "VisseVinil/0.0 (iOS; SwiftUI)"
    
    private func getDiscogsMasterRequest(
        id: Int
    ) -> URLRequest? {
        guard let url =
            URL(string: "https://api.discogs.com/masters/\(id)")
        else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("Discogs token=\(personalAccessToken)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func getMaster(request: URLRequest) async {
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
                    try JSONDecoder().decode(DiscogsMasterResponse.self, from: data)
                    self.master = decodedResponse
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
            self.errorMessage = "Erro carregando disco"
        }
    }
    
//    private func getDiscogsMasterVersionRequest(
//        id: Int
//    ) -> URLRequest? {
//        guard let url =
//            URL(string: "https://api.discogs.com/masters/\(id)/versions?format=Vinyl&sort=released&sort_order=asc&per_page=50&page=1")
//        else { return nil }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
//        request.setValue("Discogs token=\(personalAccessToken)", forHTTPHeaderField: "Authorization")
//        
//        return request
//    }
    
    /*private func getMasterVersion(request: URLRequest) async {
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
                    try JSONDecoder().decode(DiscogsMasterVersionResponse.self, from: data)
                    self.masterversion = decodedResponse
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
            self.errorMessage = "Erro carregando disco"
        }
    } */

    func requestVinyl(
        id: Int
    ) async {
        
        guard let request =
                getDiscogsMasterRequest(id: id) else { return }
        
        self.isLoading = true
        self.errorMessage = nil
        
        await getMaster(request: request)
        
//        guard let versionRequest =
//                getDiscogsMasterVersionRequest(id: id) else { return }
//        
//        await getMasterVersion(request: versionRequest)
        
        self.isLoading = false
    }
}
