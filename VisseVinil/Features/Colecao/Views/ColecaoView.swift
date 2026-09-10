//
//  ColecaoView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI

//var names = ["a", "b", "c", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l"]

struct ColecaoView: View {
//    @State var addingName = false
//    @State var newName: String = ""
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        /*NavigationStack {
            List {
                ForEach(names, id: \.self) { name in
                    Text(name)
                }
            }
            .navigationTitle("Prateleira Rock")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem {
                    Button {
                        newName = ""
                        addingName = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $addingName) {
                HStack {
                    TextField("Nome do sla", text: $newName)
                    Button(role:.confirm) {
                        if !newName.isEmpty {
                            names.append(newName)
                        }
                        addingName = false
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }.padding()
                .presentationDetents([.fraction(0.2)])
            }
        }*/
    }
}

#Preview {
    ColecaoView()
}
