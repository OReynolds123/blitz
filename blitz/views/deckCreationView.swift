//
//  deckCreationView.swift
//  blitz
//
//  Created by Owen Reynolds on 9/23/22.
//

import SwiftUI
import Foundation
import Vision

struct deckCreation: View {
    var width: CGFloat = 450
    @StateObject var userDataStore: userStore
    @StateObject var viewManager: viewsManager
    
    @State private var padding: CGFloat = 7.0
    @State private var space: CGFloat = 0.0
    
    @State private var scrollIndex: Int?
    @State private var height: CGFloat = 0.0
        
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    self.scrollIndex = 0
                }, label: {
                    Text(self.userDataStore.userData.getDeck().title == "" ? "Deck Title" : self.userDataStore.userData.getDeck().title)
                        .foregroundColor(Color("nav_titleColor"))
                        .fontWeight(.semibold)
                        .font(.title3)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                })
                .padding(.horizontal)
                .buttonStyle(PlainButtonStyle())
                .help("Scroll to Top")
                
                Divider().padding(.horizontal, 20)
                
                List {
                    ForEachIndexed(self.$userDataStore.userData.decks[self.userDataStore.userData.deckIndex].cards) { index, elem in
                        Button(action: {
                            self.scrollIndex = index + 1
                        }, label: {
                            Text(elem.wrappedValue.front == "" ? "Card \(index + 1)" : elem.wrappedValue.front)
                                .foregroundColor(Color("nav_textColor"))
                                .fontWeight(.medium)
                        })
                        .buttonStyle(PlainButtonStyle())
                    }

                    Button(action: {
                        self.addCard()
                    }, label: {
                        Text("New Card")
                            .foregroundColor(Color("nav_altColor"))
                    })
                    .buttonStyle(PlainButtonStyle())
                    .help("Add New Card")
                }
                .padding(.horizontal)

                Spacer()
                
                Divider().padding(.horizontal, 20)
                
                Button(action: {
                    self.exit()
                    self.viewManager.views.deleteAlert = true
                }, label: {
                    Text("Delete")
                        .foregroundColor(Color("nav_deleteColor"))
                        .padding(.vertical, 5)
                })
                .buttonStyle(PlainButtonStyle())
                .help("Delete the Deck")
                
                Button(action: {
                    self.exit()
                    self.viewManager.views.fullView = true
                }, label: {
                    Text("Close")
                        .foregroundColor(Color("nav_saveColor"))
                        .padding(.bottom, 15)
                })
                .buttonStyle(PlainButtonStyle())
                .help("Close the Deck")
            } // vstack
            .background(Color("nav_bkg"))

            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: true) {
                    ScrollViewReader { (proxy: ScrollViewProxy) in
                        // Title Card
                        titleCardEdit(text: self.$userDataStore.userData.decks[self.userDataStore.userData.deckIndex].title, width: self.width)
                            .padding(.horizontal)
                            .padding(.vertical, self.padding)
                            .padding(.top, 20)
                            .id(0)

                        // Cards
                        ForEachIndexed(self.$userDataStore.userData.decks[self.userDataStore.userData.deckIndex].cards) { index, elem in
                            normalCardEdit(cardArr: self.$userDataStore.userData.decks[self.userDataStore.userData.deckIndex].cards, card: elem, width: self.width)
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
                        Color.clear
                            .frame(width: geo.size.width, height: CGFloat(geo.size.height - (self.space * CGFloat(self.userDataStore.userData.decks[self.userDataStore.userData.deckIndex].cards.count + 1)) - 95))

                        // Add Card
                        addCardEdit(width: self.width)
                            .padding(.horizontal)
                            .padding(.vertical, self.padding)
                            .frame(height: 60, alignment: .top)
                            .onTapGesture {
                                self.addCard()
                            }
                    }
                }
                .frame(width: geo.size.width)
            }
        } // nav
        .touchBar() {
            Button(action: {
                self.addCard()
            }, label: {
                Label("Add Card", systemImage: "plus")
            })
            
            Button(action: {
                self.exit()
                self.viewManager.views.deleteAlert = true
            }, label: {
                Label("Delete Deck", systemImage: "trash")
            })
            .foregroundColor(Color("nav_deleteColor"))
            
            Button(action: {
                self.exit()
                self.viewManager.views.fullView = true
            }, label: {
                Text("Close")
            })
            .foregroundColor(Color("nav_saveColor"))
        }
        .background(Color("windowBkg"))
        .onAppear {
            self.height = self.width * (3/5)
            self.space = CGFloat((self.width * (3/5)) + CGFloat(2 * self.padding) + 8)
        }
        .onExitCommand {
            self.exit()
        }
    } // body
    
    private func saveUserData() {
        userStore.save(user: self.userDataStore.userData) { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let uuid):
                print(uuid)
            }
        }
    }
    
    private func exit() {
        self.saveUserData()
        self.viewManager.views.creationView = false
    }
    
    private func addCard() {
        self.userDataStore.userData.decks[self.userDataStore.userData.deckIndex].cards.append(card())
        self.scrollIndex = self.userDataStore.userData.decks[self.userDataStore.userData.deckIndex].cards.count
        self.saveUserData()
    }
}

struct deckCreation_Previews: PreviewProvider {
    static var previews: some View {
        deckCreation(userDataStore: userStore(), viewManager: viewsManager())
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
                } // vstack
                .padding(14)
                .frame(width: self.width)
                .rotation3DEffect(.degrees(self.press ? 180 : 0), axis: (x: -1, y: 0, z: 0))
            } // zstack
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
                if let imgurl = openPanel.url {
                    if let image = NSImage(contentsOfFile: imgurl.path) {
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
                            if let cgimg = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                                let requestHandler = VNImageRequestHandler(cgImage: cgimg, options: [:])
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
        self.textEditorHeight = fontSize + 17 // 17
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.text = self.text + " "
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.text = String(self.text.dropLast())
                }
            }
        }
    }
    
    private var coverScrollOverlay: some View {
        Rectangle()
            .frame(width: 14)
            .foregroundColor(Color("defaultCardBkgColor"))
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
