//
//  PickerEstado.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 02/10/26.
//

import SwiftUI

struct PickerEstado< T : Hashable & RawRepresentable>: View {
    let titulo: String
    @Binding var estado: T?
    let estados: [T]
    init(_ titulo: String, _ estado: Binding<T?>, estados: [T]) {
        self.titulo = titulo
        self._estado = estado
        self.estados = estados
    }
    var body: some View {
        Picker(titulo, selection: $estado) {
            Text(estado != nil ?
                 "Remover Estado" : "Selecionar").tag(nil as T?)
            
            Divider()
            
            ForEach(estados, id: \.self) { estado in
                if let rawValue = estado.rawValue as? Int {
                    Text(EstadoCapa(rawValue: rawValue).flatMap { titleEstados[$0] } ?? "").tag(estado)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
        }
    }
}
