//
//  EditPerfilView.swift
//  VisseVinil
//
//  Created by Maria Eduarda Marrocos Honda on 18/09/26.
//

import SwiftUI
import SwiftData
import PhotosUI

/// Edição do perfil. Tudo é feito em cópias (foto, nome, data e favoritos):
/// o ✓ grava, o X descarta e o perfil fica como estava.
struct EditPerfilView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var discos: [DiscoModel]

    @State var tempPerfil = TempPerfil(name: "")
    @Binding var perfil: PerfilModel?
    @Binding var editando: Bool

    @State private var fotoSelecionada: PhotosPickerItem?
    // Vazio = mantém o nome atual (que aparece em cinza, como placeholder)
    @State private var nomeNovo = ""
    // Favoritos escolhidos, na ordem da escolha (só vão pros discos ao salvar)
    @State private var favoritos: [PersistentIdentifier] = []
    @State private var escolhendoFavoritos = false
    @State private var escolhendoOutraCor = false

    private let tamanhoDaFoto: CGFloat = 120

    private var discosFavoritos: [DiscoModel] {
        favoritos.compactMap { id in discos.first { $0.persistentModelID == id } }
    }

    var body: some View {
        NavigationStack {
            Form {
                secaoDaFoto

                Section("Nome de Usuário") {
                    TextField("Nome", text: $nomeNovo,
                              prompt: Text(tempPerfil.name.isEmpty ? "Nome" : tempPerfil.name))
                        .textContentType(.name)
                        .submitLabel(.done)
                }

                Section("Coleciona Desde") {
                    DatePicker("Início da Coleção", selection: $tempPerfil.collectingSince,
                               in: ...Date.now, displayedComponents: [.date])
                }

                secaoDosFavoritos
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) { editando = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) { salvar() }
                }
            }
            .sheet(isPresented: $escolhendoOutraCor) {
                SeletorDeCorDoSistema(titulo: "Cor da Borda", cor: corDoSeletor) {
                    escolhendoOutraCor = false
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $escolhendoFavoritos) {
                EscolherFavoritosView(escolhidos: $favoritos)
            }
            .onChange(of: fotoSelecionada) {
                Task { await carregarFoto() }
            }
        }
        .onAppear {
            if let perfil {
                tempPerfil = perfil.toStruct()
            }
            favoritos = discos.filter(\.favorito).map(\.persistentModelID)
        }
    }

    // MARK: - Foto

    private var secaoDaFoto: some View {
        Section {
            VStack(spacing: 12) {
                Group {
                    if let dados = tempPerfil.photoImageName, let imagem = UIImage(data: dados) {
                        Image(uiImage: imagem)
                            .resizable()
                            .scaledToFill()
                    } else {
                        FotoPadraoDoPerfil()
                    }
                }
                .frame(width: tamanhoDaFoto, height: tamanhoDaFoto)
                .clipShape(Circle())
                .overlay {
                    Circle().strokeBorder(BordaDoPerfil.estilo(tempPerfil.bordaDaFoto), lineWidth: 3)
                }
                .animation(.easeInOut(duration: 0.25), value: tempPerfil.bordaDaFoto)
                .accessibilityHidden(true)

                PhotosPicker(selection: $fotoSelecionada, matching: .images) {
                    Text(tempPerfil.photoImageName == nil ? "Adicionar Foto" : "Editar Foto")
                }
                .buttonStyle(.borderedProminent)

                coresDaBorda
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
        }
        .listRowBackground(Color.clear)
    }

    // MARK: - Borda da foto

    // Cores sugeridas + "outra cor" (seletor do sistema), embaixo da foto, como as cores do
    // editor de foto do Contatos. Cada amostra tem 44 pt de toque (mínimo da HIG) e a
    // escolhida ganha um anel na própria cor, com um respiro em volta.
    private var coresDaBorda: some View {
        HStack(spacing: 0) {
            ForEach(BordaDoPerfil.Sugestao.allCases) { sugestao in
                amostra(sugestao.estilo,
                        escolhida: BordaDoPerfil.sugestao(tempPerfil.bordaDaFoto) == sugestao) {
                    tempPerfil.bordaDaFoto = sugestao.rawValue
                }
                .accessibilityLabel(sugestao.nome)
            }

            // Outra cor: com o visual do botão de cor do sistema (anel arco-íris, cor no centro)
            let personalizada = BordaDoPerfil.corPersonalizada(tempPerfil.bordaDaFoto)
            Button {
                escolhendoOutraCor = true
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(.secondary, lineWidth: 2.5)
                        .frame(width: 40, height: 40)
                        .opacity(personalizada != nil ? 1 : 0)
                        .scaleEffect(personalizada != nil ? 1 : 0.8)
                    Circle()
                        .strokeBorder(Self.arcoIris, lineWidth: 3.5)
                        .frame(width: 30, height: 30)
                    Circle()
                        .fill(personalizada.map { AnyShapeStyle($0) } ?? AnyShapeStyle(.fill.tertiary))
                        .frame(width: 18, height: 18)
                }
                .frame(width: 44, height: 44)
                .contentShape(Circle())
                .animation(.snappy, value: personalizada != nil)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .accessibilityAddTraits(personalizada != nil ? .isSelected : [])
            .accessibilityLabel("Outra Cor")
            .accessibilityHint("Abre o seletor de cores")
        }
        .frame(maxWidth: .infinity)
        .sensoryFeedback(.selection, trigger: tempPerfil.bordaDaFoto)
    }

    private static let arcoIris = AngularGradient(
        colors: [.red, .orange, .yellow, .green, .mint, .blue, .purple, .pink, .red],
        center: .center)

    private func amostra(_ estilo: AnyShapeStyle, escolhida: Bool,
                         acao: @escaping () -> Void) -> some View {
        Button(action: acao) {
            ZStack {
                Circle()
                    .strokeBorder(estilo, lineWidth: 2.5)
                    .frame(width: 40, height: 40)
                    .opacity(escolhida ? 1 : 0)
                    .scaleEffect(escolhida ? 1 : 0.8)
                Circle()
                    .fill(estilo)
                    .frame(width: 30, height: 30)
            }
            .frame(width: 44, height: 44)
            .contentShape(Circle())
            .animation(.snappy, value: escolhida)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .accessibilityAddTraits(escolhida ? .isSelected : [])
    }

    // O seletor abre na cor atual; escolher uma cor salva ela como personalizada
    private var corDoSeletor: Binding<Color> {
        Binding {
            BordaDoPerfil.corPersonalizada(tempPerfil.bordaDaFoto)
                ?? BordaDoPerfil.sugestao(tempPerfil.bordaDaFoto)?.corBase
                ?? .bordaDoPerfil
        } set: { cor in
            tempPerfil.bordaDaFoto = BordaDoPerfil.valor(de: cor)
        }
    }

    // MARK: - Discos favoritos

    private var secaoDosFavoritos: some View {
        Section {
            ForEach(discosFavoritos) { disco in
                linhaDoFavorito(disco)
            }
            .onDelete { indices in
                withAnimation { favoritos.remove(atOffsets: indices) }
            }

            Button {
                escolhendoFavoritos = true
            } label: {
                Label(favoritos.isEmpty ? "Escolher Discos Favoritos" : "Editar Discos Favoritos",
                      systemImage: favoritos.isEmpty ? "plus.circle.fill" : "pencil.circle.fill")
            }
        } header: {
            Text("Discos Favoritos")
        } footer: {
            Text("\(favoritos.count) de \(EscolherFavoritosView.limite) escolhidos. Eles aparecem no carrossel do seu perfil.")
        }
    }

    private func linhaDoFavorito(_ disco: DiscoModel) -> some View {
        HStack(spacing: 12) {
            Group {
                if let capa = disco.coverImage {
                    capa.resizable().scaledToFill()
                } else {
                    ZStack {
                        Color(.systemGray5)
                        Image(systemName: "opticaldisc")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(disco.title)
                    .lineLimit(1)
                if !disco.artistsListed.isEmpty {
                    Text(disco.artistsListed)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Salvar

    private func salvar() {
        if let perfil {
            let nome = nomeNovo.trimmingCharacters(in: .whitespacesAndNewlines)
            if !nome.isEmpty {
                tempPerfil.name = nome
            }
            tempPerfil.toData(perfil: perfil)
        }
        for disco in discos {
            let favorito = favoritos.contains(disco.persistentModelID)
            if disco.favorito != favorito {
                disco.favorito = favorito
            }
        }
        try? modelContext.save()
        editando = false
    }

    private func carregarFoto() async {
        guard let fotoSelecionada,
              let dados = try? await fotoSelecionada.loadTransferable(type: Data.self)
        else { return }
        tempPerfil.photoImageName = dados
    }
}

#Preview {
    TabView {
        Tab("Perfil", systemImage: "person") {
            PerfilView()
        }
    }
    .modelContainer(for: appSchema, inMemory: true)
}
