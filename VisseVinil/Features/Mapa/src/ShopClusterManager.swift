//
//  ShopClusterManager.swift
//  VisseVinil
//
//  Created by Gabriel Alves Gadelha de Melo on 22/09/26.
//

import SwiftUI
import SwiftData
import MapKit
import ClusterMap

//==================================================================
// Um tipo simples que vai ser chamado na View para ser desenhado
struct GroupOfShops: Identifiable {
    let id: ClusterManager<Loja>.ClusterAnnotation.ID
    let coordinate: CLLocationCoordinate2D
    let count: Int
}
//=================================================================

@MainActor
@Observable
class ShopClusterManager {
    private let clusterManager: ClusterManager<Loja>
    private var tarefaAtual: Task<Void, Never>?
    private var regiaoPendente: MKCoordinateRegion?

    var mapSize: CGSize = .zero
    var visibleLojas: [Loja] = []
    var visibleGroups: [GroupOfShops] = []

    func setLojas(_ lojas: [Loja]) async {
        await clusterManager.add(lojas)
    }
    
    init() {
        let configuracao = ClusterManager<Loja>.Configuration(
            clusterPosition: .average,
            cellSizeForZoomLevel: { _ in CGSize(width: 70, height: 70) }
        )
        clusterManager = ClusterManager<Loja>(configuration: configuracao)
    }
    
    func updateClusters(region: MKCoordinateRegion) {
        regiaoPendente = region

        guard tarefaAtual == nil else { return }

        tarefaAtual = Task {
            while let regiao = regiaoPendente {
                regiaoPendente = nil
                await processarAtualizacao(region: regiao)
            }
            tarefaAtual = nil
        }
    }

    private func processarAtualizacao(region: MKCoordinateRegion) async {
        let result = await clusterManager.reload(mapViewSize: mapSize, coordinateRegion: region)
        
        withAnimation(.easeInOut(duration: 2)) {
            for removal in result.removals {
                switch removal {
                case .annotation(let loja):
                    visibleLojas.removeAll { $0.persistentModelID == loja.persistentModelID }
                case .cluster(let group):
                    visibleGroups.removeAll { $0.id == group.id }
                }
            }
            
            for insertion in result.insertions {
                switch insertion {
                case .annotation(let loja):
                    visibleLojas.append(loja)
                case .cluster(let group):
                    visibleGroups.append(
                        GroupOfShops(id: group.id, coordinate: group.coordinate, count: group.memberAnnotations.count)
                    )
                }
            }
        }
    }
}
