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
    var quiz_passed: Bool
    var quiz_failed: Bool
    var test_passed: Bool
    var test_failed: Bool
    
    init(id: UUID = UUID(), front: String = "", back: String = "") {
        self.id = id
        self.front = front
        self.back = back
        self.quiz_passed = false
        self.quiz_failed = false
        self.test_passed = false
        self.test_failed = false
    }
    
    mutating func quizPassed() {
        self.quiz_passed = true
        self.quiz_failed = false
    }
    mutating func quizFailed() {
        self.quiz_passed = false
        self.quiz_failed = true
    }
    
    mutating func testPassed() {
        self.test_passed = true
        self.test_failed = false
    }
    mutating func testFailed() {
        self.test_passed = false
        self.test_failed = true
    }
      
    static var example: card {
        card(front: "Who is the longest serving US president?", back: "FDR")
    }
    static var example1: card {
        card(front: "Who is the shortest serving US president?", back: "William Henry Harrison")
    }
}
