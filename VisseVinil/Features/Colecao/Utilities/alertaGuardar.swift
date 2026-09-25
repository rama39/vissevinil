//
//  alertaGuardar.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 25/09/26.
//

import SwiftUI

extension View {
    func alertaGuardar(_ desRemovendoDisco: Binding<DiscoModel?>) -> some View {
        return self.alert("Guardar Disco", item: desRemovendoDisco) { disco in
            // TODO: MAKE BLUE
            Button("Guardar disco na frente", role: .confirm) {
                withAnimation {
                    // TODO: mover à frente
                    disco.removed = false
                    desRemovendoDisco.wrappedValue = nil
                }
            }
            Button("Guardar disco onde estava", role: .none) {
                withAnimation {
                    disco.removed = false
                    desRemovendoDisco.wrappedValue = nil
                }
            }
            Button("Cancelar", role: .cancel) {
                desRemovendoDisco.wrappedValue = nil
            }
        } message: { _ in
            if let disco = desRemovendoDisco.wrappedValue {
                let text =
                    "Disco: \(disco.title) - \(disco.artistsListed)" + (
                        disco.caixa != nil ?
                        "\nCaixa: \(disco.caixa!.title)" : ""
                    )
                Text(text)
            }
        }
    }
}
