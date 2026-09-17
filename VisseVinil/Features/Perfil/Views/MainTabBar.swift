//
//  MainTabBar.swift
//  VisseVinil
//
//  Created by Pedro Augusto Santos de Sousa on 16/09/26.


import SwiftUI

enum MainTab: CaseIterable {
    case buscar, colecao, mapa, perfil

    var title: String {
        switch self {
        case .buscar: return "Buscar"
        case .colecao: return "coleção"
        case .mapa: return "Mapa"
        case .perfil: return "Perfil"
        }
    }

    var iconName: String {
        switch self {
        case .buscar: return "magnifyingglass"
        case .colecao: return "square.stack"
        case .mapa: return "map"
        case .perfil: return "person.fill"
        }
    }
}

struct MainTabBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(Color(red: 0.94, green: 0.93, blue: 0.90))
        )
        .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func tabButton(for tab: MainTab) -> some View {
        let isSelected = selectedTab == tab

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 18))
                Text(tab.title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(isSelected ? Color(red: 0.72, green: 0.45, blue: 0.30) : Color.black.opacity(0.55))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.white : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabBar(selectedTab: .constant(.perfil))
        .padding(.vertical)
        .background(Color(red: 0.98, green: 0.97, blue: 0.95))
}
