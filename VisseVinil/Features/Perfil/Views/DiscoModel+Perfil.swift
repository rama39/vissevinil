//
//  DiscoModel+Perfil.swift
//  VisseVinil
//
//  Created by Pedro Augusto Santos de Sousa on 22/09/26.
//

import SwiftUI

extension DiscoModel {
    /// Capa a partir dos bytes já baixados do Discogs (thumbData).
    var coverImage: Image? {
        guard let thumbData, let uiImage = UIImage(data: thumbData) else { return nil }
        return Image(uiImage: uiImage)
    }

    /// Nome do local físico onde o disco está guardado, se já tiver uma Caixa.
    var locationName: String? { caixa?.title }

    /// Cor da Caixa, pra pintar a bolinha de localização.
    /// (Reaproveita CaixaModel.cor, que já existe.)
    var locationColor: Color? { caixa?.cor }
}
