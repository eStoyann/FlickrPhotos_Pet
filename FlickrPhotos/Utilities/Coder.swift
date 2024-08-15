//
//  Coder.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 20.07.2024.
//

import Foundation

class Coder {
    func encode<T>(_ data: T,
                   fileName: String = #file) throws -> Data where T: Codable {
        do {
            return try JSONEncoder().encode(data)
        } catch {
            print("\n--- \(fileName). Encoding error: \(error.localizedDescription)")
            throw error
        }
    }
    func decode<O, T>(_ object: O,
                      fileName: String = #file) throws -> T where O: Codable, T: Codable {
        do {
            let data = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
            
        } catch {
            print("\n--- \(fileName). Decoding error: \(error.localizedDescription)")
            throw error
        }
    }
}
