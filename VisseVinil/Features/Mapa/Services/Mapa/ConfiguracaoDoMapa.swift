//
//  ConfiguracaoDoMapa.swift
//  VisseVinil
//

import MapKit

/*
 ===============================================================================================
  Imagine que existe uma câmera em cima do globo, precisamos definir duas coisas:
     - Onde ela está posicionada;
     - A que altura ela está.

  Dessa forma, como queremos limitar apenas Recife, devemos "prender" o usuário nessa posição.
 ===============================================================================================
*/
enum ConfiguracaoDoMapa {
    /// "Principal" Região Metropolitana do Recife: a câmera fica presa dentro dela
    static let regiaoMetropolitana = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -8.0576, longitude: -34.9050),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.20)
    )

    // Limitantes do Zoom (distância da câmera, em metros)
    static let distanciaMinima: CLLocationDistance = 500
    static let distanciaMaxima: CLLocationDistance = 85000

    /// Zoom (graus de latitude visíveis na altura do mapa) usado ao abrir um local pela
    /// busca, recentes ou favoritos
    static let spanDeFoco: CLLocationDegrees = 0.012

    // Sheet de detalhes: altura reduzida e distância entre a loja e o topo da sheet
    static let alturaDaSheetReduzida: CGFloat = 340
    static let espacamentoAcimaDaSheet: CGFloat = 40
}
