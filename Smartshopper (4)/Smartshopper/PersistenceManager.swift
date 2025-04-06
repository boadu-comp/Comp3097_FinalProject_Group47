//
//  PersistenceManager.swift
//  Smartshopper
//
//  Created by Bakim Boadu on 2025-04-03.
//

import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private init() {}
    
    // URL to store the JSON file in the documents directory
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("data.json")
    }
    
    // Save any Codable data to file
    func saveData<T: Codable>(_ data: T) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            try? encoded.write(to: fileURL)
        }
    }
    
    // Load any Codable data from file
    func loadData<T: Codable>(as type: T.Type) -> T? {
        let decoder = JSONDecoder()
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? decoder.decode(T.self, from: data) {
            return decoded
        }
        return nil
    }
}
