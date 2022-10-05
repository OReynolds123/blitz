//
//  deckCreationView.swift
//  blitz
//
//  Created by Owen Reynolds on 9/23/22.
//

import SwiftUI
import Foundation
import Vision

// Create a Deck
struct deckCreation: View {
    @StateObject private var userDataStore = userStore()
    
    var width: CGFloat
    @State var index: Int
    @Binding var creationPresented: Bool
    @Binding var testPresented: Bool
    
    private var padding: CGFloat = 7.0

    @State private var deckTitle: String = ""
    @State private var deckCards: [card] = []
    
    @State private var scrollIndex: Int?
    @State private var height: CGFloat
    
    init(width: CGFloat = 450, index: Int, creationPresented: Binding<Bool>, testPresented: Binding<Bool>) {
        self.width = width
        self.height = self.width * (3/5)
        self.index = index
        self._creationPresented = creationPresented
        self._testPresented = testPresented
    }
        
    var body: some View {
        NavigationView {
            VStack {
                Label("Home", systemImage: "house")
                    .foregroundColor(Color(NSColor.headerTextColor))
                    .padding(.top, 15)
                    .padding(.bottom, 5)
                    .onTapGesture {
                        self.creationPresented = false
                        self.testPresented = false
                    }
                
                Divider().padding(.horizontal, 20)
                
                List {
                    Label(self.deckTitle == "" ? "Deck Title" : self.deckTitle, systemImage: "home")
                        .onTapGesture {
                            self.scrollIndex = 0
                        }

                    ForEachIndexed(self.$deckCards) { index, elem in
                        Label(elem.wrappedValue.front == "" ? "Card \(index + 1)" : elem.wrappedValue.front, systemImage: "")
                            .onTapGesture {
                                self.scrollIndex = index + 1
                            }
                    }

                    Label("New Card", systemImage: "")
                        .onTapGesture {
                            self.deckCards.append(card())
                        }
                }

                Spacer()
                
                Divider().padding(.horizontal, 20)

                Label("Delete", systemImage: "")
                    .foregroundColor(Color(NSColor.systemRed))
                    .padding(.vertical, 5)
                    .onTapGesture {
                        self.creationPresented = false
                        self.testPresented = false
                        self.userDataStore.userData.decks.remove(at: self.index)
                        userStore.save(user: self.userDataStore.userData) { result in
                            switch result {
                            case .failure(let error):
                                fatalError(error.localizedDescription)
                            case .success(let uuid):
                                print(uuid)
                            }
                        }
                    }
                    
                Label("Save", systemImage: "")
                    .foregroundColor(Color(NSColor.linkColor))
                    .padding(.bottom, 15)
                    .onTapGesture {
                        self.creationPresented = false
                        self.testPresented = true
                        self.userDataStore.userData.decks[self.index].title = self.deckTitle
                        self.userDataStore.userData.decks[self.index].cards = self.deckCards
                        userStore.save(user: self.userDataStore.userData) { result in
                            switch result {
                            case .failure(let error):
                                fatalError(error.localizedDescription)
                            case .success(let uuid):
                                print(uuid)
                            }
                        }
                    }
            }

            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: true) {
                    ScrollViewReader { (proxy: ScrollViewProxy) in
                        // Title Card
                        titleCardEdit(text: self.$deckTitle, width: self.width)
                            .padding(.horizontal)
                            .padding(.vertical, self.padding)
                            .padding(.top, 20)
                            .id(0)

                        // Cards
                        ForEachIndexed(self.$deckCards) { index, elem in
                            normalCardEdit(cardArr: self.$deckCards, card: elem, width: self.width)
                                .padding(.horizontal)
                                .padding(.vertical, self.padding)
                                .id(index + 1)
                        }
                        .onChange(of: self.scrollIndex) { target in
                            if let target = target {
                                self.scrollIndex = nil
                                withAnimation {
                                    proxy.scrollTo(target, anchor: .center)
                                }
                            }
                        }

                        // Spacer
                        Rectangle()
                            .foregroundColor(Color.clear)
                            .frame(width: geo.size.width - 0, height: CGFloat(geo.size.height - CGFloat((self.height + CGFloat(2 * self.padding) + 8) * CGFloat(self.deckCards.count + 1)) - 60 - 35))

                        // Add Card
                        addCardEdit(width: self.width)
                            .padding(.horizontal)
                            .padding(.vertical, self.padding)
                            .frame(height: 60, alignment: .top)
                            .onTapGesture {
                                self.deckCards.append(card())
                            }
                    }
                }
                .frame(width: geo.size.width)
            }
        } // nav
        .onAppear {
            userStore.load { result in
                switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success(let userData):
                    self.userDataStore.userData = userData
                    self.deckTitle = self.userDataStore.userData.decks[self.index].title
                    self.deckCards = self.userDataStore.userData.decks[self.index].cards
                }
            }
        }
    } // body
}

struct deckCreation_Previews: PreviewProvider {
    static var previews: some View {
        deckCreation(index: 0, creationPresented: .constant(true), testPresented: .constant(false))
    }
}


// Title Card Edit View
struct titleCardEdit: View {
    @Binding var text : String
    var width: CGFloat = 450
    
    var body: some View {
        let elem = AnyView(
            CustomTextEditor(width: self.width, text: self.$text, placeholder: "Deck Title")
                .padding()
        )
        cardStruct(elem: elem, width: self.width)
    }
}

// Normal Card Edit View
struct normalCardEdit: View {
    @Binding var cardArr: [card]
    @Binding var card: card
    var width: CGFloat = 450
    
    @State private var press: Bool = false
    @State private var hover: Bool = false
    
    @State private var cameraBtnHover = false
    @State private var trashBtnHover = false
    @State private var backBtnHover = false
    
    var body: some View {
        let elem = AnyView(
            ZStack {
                if !self.press {
                    CustomTextEditor(width: self.width, text: self.$card.front, placeholder: "Front", fontSize: 20.0)
                        .padding()
                        .animation(.none)
                } else {
                    CustomTextEditor(width: self.width, text: self.$card.back, placeholder: "Back", fontSize: 20.0)
                        .padding()
                        .rotation3DEffect(.degrees(self.press ? 180 : 0), axis: (x: -1, y: 0, z: 0))
                        .animation(.none)
                }
                
                // Edit Options
                VStack(alignment: .center) {
                    HStack(alignment: .top) {
                        Spacer()
                        
                        HStack(alignment: .top) {
                            if self.cameraBtnHover {
                                Text("Insert Text")
                            }
                            
                            Image(systemName: "camera.fill")
                                .frame(width: 15, height: 15, alignment: .center)
                                .foregroundColor(Color(NSColor.secondaryLabelColor))
                        }
                        .onHover { hover in
                            self.cameraBtnHover = hover
                        }
                    }
                    .onTapGesture {  filePicker() }
                    
                    Spacer()
                    
                    HStack(alignment: .bottom) {
                        HStack(alignment: .bottom) {
                            Image(systemName: "trash.fill")
                                .frame(width: 15, height: 15, alignment: .center)
                                .foregroundColor(Color(NSColor.systemRed))
                            
                            if self.trashBtnHover {
                                Text("Remove Card")
                            }
                        }
                        .onHover { hover in
                            self.trashBtnHover = hover
                        }
                        .onTapGesture {
                            if let index = self.cardArr.firstIndex(of: self.card) {
                                self.cardArr.remove(at: index)
                            }
                        }
                        
                        Spacer()
                        
                        HStack(alignment: .bottom) {
                            if self.backBtnHover {
                                Text(self.press ? "Edit Front" : "Edit Back")
                            }
                            
                            Image(systemName: "arrowshape.turn.up.right.fill")
                                .frame(width: 15, height: 15, alignment: .center)
                                .foregroundColor(Color(NSColor.secondaryLabelColor))
                        }
                        .onHover { hover in
                            self.backBtnHover = hover
                        }
                        .onTapGesture { self.press.toggle() }
                    }
                }
                .padding(14)
                .frame(width: self.width)
                .rotation3DEffect(.degrees(self.press ? 180 : 0), axis: (x: -1, y: 0, z: 0))
            }
        )
        cardView_noBindings(elem: elem, width: self.width, press: self.$press, hover: self.$hover)
    }
    
    private func filePicker() {
        let openPanel = NSOpenPanel()
        openPanel.prompt = "Select photo"
        openPanel.worksWhenModal = true
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["png","jpg","jpeg"]
        openPanel.begin { (result) -> Void in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                // Load image
                let image = NSImage(contentsOfFile: openPanel.url!.path)!
                if image.size.width == 0 {
                    return
                }
                
                // Setup live text request
                let request = VNRecognizeTextRequest { (request, error) in
                    guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                    
                    var ocrText = ""
                    for observation in observations {
                        guard let topCandidate = observation.topCandidates(1).first else { continue }
                        ocrText += topCandidate.string + " "
                    }
                    
                    DispatchQueue.main.async {
                        if !self.press {
                            self.card.front = self.card.front + ocrText
                        } else {
                            self.card.back = self.card.back + ocrText
                        }
                    }
                }
                request.recognitionLevel = .accurate
                request.recognitionLanguages = ["en-US"]
                request.usesLanguageCorrection = true
                
                // Do request
                DispatchQueue.main.async {
                    let requestHandler = VNImageRequestHandler(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!, options: [:])
                    do {
                        try requestHandler.perform([request])
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}

// Add Card View
struct addCardEdit: View {
    var width: CGFloat = 450
    
    @State private var hover: Bool = false
    
    var body: some View {
        let elem = AnyView(
            Text("Add Card")
                .font(.title)
                .foregroundColor(Color.blue)
                .offset(x: 0, y: -(self.width / 4))
        )
        cardStruct(elem: elem, width: self.width)
            .onHover { hover in self.hover = hover }
            .offset(x: 0, y: self.hover ? -10 : 0)
            .scaleEffect(self.hover ? 1.01 : 1)
            .animation(.interpolatingSpring(stiffness: 180, damping: 100))
    }
}


// Custom Text Editor
struct CustomTextEditor: View {
    var width: CGFloat
    @Binding var text: String
    var placeholder: String
    var fontSize: CGFloat
    
    @State private var height: CGFloat
    @State private var textEditorHeight: CGFloat

    init(width: CGFloat = 450, text: Binding<String>, placeholder: String = "", fontSize: CGFloat = 40.0) {
        self.width = width
        self.height = (self.width * (3/5)) - 75
        self._text = text
        self.placeholder = placeholder
        self.fontSize = fontSize
        self.textEditorHeight = fontSize + 17
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            ZStack() {
                if (self.text.isEmpty) {
                    Text(self.placeholder)
                        .font(.system(size: self.fontSize))
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                        .padding(5)
                        .offset(x: 0, y: 0)
                        .multilineTextAlignment(.center)
                }
                TextEditor(text: self.$text)
                    .font(.system(size: self.fontSize))
                    .foregroundColor(Color(NSColor.textColor))
                    .padding(5)
                    .offset(x: 0, y: 0) // x: 8
                    .multilineTextAlignment(.center)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onChange(of: self.text, perform: {_ in
                                    self.textEditorHeight = geo.size.height
                                })
                        }
                    )
                    .overlay(coverScrollOverlay, alignment: .trailing)
            }
        }
        .frame(height: min(self.textEditorHeight, self.height))
    }
    
    private var coverScrollOverlay: some View {
        Rectangle()
            .frame(width: 20)
            .foregroundColor(Color(NSColor.windowBackgroundColor))
    }
}
extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear
            drawsBackground = true
        }
    }
}

// Custom ForEach with Binding
struct ForEachIndexed<Data: MutableCollection&RandomAccessCollection, RowContent: View, ID: Hashable>: View, DynamicViewContent where Data.Index : Hashable
{
    var data: [(Data.Index, Data.Element)] {
        forEach.data
    }
    
    let forEach: ForEach<[(Data.Index, Data.Element)], ID, RowContent>
    
    init(_ data: Binding<Data>,
         @ViewBuilder rowContent: @escaping (Data.Index, Binding<Data.Element>) -> RowContent
    ) where Data.Element: Identifiable, Data.Element.ID == ID {
        forEach = ForEach(
            Array(zip(data.wrappedValue.indices, data.wrappedValue)),
            id: \.1.id
        ) { i, _ in
            rowContent(i, Binding(get: { data.wrappedValue[i] }, set: { data.wrappedValue[i] = $0 }))
        }
    }
    
    init(_ data: Binding<Data>,
         id: KeyPath<Data.Element, ID>,
         @ViewBuilder rowContent: @escaping (Data.Index, Binding<Data.Element>) -> RowContent
    ) {
        forEach = ForEach(
            Array(zip(data.wrappedValue.indices, data.wrappedValue)),
            id: (\.1 as KeyPath<(Data.Index, Data.Element), Data.Element>).appending(path: id)
        ) { i, _ in
            rowContent(i, Binding(get: { data.wrappedValue[i] }, set: { data.wrappedValue[i] = $0 }))
        }
    }
    
    var body: some View {
        forEach
    }
}
