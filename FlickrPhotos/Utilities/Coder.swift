//
//  Coder.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 20.07.2024.
//

import Foundation

class Coder {
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(encoder: JSONEncoder = .init(),
         decoder: JSONDecoder = .init()){
        self.decoder = decoder
        self.encoder = encoder
    }
    
    func encode<T>(_ data: T,
                   fileName: String = #file,
                   line: UInt = #line) throws -> Data where T: Codable {
        do {
            return try encoder.encode(data)
        } catch {
            print("\n--- File: \(fileName).\nLine: \(line).\nDecoding error: \(error.localizedDescription)")
            throw error
        }
    }
    func decode<O, T>(_ object: O,
                      fileName: String = #file,
                      line: UInt = #line) throws -> T where O: Codable, T: Codable {
        do {
            let data = try JSONSerialization.data(withJSONObject: object,
                                                  options: .prettyPrinted)
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            print("\n--- File: \(fileName).\nLine: \(line).\nDecoding error: \(error.localizedDescription)")
            throw error
        }
    }
}
