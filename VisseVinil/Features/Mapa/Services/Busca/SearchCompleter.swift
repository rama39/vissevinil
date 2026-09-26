//
//  SearchCompleter.swift
//  VisseVinil
//
//  Created by Gabriel Alves Gadelha de Melo on 25/09/26.
//

import Foundation
import MapKit

@MainActor
@Observable
class SearchCompleter: NSObject, MKLocalSearchCompleterDelegate {
    private let completer = MKLocalSearchCompleter()
    var sugestoes: [MKLocalSearchCompletion] = []

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.pointOfInterest, .address]
    }

    func atualizarRegiao(_ regiao: MKCoordinateRegion) {
        completer.region = regiao
    }

    func buscar(_ texto: String) {
        completer.queryFragment = texto
    }

    func limpar() {
        completer.queryFragment = ""
        sugestoes = []
    }

    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            sugestoes = completer.results
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor in
            sugestoes = []
        }
    }
}
