//
//  ContatoDoLocal.swift
//  VisseVinil
//

import Foundation
import SwiftData

/// Telefone/site informados pela própria pessoa quando o Apple Maps não tem (ou tem errado).
/// Fica separado da Loja pra atualização automática (a cada 20 dias) não apagar o que ela
/// digitou, e funciona também pra locais avulsos. O endereço não é editável.
@Model
final class ContatoDoLocal {
    var chaveDoLocal: String
    var telefone: String?
    var site: String?

    init(chaveDoLocal: String, telefone: String?, site: String?) {
        self.chaveDoLocal = chaveDoLocal
        self.telefone = telefone
        self.site = site
    }
}
