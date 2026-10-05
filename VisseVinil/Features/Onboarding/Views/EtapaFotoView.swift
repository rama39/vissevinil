//
//  EtapaFotoView.swift
//  VisseVinil
//

import SwiftUI
import PhotosUI
import UIKit

/// Etapa 2 do onboarding (opcional): foto de perfil.
/// Como no app Contatos: sem foto, mostra as iniciais do nome; e como nas configurações do
/// sistema, a opção de deixar pra depois ("Agora Não") fica embaixo do botão principal.
struct EtapaFotoView: View {
    let nome: String
    @Binding var foto: Data?
    let concluir: () -> Void

    @State private var itemSelecionado: PhotosPickerItem?
    @State private var carregando = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                fotoDePerfil
                    .padding(.top, 32)

                VStack(spacing: 12) {
                    Text("Adicione uma Foto")
                        .font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)

                    Text("Ela aparece no seu perfil. Você pode trocar quando quiser.")
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                if foto == nil {
                    PhotosPicker(selection: $itemSelecionado, matching: .images) {
                        Text("Escolher Foto")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(carregando)

                    Button("Agora Não") {
                        foto = nil
                        concluir()
                    }
                } else {
                    Button(action: concluir) {
                        Text("Continuar")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(carregando)

                    PhotosPicker("Escolher Outra Foto", selection: $itemSelecionado, matching: .images)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: itemSelecionado) { _, item in
            guard let item else { return }
            Task { await carregarFoto(de: item) }
        }
    }

    // MARK: - Foto

    private let tamanhoDaFoto: CGFloat = 140

    // Foto escolhida, ou as iniciais do nome num círculo cinza (como no Contatos)
    private var fotoDePerfil: some View {
        ZStack {
            if let foto, let imagem = UIImage(data: foto) {
                Image(uiImage: imagem)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(Color(.systemGray3).gradient)
                if iniciais.isEmpty {
                    Image(systemName: "person.fill")
                        .font(.system(size: tamanhoDaFoto * 0.45))
                        .foregroundStyle(.white)
                } else {
                    Text(iniciais)
                        .font(.system(size: tamanhoDaFoto * 0.4, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                }
            }

            if carregando {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .frame(width: tamanhoDaFoto, height: tamanhoDaFoto)
        .clipShape(Circle())
        .accessibilityElement()
        .accessibilityLabel(foto == nil ? "Sem foto de perfil" : "Foto de perfil escolhida")
    }

    // "Gabriel Melo" -> "GM"
    private var iniciais: String {
        nome.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .uppercased()
    }

    private func carregarFoto(de item: PhotosPickerItem) async {
        carregando = true
        defer { carregando = false }
        guard let dados = try? await item.loadTransferable(type: Data.self) else { return }
        foto = reduzida(dados)
    }

    // No máximo 1024 px em JPEG: fotos da câmera têm vários MB e a do perfil nunca aparece grande
    private func reduzida(_ dados: Data, ladoMaximo: CGFloat = 1024) -> Data {
        guard let imagem = UIImage(data: dados) else { return dados }
        let escala = min(1, ladoMaximo / max(imagem.size.width, imagem.size.height))
        let tamanho = CGSize(width: imagem.size.width * escala, height: imagem.size.height * escala)

        let formato = UIGraphicsImageRendererFormat.default()
        formato.scale = 1
        let imagemReduzida = UIGraphicsImageRenderer(size: tamanho, format: formato).image { _ in
            imagem.draw(in: CGRect(origin: .zero, size: tamanho))
        }
        return imagemReduzida.jpegData(compressionQuality: 0.85) ?? dados
    }
}
