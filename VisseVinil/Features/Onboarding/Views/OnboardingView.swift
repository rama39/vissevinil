//
//  OnboardingView.swift
//  VisseVinil
//

import SwiftUI
import SwiftData

/*
 Primeira abertura do app (curto, um objetivo por tela, como pede a HIG):
  1. Dados (obrigatória): nome de usuário e desde quando coleciona discos.
  2. Foto (opcional): foto de perfil, com "Agora Não".
 Ao abrir, já aparece o pedido de localização do sistema (a única permissão do app; a
 foto usa o seletor do sistema, que não precisa de permissão).
 No fim, grava no PerfilModel (o mesmo que a aba Perfil lê) e chama `concluir`.
*/
struct OnboardingView: View {
    /// Chamado quando a pessoa termina (o app abre na aba Perfil)
    let concluir: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var perfis: [PerfilModel]

    @State private var nome = ""
    @State private var colecionaDesde = Date()
    @State private var foto: Data?
    @State private var mostrandoEtapaDaFoto = false
    @State private var localizacao = PermissaoDeLocalizacao()

    var body: some View {
        NavigationStack {
            EtapaDadosView(nome: $nome, colecionaDesde: $colecionaDesde) {
                mostrandoEtapaDaFoto = true
            }
            .navigationDestination(isPresented: $mostrandoEtapaDaFoto) {
                EtapaFotoView(nome: nome, foto: $foto, concluir: salvarEConcluir)
            }
        }
        // Pedido do sistema logo no começo (só aparece se a pessoa ainda não respondeu)
        .task {
            localizacao.pedir()
        }
    }

    private func salvarEConcluir() {
        // Reaproveita o perfil se já existir um (a aba Perfil cria um vazio ao aparecer)
        let perfil = perfis.first ?? {
            let novo = PerfilModel()
            modelContext.insert(novo)
            return novo
        }()

        perfil.name = nome.trimmingCharacters(in: .whitespacesAndNewlines)
        perfil.collectingSince = colecionaDesde
        perfil.imagePhotoName = foto
        try? modelContext.save()

        concluir()
    }
}

#Preview {
    OnboardingView { }
        .modelContainer(for: appSchema, inMemory: true)
}
