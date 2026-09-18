//
//  ProfileHeaderView.swift
//  VisseVinil
//
//  Created by Pedro Augusto Santos de Sousa on 16/09/26.


import SwiftUI

struct ProfileHeaderView: View {
    @Bindable var profile: PerfilModel
    var onEditTapped: () -> Void = {}

    var body: some View {
        VStack(spacing: 16) {
            // Barra de título com botão de edição
            ZStack {
                Text("Perfil")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.85))

                HStack {
                    Spacer()
                    Button(action: onEditTapped) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.black.opacity(0.75))
                            .padding(12)
                            .background(Circle().fill(Color.white))
                            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                    }
                }
            }
            .padding(.horizontal, 20)

            // Foto de perfil
            Group {
                if let uiImage = UIImage(named: profile.photoImageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    // Placeholder enquanto não há asset cadastrado
                    ZStack {
                        Color.gray.opacity(0.2)
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.gray)
                    }
                }
            }
            .frame(width: 130, height: 130)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color(red: 0.72, green: 0.45, blue: 0.30).opacity(0.6), lineWidth: 3)
            )

            // Nome e tempo de coleção
            VStack(spacing: 6) {
                Text(profile.name)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.black.opacity(0.85))

                Text(profile.collectingTimeDescription)
                    .font(.system(size: 15))
                    .foregroundStyle(Color(red: 0.45, green: 0.45, blue: 0.45))
            }
        }
    }
}

#Preview {
    let previewProfile = PerfilModel(
        name: "Matheus",
        photoImageName: "profile_photo",
        collectingSince: Calendar.current.date(byAdding: .month, value: -30, to: Date()) ?? Date()
    )
    return ProfileHeaderView(profile: previewProfile)
        .background(Color(red: 0.98, green: 0.97, blue: 0.95))
}
