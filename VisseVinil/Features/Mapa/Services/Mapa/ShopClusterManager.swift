import SwiftUI
import MapKit
import Clusterables
import SwiftData

struct GroupOfShops: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let count: Int
    let lojas: [Loja]
}

@MainActor
@Observable
class ShopClusterManager {
    private let clusterManager = ClusterManager<Loja>()
    private var lojas: [Loja] = []
    private var idsForcadosASeparar: Set<PersistentIdentifier> = []
    // Loja selecionada: nunca entra em cluster, pra que o pin dela sempre apareça (e expanda)
    private var idDestacado: PersistentIdentifier?

    var visibleLojas: [Loja] = []
    var visibleGroups: [GroupOfShops] = []

    func setLojas(_ lojas: [Loja]) {
        self.lojas = lojas
    }

    func destacar(_ loja: Loja?) {
        idDestacado = loja?.persistentModelID
    }

    func forcarSeparacao(_ lojasDoGrupo: [Loja]) {
        for loja in lojasDoGrupo {
            idsForcadosASeparar.insert(loja.persistentModelID)
        }
    }
    
    private let distanciaLimiteParaLimpar: CLLocationDistance = 1500

    func limparForcadosSeAfastado(distanciaAtual: CLLocationDistance) {
        if distanciaAtual > distanciaLimiteParaLimpar {
            idsForcadosASeparar.removeAll()
        }
    }

    func updateClusters(mapProxy: MapProxy, spacingInPixels: Int = 60) async {
        guard let epsilon = mapProxy.degrees(fromPixels: spacingInPixels) else { return }

        let destacada = lojas.first { $0.persistentModelID == idDestacado }
        let lojasParaAgrupar = lojas.filter { $0.persistentModelID != idDestacado }

        await clusterManager.update(lojasParaAgrupar, epsilon: epsilon)

        var novasLojas: [Loja] = []
        var novosGrupos: [GroupOfShops] = []

        for cluster in clusterManager.clusters {
            let idsDoCluster = Set(cluster.items.map { $0.persistentModelID })

            if idsDoCluster.isSubset(of: idsForcadosASeparar) {
                novasLojas.append(contentsOf: cluster.items)
            } else if cluster.size == 1, let loja = cluster.items.first {
                novasLojas.append(loja)
            } else {
                novosGrupos.append(
                    GroupOfShops(id: UUID(), coordinate: cluster.center, count: cluster.size, lojas: cluster.items)
                )
            }
        }

        if let destacada {
            novasLojas.append(destacada)
        }

        withAnimation(.easeInOut(duration: 2.0)) {
            visibleLojas = novasLojas
            visibleGroups = novosGrupos
        }
    }
}
