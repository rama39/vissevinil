//
//  FotoPadraoDoPerfil.swift
//  VisseVinil
//

import SwiftUI

/// Imagem do perfil quando não há foto cadastrada: um disco sobre fundo cinza.
/// Usada no onboarding, no cabeçalho do Perfil e na edição do perfil.
struct FotoPadraoDoPerfil: View {
    var body: some View {
        ZStack {
            Color(.systemGray5)
            Image(systemName: "opticaldisc.fill")
                .resizable()
                .scaledToFit()
                .padding(8)
                .foregroundStyle(.primary)
        }
        .accessibilityHidden(true)
    }
}
