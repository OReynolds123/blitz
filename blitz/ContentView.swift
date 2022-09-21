//
//  ContentView.swift
//  blitz
//
//  Created by Owen Reynolds on 9/12/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: blitzHomeView().navigationTitle("Home")) {
                    Label("Home", systemImage: "house")
                }
            }
            blitzHomeView()
                .navigationTitle("Blitz")
        }
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 600, height: 600)
    }
}