//
//  LojaDetailView.swift
//  VisseVinil
//
//  Created by Gabriel Alves Gadelha de Melo on 24/09/26.
//

import SwiftUI
import SwiftData
import MapKit

/*
 Sheet de detalhes de um local, no modelo do app Mapas:
  - Barra do topo: título centralizado na mesma linha do X; grande no início e menor ao rolar
  1. subtítulo (categoria · distância), centralizado sob o título
  2. três ações: rota (abre o app Mapas já com a rota a pé traçada, mostrando o tempo
     estimado), ligar e site (cinza quando não há dado)
  3. avaliações pessoais: nota + comentário salvos com dia e hora; a média é só da pessoa.
     Mostra as 3 últimas; o resto fica em "Ver todas"
  4. detalhes: telefone e site (editáveis pela pessoa) e endereço (com botão de copiar)
  5. comunicar um problema
 Seções separadas por linhas finas. Embaixo, um bloco centralizado com fixar, favoritar e
 "…" (resumo das ações num menu).
 Textos nos estilos dinâmicos da HIG (title3 nos títulos de seção, body no conteúdo,
 subheadline/footnote nos apoios), que acompanham o tamanho de fonte escolhido no iPhone.
*/
struct LojaDetailView: View {
    let loja: Loja
    let chaveDoLocal: String
    let ehLojaCadastrada: Bool
    let ehFavorito: Bool
    let onToggleFavorito: () -> Void
    let ehFixado: Bool
    let onToggleFixado: () -> Void
    let localizacaoDoUsuario: CLLocationCoordinate2D?
    let onFechar: () -> Void

    // Telas empilhadas dentro da sheet
    private enum Destino: Hashable {
        case todasAsAvaliacoes
    }

    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var modelContext
    @Query private var avaliacoes: [AvaliacaoDoLocal]
    @Query private var contatos: [ContatoDoLocal]

    @State private var caminho: [Destino] = []
    @State private var tempoAPe: TimeInterval?
    @State private var buscandoEndereco = false
    @State private var escrevendoAvaliacao = false
    @State private var editandoContato = false
    @State private var comunicandoProblema = false
    @State private var tituloCompacto = false
    @State private var copiouEndereco = false

    // Quantas avaliações aparecem direto na sheet
    private let avaliacoesVisiveis = 3

    init(loja: Loja, chaveDoLocal: String, ehLojaCadastrada: Bool,
         ehFavorito: Bool, onToggleFavorito: @escaping () -> Void,
         ehFixado: Bool, onToggleFixado: @escaping () -> Void,
         localizacaoDoUsuario: CLLocationCoordinate2D?, onFechar: @escaping () -> Void) {
        self.loja = loja
        self.chaveDoLocal = chaveDoLocal
        self.ehLojaCadastrada = ehLojaCadastrada
        self.ehFavorito = ehFavorito
        self.onToggleFavorito = onToggleFavorito
        self.ehFixado = ehFixado
        self.onToggleFixado = onToggleFixado
        self.localizacaoDoUsuario = localizacaoDoUsuario
        self.onFechar = onFechar

        // Só os dados deste local
        let chave = chaveDoLocal
        _avaliacoes = Query(
            filter: #Predicate<AvaliacaoDoLocal> { $0.chaveDoLocal == chave },
            sort: \.data,
            order: .reverse
        )
        _contatos = Query(filter: #Predicate<ContatoDoLocal> { $0.chaveDoLocal == chave })
    }

    var body: some View {
        NavigationStack(path: $caminho) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    subtituloCentralizado
                    botoesDeAcao
                    Divider()
                    secaoDeAvaliacoes
                    Divider()
                    secaoDeDetalhes
                    Divider()
                    comunicarProblema
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            // Desfoque em degradê (some aos poucos) atrás das barras, em vez de uniforme
            .scrollEdgeEffectStyle(.soft, for: .all)
            // Título encolhe quando o conteúdo começa a passar por baixo da barra
            .onScrollGeometryChange(for: Bool.self) { geometria in
                geometria.contentOffset.y + geometria.contentInsets.top > 12
            } action: { _, rolou in
                withAnimation(.easeInOut(duration: 0.2)) {
                    tituloCompacto = rolou
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Título na mesma linha do X, centralizado
                ToolbarItem(placement: .principal) {
                    Text(nome)
                        .font(tituloCompacto ? .headline : .title.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .accessibilityAddTraits(.isHeader)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .close, action: onFechar)
                }

                // Bloco único centralizado: espaçadores flexíveis dos dois lados
                ToolbarSpacer(.flexible, placement: .bottomBar)
                ToolbarItemGroup(placement: .bottomBar) {
                    barraInferior
                }
                ToolbarSpacer(.flexible, placement: .bottomBar)
            }
            .navigationDestination(for: Destino.self) { destino in
                switch destino {
                case .todasAsAvaliacoes:
                    TodasAvaliacoesView(chaveDoLocal: chaveDoLocal, nomeDoLocal: nome)
                }
            }
        }
        .sheet(isPresented: $escrevendoAvaliacao) {
            NovaAvaliacaoView(chaveDoLocal: chaveDoLocal, nomeDoLocal: nome)
        }
        .sheet(isPresented: $editandoContato) {
            EditarContatoView(chaveDoLocal: chaveDoLocal, nomeDoLocal: nome,
                              telefone: telefone ?? "", site: site ?? "")
        }
        .sheet(isPresented: $comunicandoProblema) {
            ComunicarProblemaView(chaveDoLocal: chaveDoLocal, nomeDoLocal: nome)
        }
        // Tudo que depende do local é recarregado quando a sheet troca de local
        .task(id: loja.id) {
            caminho = []
            await carregarInformacoes()
        }
    }

    private func verTodasAsAvaliacoes() {
        caminho = [.todasAsAvaliacoes]
    }

    // MARK: - Subtítulo

    private var nome: String {
        loja.officialName ?? loja.nameForSearch
    }

    private var subtitulo: String {
        var partes = [CategoriaDoLocal.nome(para: loja.category, ehLojaCadastrada: ehLojaCadastrada)]
        if let localizacaoDoUsuario {
            let distancia = CLLocation(latitude: localizacaoDoUsuario.latitude, longitude: localizacaoDoUsuario.longitude)
                .distance(from: CLLocation(latitude: loja.latitude, longitude: loja.longitude))
            partes.append(FormatoDeRota.distancia(distancia))
        }
        return partes.joined(separator: " · ")
    }

    private var subtituloCentralizado: some View {
        Text(subtitulo)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            // Mais perto do título, que fica na barra logo acima
            .padding(.top, -10)
    }

    // MARK: - Contato (o informado pela pessoa tem prioridade sobre o do Apple Maps)

    private var telefone: String? {
        contatos.first?.telefone?.nilSeVazio ?? loja.fone?.nilSeVazio
    }

    private var site: String? {
        contatos.first?.site?.nilSeVazio ?? loja.website?.nilSeVazio
    }

    private var urlDoTelefone: URL? {
        guard let telefone else { return nil }
        let digitos = telefone.filter { $0.isNumber || $0 == "+" }
        return digitos.isEmpty ? nil : URL(string: "tel://\(digitos)")
    }

    private var urlDoSite: URL? {
        guard let site else { return nil }
        return URL(string: site.contains("://") ? site : "https://\(site)")
    }

    // MARK: - Ações (rota, ligar, site)

    private var tituloDaRota: String {
        tempoAPe.map(FormatoDeRota.tempo) ?? "Rota"
    }

    // Abre o app Mapas já com a rota a pé traçada até o local
    private func abrirRota() {
        RotaNoMapas.abrirRota(ate: loja)
    }

    private var botoesDeAcao: some View {
        HStack(spacing: 8) {
            BotaoDeAcao(titulo: tituloDaRota, icone: "figure.walk", destaque: true,
                        habilitado: true, acao: abrirRota)
            BotaoDeAcao(titulo: "Ligar", icone: "phone.fill", habilitado: urlDoTelefone != nil) {
                if let urlDoTelefone { openURL(urlDoTelefone) }
            }
            BotaoDeAcao(titulo: "Site", icone: "safari.fill", habilitado: urlDoSite != nil) {
                if let urlDoSite { openURL(urlDoSite) }
            }
        }
    }

    // MARK: - Avaliações pessoais

    private var notas: [Int] {
        avaliacoes.map(\.nota).filter { $0 > 0 }
    }

    private var media: Double? {
        notas.isEmpty ? nil : Double(notas.reduce(0, +)) / Double(notas.count)
    }

    private var secaoDeAvaliacoes: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TituloDeSecao("Suas Avaliações")
                Spacer()
                Button("Avaliar", systemImage: "square.and.pencil") {
                    escrevendoAvaliacao = true
                }
                .font(.subheadline.weight(.semibold))
            }

            if let media {
                HStack(alignment: .center, spacing: 12) {
                    Text(media.formatted(.number.precision(.fractionLength(1))))
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    VStack(alignment: .leading, spacing: 4) {
                        EstrelasDeNota(nota: media)
                        Text(notas.count == 1 ? "Sua nota" : "Sua média em \(notas.count) visitas")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
            }

            if avaliacoes.isEmpty {
                Text("Dê uma nota e anote como foi cada visita. Só você vê.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(avaliacoes.prefix(avaliacoesVisiveis)) { avaliacao in
                    CartaoDeAvaliacao(avaliacao: avaliacao)
                        .contextMenu {
                            Button("Apagar", systemImage: "trash", role: .destructive) {
                                modelContext.delete(avaliacao)
                            }
                        }
                }

                if avaliacoes.count > avaliacoesVisiveis {
                    Button(action: verTodasAsAvaliacoes) {
                        HStack {
                            Text("Ver todas as \(avaliacoes.count) avaliações")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                        }
                        .font(.subheadline.weight(.semibold))
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                }
            }
        }
    }

    // MARK: - Detalhes

    // Endereço em linhas, como no Mapas: "Rua, número" / "Bairro, Cidade - UF" / CEP / País.
    // Sem as partes (ainda não buscadas), usa o endereço completo em texto único.
    private var linhasDoEndereco: [String] {
        let ruaENumero = [loja.rua, loja.numero].compactMap { $0 }.joined(separator: ", ")
        let cidadeEEstado = [loja.cidade, loja.estado].compactMap { $0 }.joined(separator: " - ")
        let bairroECidade = [loja.bairro, cidadeEEstado.isEmpty ? nil : cidadeEEstado]
            .compactMap { $0 }.joined(separator: ", ")
        let linhas = [ruaENumero, bairroECidade, loja.cep ?? "", loja.pais ?? ""].filter { !$0.isEmpty }

        if linhas.isEmpty, let completo = loja.address {
            return [completo]
        }
        return linhas
    }

    private func copiarEndereco() {
        UIPasteboard.general.string = linhasDoEndereco.joined(separator: ", ")
        copiouEndereco = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            copiouEndereco = false
        }
    }

    // Lista simples (sem bloco): nome do campo à esquerda, informação à direita
    private var secaoDeDetalhes: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                TituloDeSecao("Detalhes")
                if buscandoEndereco {
                    ProgressView()
                        .padding(.leading, 4)
                }
                Spacer()
                // Só telefone e site são editáveis (o endereço vem do mapa)
                Button("Editar") {
                    editandoContato = true
                }
                .font(.subheadline.weight(.semibold))
            }
            .padding(.bottom, 4)

            LinhaDeDetalhe(campo: "Telefone") {
                if let telefone, let urlDoTelefone {
                    Button(telefone) { openURL(urlDoTelefone) }
                        .foregroundStyle(Color.accentColor)
                } else {
                    naoCadastrado
                }
            }
            Divider()

            LinhaDeDetalhe(campo: "Site") {
                if let site, let urlDoSite {
                    Button(site.replacingOccurrences(of: "https://", with: "")
                               .replacingOccurrences(of: "http://", with: "")) {
                        openURL(urlDoSite)
                    }
                    .foregroundStyle(Color.accentColor)
                    .lineLimit(1)
                } else {
                    naoCadastrado
                }
            }
            Divider()

            LinhaDeDetalhe(campo: "Endereço") {
                if linhasDoEndereco.isEmpty {
                    Text(buscandoEndereco ? "Buscando endereço…" : "Endereço indisponível")
                        .foregroundStyle(.secondary)
                } else {
                    Text(linhasDoEndereco.joined(separator: "\n"))
                        .multilineTextAlignment(.trailing)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } acessorio: {
                if !linhasDoEndereco.isEmpty {
                    Button(copiouEndereco ? "Copiado" : "Copiar",
                           systemImage: copiouEndereco ? "checkmark" : "doc.on.doc",
                           action: copiarEndereco)
                        .labelStyle(.iconOnly)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                        .contentTransition(.symbolEffect(.replace))
                        .sensoryFeedback(.success, trigger: copiouEndereco) { _, novo in novo }
                        .accessibilityLabel(copiouEndereco ? "Endereço copiado" : "Copiar endereço")
                }
            }
        }
    }

    // Toque em "Não cadastrado" abre a edição
    private var naoCadastrado: some View {
        Button("Não cadastrado") {
            editandoContato = true
        }
        .foregroundStyle(.secondary)
        .accessibilityHint("Toque para adicionar")
    }

    // MARK: - Comunicar problema

    private var comunicarProblema: some View {
        Button {
            comunicandoProblema = true
        } label: {
            Label("Comunicar um Problema", systemImage: "exclamationmark.bubble")
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(.secondarySystemFill)))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.red)
    }

    // MARK: - Barra inferior

    @ViewBuilder
    private var barraInferior: some View {
        Button(ehFixado ? "Desafixar" : "Fixar", systemImage: ehFixado ? "pin.fill" : "pin",
               action: onToggleFixado)
        Button(ehFavorito ? "Remover dos Favoritos" : "Favoritar",
               systemImage: ehFavorito ? "star.fill" : "star", action: onToggleFavorito)

        // "…": resumo da sheet (as três ações no topo + avaliações, favoritar e fixar)
        Menu {
            ControlGroup {
                Button(tituloDaRota, systemImage: "figure.walk", action: abrirRota)
                Button("Ligar", systemImage: "phone.fill") {
                    if let urlDoTelefone { openURL(urlDoTelefone) }
                }
                .disabled(urlDoTelefone == nil)
                Button("Site", systemImage: "safari.fill") {
                    if let urlDoSite { openURL(urlDoSite) }
                }
                .disabled(urlDoSite == nil)
            }

            Button("Adicionar Avaliação", systemImage: "square.and.pencil") {
                escrevendoAvaliacao = true
            }
            Button("Ver Suas Avaliações", systemImage: "list.star", action: verTodasAsAvaliacoes)
            Button(ehFavorito ? "Remover dos Favoritos" : "Adicionar aos Favoritos",
                   systemImage: ehFavorito ? "star.slash" : "star", action: onToggleFavorito)
            Button(ehFixado ? "Desafixar" : "Fixar",
                   systemImage: ehFixado ? "pin.slash" : "pin", action: onToggleFixado)
        } label: {
            Label("Mais opções", systemImage: "ellipsis")
        }
    }

    // MARK: - Carregamento

    private func carregarInformacoes() async {
        tempoAPe = nil

        // Em paralelo: tempo a pé e endereço detalhado
        let destino = loja.coordinate
        let origem = localizacaoDoUsuario
        async let tempo: TimeInterval? = {
            guard let origem else { return nil }
            return await RotaNoMapas.tempoAPe(de: origem, ate: destino)
        }()

        if !loja.temEnderecoDetalhado {
            buscandoEndereco = true
            await loja.buscarEnderecoSeFaltar()
            buscandoEndereco = false
        }

        tempoAPe = await tempo
    }
}

// MARK: - Componentes

private extension String {
    var nilSeVazio: String? {
        let limpo = trimmingCharacters(in: .whitespacesAndNewlines)
        return limpo.isEmpty ? nil : limpo
    }
}

/// Título de seção da sheet (Title 3 em negrito, como nos cartões do Mapas).
private struct TituloDeSecao: View {
    let texto: String

    init(_ texto: String) {
        self.texto = texto
    }

    var body: some View {
        Text(texto)
            .font(.title3.bold())
            .accessibilityAddTraits(.isHeader)
    }
}

/// Botão grande de ação (como os do Mapas). Cinza e desativado quando não há o dado.
private struct BotaoDeAcao: View {
    let titulo: String
    let icone: String
    var destaque = false
    let habilitado: Bool
    let acao: () -> Void

    var body: some View {
        Button(action: acao) {
            VStack(spacing: 4) {
                Image(systemName: icone)
                    .font(.title3)
                Text(titulo)
                    .font(.footnote.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 58)
            .foregroundStyle(corDoConteudo)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(corDoFundo))
        }
        .buttonStyle(.plain)
        .disabled(!habilitado)
        .accessibilityLabel(titulo)
    }

    private var corDoConteudo: Color {
        guard habilitado else { return .secondary }
        return destaque ? .creme : .accentColor
    }

    private var corDoFundo: Color {
        habilitado && destaque ? .vinho : Color(.tertiarySystemFill)
    }
}

/// Linha de "Detalhes": nome do campo à esquerda (com um acessório opcional ao lado, ex: o
/// botão de copiar) e a informação à direita.
private struct LinhaDeDetalhe<Valor: View, Acessorio: View>: View {
    let campo: String
    @ViewBuilder let valor: Valor
    @ViewBuilder let acessorio: Acessorio

    init(campo: String, @ViewBuilder valor: () -> Valor,
         @ViewBuilder acessorio: () -> Acessorio = { EmptyView() }) {
        self.campo = campo
        self.valor = valor()
        self.acessorio = acessorio()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            HStack(spacing: 8) {
                Text(campo)
                    .foregroundStyle(.secondary)
                acessorio
            }

            valor
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.body)
        .padding(.vertical, 12)
    }
}
