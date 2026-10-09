//
//  OnboardingView.swift
//  VisseVinil
//

import SwiftUI
import SwiftData

/*
 Primeira abertura do app (curto, um objetivo por tela, como pede a HIG):
  0. Privacidade (obrigatória): a Política de Privacidade num quadro, com "Li e aceito".
  1. Dados (obrigatória): nome de usuário e desde quando coleciona discos.
  2. Foto (opcional): foto de perfil, com "Agora Não".
 Depois do aceite, aparece o pedido de localização do sistema (a única permissão do app;
 a foto usa o seletor do sistema, que não precisa de permissão).
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
    @State private var mostrandoEtapaDosDados = false
    @State private var mostrandoEtapaDaFoto = false
    // Quando a política foi aceita (registro do aceite)
    @AppStorage("privacidade.aceitaEm") private var privacidadeAceitaEm: Double = 0
    @State private var localizacao = PermissaoDeLocalizacao()

    var body: some View {
        NavigationStack {
            EtapaPrivacidadeView {
                privacidadeAceitaEm = Date.now.timeIntervalSince1970
                mostrandoEtapaDosDados = true
                // Pedido do sistema logo depois do aceite (só aparece se ainda não respondeu)
                localizacao.pedir()
            }
            .navigationDestination(isPresented: $mostrandoEtapaDosDados) {
                EtapaDadosView(nome: $nome, colecionaDesde: $colecionaDesde) {
                    mostrandoEtapaDaFoto = true
                }
                // A política já foi aceita: não volta pra ela
                .navigationBarBackButtonHidden()
                .navigationDestination(isPresented: $mostrandoEtapaDaFoto) {
                    EtapaFotoView(nome: nome, foto: $foto, concluir: salvarEConcluir)
                }
            }
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
