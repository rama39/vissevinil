//
//  alertaGuardar.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 25/09/26.
//

import SwiftUI

extension View {
    func alertaGuardar(_ desRemovendoDisco: Binding<DiscoModel?>, _ acaoGuardar: @escaping (DiscoModel) -> Void) -> some View {
        return self.alert("Guardar Disco", item: desRemovendoDisco) { disco in
            // TODO: MAKE BLUE
            Button("Guardar disco na frente", role: .confirm) {
                withAnimation {
                    disco.moverParaFrenteDaCaixa()
                    disco.removed = false
                    disco.whenRemoved = nil
                    acaoGuardar(disco)
                    
                    desRemovendoDisco.wrappedValue = nil
                }
            }
            Button("Guardar disco onde estava", role: .none) {
                withAnimation {
                    disco.removed = false
                    disco.whenRemoved = nil
                    acaoGuardar(disco)
                    
                    desRemovendoDisco.wrappedValue = nil
                }
            }
            Button("Cancelar", role: .cancel) {
                desRemovendoDisco.wrappedValue = nil
            }
        } message: { _ in
            if let disco = desRemovendoDisco.wrappedValue {
                let text =
                    "Disco: \(disco.title) - \(disco.artistsListed)" +
                    (disco.caixa.map { "\nCaixa: \($0.title)" } ?? "")
                Text(text)
            }
        }
    }
}

extension DiscoModel {
    /// Coloca o disco na frente da caixa (posição 0 da ordem manual), empurrando os outros
    func moverParaFrenteDaCaixa() {
        guard let caixa else { return }
        for outro in caixa.discos where outro !== self {
            if let posicao = outro.posicaoCaixa {
                outro.posicaoCaixa = posicao + 1
            }
        }
        posicaoCaixa = 0
    }
}
