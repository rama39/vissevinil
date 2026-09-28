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
            Capsule().fill(Color(.secondarySystemBackground))
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
            .foregroundStyle(isSelected ? Color.accentColor : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color(.systemBackground) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabBar(selectedTab: .constant(.perfil))
        .padding(.vertical)
        .background(Color(.systemGroupedBackground))
}
