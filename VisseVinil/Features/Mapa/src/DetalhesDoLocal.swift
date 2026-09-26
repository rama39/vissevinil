//
//  DetalhesDoLocal.swift
//  VisseVinil
//

import MapKit

extension Loja {
    /// Tem rua/cidade separadas? (se não, a sheet busca pela coordenada)
    var temEnderecoDetalhado: Bool {
        rua != nil || cidade != nil
    }

    /*
     Preenche o endereço em partes a partir de um resultado do MapKit.
     No iOS 26 o MKMapItem novo (address/addressRepresentations) só entrega o endereço como
     texto único + cidade/estado. Rua, número e CEP separados só existem no placemark antigo,
     que foi descontinuado mas continua funcionando; ele é lido por KVC pra não gerar aviso
     de descontinuação no build.
    */
    func preencherEndereco(com item: MKMapItem) {
        let marcador = item.value(forKey: "placemark") as? CLPlacemark

        rua = marcador?.thoroughfare ?? rua
        numero = marcador?.subThoroughfare ?? numero
        bairro = marcador?.subLocality ?? bairro
        cidade = marcador?.locality ?? item.addressRepresentations?.cityName ?? cidade
        estado = marcador?.administrativeArea ?? item.addressRepresentations?.regionName ?? estado
        cep = marcador?.postalCode ?? cep
        pais = marcador?.country ?? pais
        address = item.address?.fullAddress ?? address
    }

    /// Busca o endereço pela coordenada (geocodificação reversa) quando ainda não temos.
    func buscarEnderecoSeFaltar() async {
        guard !temEnderecoDetalhado,
              let pedido = MKReverseGeocodingRequest(location: CLLocation(latitude: latitude, longitude: longitude)),
              let item = try? await pedido.mapItems.first
        else { return }
        preencherEndereco(com: item)
    }
}

enum CategoriaDoLocal {
    /// Nome em português da categoria do Apple Maps (ex: "MKPOICategoryCafe" -> "Café")
    static func nome(para valorBruto: String?, ehLojaCadastrada: Bool) -> String {
        guard let valorBruto else {
            return ehLojaCadastrada ? "Loja de discos" : "Local"
        }
        let nomes: [MKPointOfInterestCategory: String] = [
            .store: "Loja",
            .musicVenue: "Casa de shows",
            .cafe: "Café",
            .restaurant: "Restaurante",
            .bakery: "Padaria",
            .brewery: "Cervejaria",
            .winery: "Vinícola",
            .nightlife: "Vida noturna",
            .theater: "Teatro",
            .movieTheater: "Cinema",
            .museum: "Museu",
            .library: "Biblioteca",
            .park: "Parque",
            .school: "Escola",
            .university: "Universidade",
            .foodMarket: "Mercado",
            .publicTransport: "Transporte público",
            .parking: "Estacionamento",
            .hotel: "Hotel",
            .pharmacy: "Farmácia",
            .hospital: "Hospital",
            .bank: "Banco",
            .atm: "Caixa eletrônico",
            .gasStation: "Posto de combustível",
            .fitnessCenter: "Academia",
            .beach: "Praia",
        ]
        let categoria = MKPointOfInterestCategory(rawValue: valorBruto)
        if ehLojaCadastrada && categoria == .store {
            return "Loja de discos"
        }
        return nomes[categoria] ?? (ehLojaCadastrada ? "Loja de discos" : "Local")
    }
}
