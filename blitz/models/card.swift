//
//  card.swift
//  blitz
//
//  Created by Owen Reynolds on 9/20/22.
//

import SwiftUI


struct card: Codable, Identifiable, Hashable {
    let id: UUID
    var front: String
    var back: String
    
    init(id: UUID = UUID(), front: String = "", back: String = "") {
        self.id = id
        self.front = front
        self.back = back
    }
      
    static var example: card {
        card(front: "Who is the longest serving US president?", back: "FDR")
    }
    static var example1: card {
        card(front: "Who is the shortest serving US president?", back: "William Henry Harrison")
    }
}
