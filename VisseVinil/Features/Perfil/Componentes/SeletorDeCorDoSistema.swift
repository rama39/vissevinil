//
//  SeletorDeCorDoSistema.swift
//  VisseVinil
//

import SwiftUI
import UIKit

/// O seletor de cor do iOS (grade, espectro, controles e conta-gotas), pra abrir numa sheet.
/// É o mesmo que o ColorPicker abre, mas deixa o botão que o chama ter o visual das outras
/// amostras de cor.
struct SeletorDeCorDoSistema: UIViewControllerRepresentable {
    let titulo: String
    @Binding var cor: Color
    let fechar: () -> Void

    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let seletor = UIColorPickerViewController()
        seletor.title = titulo
        seletor.supportsAlpha = false
        seletor.selectedColor = UIColor(cor)
        seletor.delegate = context.coordinator
        return seletor
    }

    func updateUIViewController(_ seletor: UIColorPickerViewController, context: Context) {
        context.coordinator.pai = self
    }

    func makeCoordinator() -> Coordenador { Coordenador(pai: self) }

    final class Coordenador: NSObject, UIColorPickerViewControllerDelegate {
        var pai: SeletorDeCorDoSistema

        init(pai: SeletorDeCorDoSistema) { self.pai = pai }

        func colorPickerViewController(_ seletor: UIColorPickerViewController,
                                       didSelect cor: UIColor, continuously: Bool) {
            pai.cor = Color(uiColor: cor)
        }

        // X do próprio seletor
        func colorPickerViewControllerDidFinish(_ seletor: UIColorPickerViewController) {
            pai.fechar()
        }
    }
}
