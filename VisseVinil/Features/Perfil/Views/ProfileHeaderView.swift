//
//  ProfileHeaderView.swift
//  VisseVinil
//
//  Created by Pedro Augusto Santos de Sousa on 16/09/26.


import SwiftUI

struct ProfileHeaderView: View {
    @Bindable var profile: PerfilModel

    private let tamanhoDaFoto: CGFloat = 120

    var body: some View {
        VStack(spacing: 14) {
            foto

            // Nome e tempo de coleção
            VStack(spacing: 4) {
                Text(profile.name)
                    .font(.title.bold())
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text(profile.collectingTimeDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
    }

    // Foto de perfil; sem foto, a imagem padrão (um disco)
    private var foto: some View {
        Group {
            if let profileImage = profile.imagePhotoName, let uiImage = UIImage(data: profileImage) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                FotoPadraoDoPerfil()
            }
        }
        .frame(width: tamanhoDaFoto, height: tamanhoDaFoto)
        .clipShape(Circle())
        .overlay {
            Circle().strokeBorder(.bordaDoPerfil, lineWidth: 3)
        }
        .accessibilityHidden(true)
    }
}
//#Preview {
//    let previewProfile = PerfilModel(
//        name: "Matheus",
//        photoImageName: "profile_photo",
//        collectingSince: Calendar.current.date(byAdding: .month, value: -30, to: Date()) ?? Date()
//    )
//    return ProfileHeaderView(profile: previewProfile)
//        .background(Color(.systemGroupedBackground))
//}
