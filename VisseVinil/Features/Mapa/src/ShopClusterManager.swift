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

    var visibleLojas: [Loja] = []
    var visibleGroups: [GroupOfShops] = []

    func setLojas(_ lojas: [Loja]) {
        self.lojas = lojas
    }

    func forcarSeparacao(_ lojasDoGrupo: [Loja]) {
        for loja in lojasDoGrupo {
            idsForcadosASeparar.insert(loja.persistentModelID)
        }
    }

    func updateClusters(mapProxy: MapProxy, spacingInPixels: Int = 60) async {
        guard let epsilon = mapProxy.degrees(fromPixels: spacingInPixels) else { return }

        await clusterManager.update(lojas, epsilon: epsilon)

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

        withAnimation(.easeInOut(duration: 2.0)) {
            visibleLojas = novasLojas
            visibleGroups = novosGrupos
        }
    }
}
