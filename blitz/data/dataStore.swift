//
//  dataStore.swift
//  blitz
//
//  Created by Capstone on 9/23/22.
//

import Foundation
import SwiftUI

// https://developer.apple.com/tutorials/app-dev-training/persisting-data

class dataStore: ObservableObject {
    @Published var currUser: [user] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                       in: .userDomainMask,
                                       appropriateFor: nil,
                                       create: false)
            .appendingPathComponent("user.data")
    }
    
    static func load(completion: @escaping (Result<[user], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let userData = try JSONDecoder().decode([user].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(userData))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func save(user: [user], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(user)
                let outfile = try fileURL()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(user.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
