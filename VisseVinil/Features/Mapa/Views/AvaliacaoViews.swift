//
//  AvaliacaoViews.swift
//  VisseVinil
//

import SwiftUI
import SwiftData

/// Estrelas só pra exibir uma nota (aceita meia estrela, ex: média 4,5).
struct EstrelasDeNota: View {
    let nota: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { posicao in
                Image(systemName: simbolo(para: posicao))
            }
        }
        .font(.caption)
        .foregroundStyle(Color.mostarda)
        .accessibilityElement()
        .accessibilityLabel("\(nota.formatted(.number.precision(.fractionLength(0...1)))) de 5 estrelas")
    }

    private func simbolo(para posicao: Int) -> String {
        let valor = nota - Double(posicao - 1)
        if valor >= 0.75 { return "star.fill" }
        if valor >= 0.25 { return "star.leadinghalf.filled" }
        return "star"
    }
}

/// Toque numa estrela pra dar a nota; tocar de novo na mesma tira a nota.
struct SeletorDeEstrelas: View {
    @Binding var nota: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { posicao in
                Button {
                    nota = (nota == posicao) ? 0 : posicao
                } label: {
                    Image(systemName: posicao <= nota ? "star.fill" : "star")
                        .font(.title)
                        .foregroundStyle(posicao <= nota ? Color.mostarda : Color.secondary)
                        .symbolEffect(.bounce, value: nota == posicao)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .sensoryFeedback(.selection, trigger: nota)
        .accessibilityElement()
        .accessibilityLabel("Nota")
        .accessibilityValue(nota == 0 ? "Sem nota" : "\(nota) de 5 estrelas")
        .accessibilityAdjustableAction { direcao in
            switch direcao {
            case .increment: nota = min(nota + 1, 5)
            case .decrement: nota = max(nota - 1, 0)
            @unknown default: break
            }
        }
    }
}

/// Nova avaliação pessoal: nota opcional + comentário. Dia e hora são salvos automaticamente.
struct NovaAvaliacaoView: View {
    let chaveDoLocal: String
    let nomeDoLocal: String

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var nota = 0
    @State private var comentario = ""

    private var comentarioLimpo: String {
        comentario.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var podeSalvar: Bool {
        nota > 0 || !comentarioLimpo.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Nota") {
                    SeletorDeEstrelas(nota: $nota)
                        .padding(.vertical, 6)
                }

                Section {
                    TextField("Como foi a visita? O que você achou do acervo?", text: $comentario, axis: .vertical)
                        .lineLimit(4...10)
                } header: {
                    Text("Comentário")
                } footer: {
                    Text("Só você vê suas avaliações. A data e a hora são salvas automaticamente.")
                }
            }
            .scrollEdgeEffectStyle(.soft, for: .all)
            .navigationTitle(nomeDoLocal)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: salvar)
                        .disabled(!podeSalvar)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func salvar() {
        modelContext.insert(AvaliacaoDoLocal(
            chaveDoLocal: chaveDoLocal,
            nota: nota,
            comentario: comentarioLimpo.isEmpty ? nil : comentarioLimpo
        ))
        dismiss()
    }
}

/// Uma avaliação: estrelas, dia/hora e comentário.
struct CartaoDeAvaliacao: View {
    let avaliacao: AvaliacaoDoLocal
    var comFundo = true

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if avaliacao.nota > 0 {
                    EstrelasDeNota(nota: Double(avaliacao.nota))
                }
                Spacer()
                Text(avaliacao.data.formatted(.dateTime.day().month(.abbreviated).year().hour().minute()))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let comentario = avaliacao.comentario, !comentario.isEmpty {
                Text(comentario)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(comFundo ? 16 : 0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if comFundo {
                RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(.secondarySystemFill))
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// Todas as avaliações pessoais de um local, da mais recente pra mais antiga.
/// Deslize pra apagar; "+" pra adicionar uma nova.
struct TodasAvaliacoesView: View {
    let chaveDoLocal: String
    let nomeDoLocal: String

    @Environment(\.modelContext) private var modelContext
    @Query private var avaliacoes: [AvaliacaoDoLocal]
    @State private var escrevendo = false

    init(chaveDoLocal: String, nomeDoLocal: String) {
        self.chaveDoLocal = chaveDoLocal
        self.nomeDoLocal = nomeDoLocal
        let chave = chaveDoLocal
        _avaliacoes = Query(
            filter: #Predicate<AvaliacaoDoLocal> { $0.chaveDoLocal == chave },
            sort: \.data,
            order: .reverse
        )
    }

    private var notas: [Int] {
        avaliacoes.map(\.nota).filter { $0 > 0 }
    }

    var body: some View {
        List {
            if !notas.isEmpty {
                let media = Double(notas.reduce(0, +)) / Double(notas.count)
                Section {
                    HStack(spacing: 12) {
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
            }

            Section {
                ForEach(avaliacoes) { avaliacao in
                    CartaoDeAvaliacao(avaliacao: avaliacao, comFundo: false)
                }
                .onDelete { indices in
                    for indice in indices {
                        modelContext.delete(avaliacoes[indice])
                    }
                }
            }
        }
        .overlay {
            if avaliacoes.isEmpty {
                ContentUnavailableView(
                    "Nenhuma avaliação",
                    systemImage: "star.bubble",
                    description: Text("Dê uma nota e anote como foi cada visita. Só você vê.")
                )
            }
        }
        .scrollEdgeEffectStyle(.soft, for: .all)
        .navigationTitle("Suas Avaliações")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Avaliar", systemImage: "plus") {
                    escrevendo = true
                }
            }
        }
        .sheet(isPresented: $escrevendo) {
            NovaAvaliacaoView(chaveDoLocal: chaveDoLocal, nomeDoLocal: nomeDoLocal)
        }
    }
}

/// Comunicar um problema com o local. Fica salvo no aparelho e será repassado pra equipe
/// quando houver um canal de envio (ex: CloudKit); por enquanto ninguém recebe.
struct ComunicarProblemaView: View {
    let chaveDoLocal: String
    let nomeDoLocal: String

    private static let tipos = [
        "Endereço incorreto",
        "Localização errada no mapa",
        "Telefone ou site incorretos",
        "Horário ou informações desatualizadas",
        "Local fechado permanentemente",
        "Outro problema",
    ]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var tipo = tipos[0]
    @State private var descricao = ""
    @State private var enviado = false

    var body: some View {
        NavigationStack {
            Form {
                Section("O que está errado?") {
                    Picker("Problema", selection: $tipo) {
                        ForEach(Self.tipos, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section {
                    TextField("Conte mais detalhes (opcional)", text: $descricao, axis: .vertical)
                        .lineLimit(3...8)
                } header: {
                    Text("Detalhes")
                } footer: {
                    Text("Seu relato sobre \(nomeDoLocal) fica salvo e será repassado para a equipe do VisseVinil.")
                }
            }
            .scrollEdgeEffectStyle(.soft, for: .all)
            .navigationTitle("Comunicar Problema")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: enviar)
                        .accessibilityLabel("Enviar")
                }
            }
            .alert("Obrigado!", isPresented: $enviado) {
                Button("OK") { dismiss() }
            } message: {
                Text("Sua mensagem foi salva e será repassada para a equipe assim que possível.")
            }
        }
        .presentationDetents([.large])
    }

    private func enviar() {
        modelContext.insert(ProblemaReportado(
            chaveDoLocal: chaveDoLocal,
            nomeDoLocal: nomeDoLocal,
            tipo: tipo,
            descricao: descricao.trimmingCharacters(in: .whitespacesAndNewlines)
        ))
        enviado = true
    }
}

/// Edita telefone e site do local (o endereço vem do mapa e não é editável).
/// Campo vazio = volta a usar o que o Apple Maps informar.
struct EditarContatoView: View {
    let chaveDoLocal: String
    let nomeDoLocal: String

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var contatos: [ContatoDoLocal]
    @State private var telefone: String
    @State private var site: String

    init(chaveDoLocal: String, nomeDoLocal: String, telefone: String, site: String) {
        self.chaveDoLocal = chaveDoLocal
        self.nomeDoLocal = nomeDoLocal
        _telefone = State(initialValue: telefone)
        _site = State(initialValue: site)
        let chave = chaveDoLocal
        _contatos = Query(filter: #Predicate<ContatoDoLocal> { $0.chaveDoLocal == chave })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Telefone", text: $telefone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                } header: {
                    Text("Telefone")
                }

                Section {
                    TextField("exemplo.com.br", text: $site)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Site")
                } footer: {
                    Text("Use quando o local não tiver essas informações no mapa. O endereço não pode ser editado.")
                }
            }
            .scrollEdgeEffectStyle(.soft, for: .all)
            .navigationTitle(nomeDoLocal)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: salvar)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func salvar() {
        let telefoneLimpo = telefone.trimmingCharacters(in: .whitespacesAndNewlines)
        let siteLimpo = site.trimmingCharacters(in: .whitespacesAndNewlines)

        if let contato = contatos.first {
            contato.telefone = telefoneLimpo
            contato.site = siteLimpo
        } else {
            modelContext.insert(ContatoDoLocal(chaveDoLocal: chaveDoLocal,
                                               telefone: telefoneLimpo, site: siteLimpo))
        }
        dismiss()
    }
}
