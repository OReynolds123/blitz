//
//  user.swift
//  blitz
//
//  Created by Owen Reynolds on 10/4/22.
//

import Foundation


struct user: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    var decks: [deck]
    var deckIndex: Int
    var initialLaunch: Bool

    init(id: UUID = UUID(), name: String = "", decks: [deck] = [deck.example], initialLaunch: Bool = true) {
        self.id = id
        self.name = name
        self.decks = decks
        self.deckIndex = 0
        self.initialLaunch = initialLaunch
    }
    
    mutating func append(deck: deck) {
        self.decks.append(deck)
    }
    
    mutating func changeIndex(index: Int) {
        self.deckIndex = index
    }
    
    func getDeck() -> deck {
        return self.decks[self.deckIndex]
    }
}

class userStore: ObservableObject {
    @Published var userData: user = user()
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("user.data")
    }
        
    static func load(completion: @escaping (Result<user, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success(user()))
                    }
                    return
                }
                let userData = try JSONDecoder().decode(user.self, from: file.availableData)
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
    
    static func save(user: user, completion: @escaping (Result<UUID, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(user)
                let outfile = try fileURL()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(user.id))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
