//
//  getThumb.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 19/09/26.
//

import Foundation

func getThumb(thumb: String?) async -> Data? {
    guard let thumb else { return nil }
    guard let url = URL(string: thumb) else { return nil }
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    } catch {
        return nil
    }
}
