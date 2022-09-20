//
//  ContentView.swift
//  Alpha_macOS
//
//  Created by Capstone on 9/12/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: alpha()) {
                    Text("LiveText API")
                        .frame(width: 150)
                }
                NavigationLink(destination: flashcardDeck()) {
                    Text("Flashcard")
                        .frame(width: 150)
                }
            }
            .frame(minWidth: 180, idealWidth: 180, maxWidth: 180, maxHeight: .infinity)
            
        }
        .navigationTitle("Alpha Demo")
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 600, height: 600)
    }
}
