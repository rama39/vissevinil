//
//  ContentView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI
import SwiftData

enum VisseVinilTabs {
    case mapa
    case buscar
    case colecao
    case perfil
}

struct ContentView: View {
    @State private var tabSelecionada: VisseVinilTabs = .colecao

    // Onboarding: só na primeira abertura. Depois, o app abre sempre na Coleção.
    @AppStorage("onboarding.concluido") private var onboardingConcluido = false
    @Query private var perfis: [PerfilModel]

    var body: some View {
        Group {
            if onboardingConcluido {
                abas
            } else {
                OnboardingView {
                    // Terminou o onboarding: abre direto no Perfil
                    tabSelecionada = .perfil
                    withAnimation(.easeInOut(duration: 0.35)) {
                        onboardingConcluido = true
                    }
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            // Quem já tinha preenchido o perfil antes do onboarding existir não passa por ele
            if !onboardingConcluido, let perfil = perfis.first, !perfil.name.isEmpty {
                onboardingConcluido = true
            }
        }
    }

    private var abas: some View {
        TabView(selection: $tabSelecionada) {
            Tab("Lojas", systemImage: "map", value: .mapa) {
                RecifeMapView()
            }
            Tab("Buscar", systemImage: "magnifyingglass", value: .buscar) {
                BuscarView()
            }
            Tab("Coleção", systemImage: "music.note.square.stack.fill", value: .colecao) {
                ColecaoView()
            }
            Tab("Perfil", systemImage: "person", value: .perfil) {
                PerfilView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: appSchema, inMemory: true)
}
