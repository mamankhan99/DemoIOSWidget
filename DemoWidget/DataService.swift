//
//  DataService.swift
//  DemoWidgetExtension
//
//  Created by Maman Khan on 01/08/2024.
//

import Foundation
import Network

struct Posts: Decodable {
    let id: Decimal
    let title: String
}


struct TariffEntries: Decodable {
    let start: String
    let end: String
    let price: Decimal
    var isCheapest: Bool?
}

enum DataServiceError: Error {
  case invalidURL
  case invalidData
  case invalidResponse
}

final class DataService {
    static let shared = DataService()

    // Call the Dynamic Tariff API and get the data
    func fetchData() async throws -> [Posts] {
        let Url = "https://my-json-server.typicode.com/mamankhan99/demoioswidget/posts"
        guard let url = URL(string: Url) else {
            throw DataServiceError.invalidURL
        }

        let request = URLRequest(url: url)

        let (data, _) = try await URLSession.shared.data(for: request)

        do {
            return try JSONDecoder().decode([Posts].self, from: data)
        } catch {
            throw DataServiceError.invalidData
        }
    }
}
