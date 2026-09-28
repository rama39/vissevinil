import Foundation
import SwiftData
import CoreLocation
import Clusterables

@Model
class Loja {
    var nameForSearch: String
    var latitude: Double
    var longitude: Double

    var officialName: String?
    var category: String?
    var address: String?
    var fone: String?
    var website: String?

    // Endereço em partes (seção "Detalhes" da sheet)
    var rua: String?
    var numero: String?
    var bairro: String?
    var cidade: String?
    var estado: String?
    var cep: String?
    var pais: String?

    var lastUpdate: Date?
    var ig: String?
    var favorito: Bool = false

    init(nameForSearch: String, coordinate: CLLocationCoordinate2D, ig: String? = nil) {
        self.nameForSearch = nameForSearch
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.ig = ig
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Loja: Clusterable {}

extension Loja: Hashable {
    static func == (lhs: Loja, rhs: Loja) -> Bool {
        lhs.persistentModelID == rhs.persistentModelID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(persistentModelID)
    }
}

extension Loja: @unchecked Sendable {}
