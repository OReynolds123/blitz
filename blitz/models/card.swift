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
        card(front: "Edit this text and flip to the back of the card\n(Press the flip icon in the bottom right of the card)", back: "Edit this text too and continue with the tutorial!")
    }
    static var example1: card {
        card(front: "Now delete this card\n(Press the trash icon in the bottom left of the card)", back: "Hmmmm. You haven't deleted it yet")
    }
    static var example2: card {
        card(front: "Next, use the Photo-To-Text button to insert text from your photos!\n(Press the camera icon in the top right of the card)", back: "Great Job!")
    }
    static var example3: card {
        card(front: "Lastly, create a new card\n(Press the 'Add Card' button at the bottom of the screen or the 'New Card' button in the navigation bar on the left)", back: "Well done! Now you can start creating and studying your own decks!")
    }
}
