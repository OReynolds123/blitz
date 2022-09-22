//
//  webView.swift
//  blitz
//
//  Created by Owen Reynolds on 9/20/22.
//

import SwiftUI
import WebKit

struct webView: View {
    var content: String
    
    var body: some View {
        Text(content)
    }
    
    func parseContent(content: String) {
        
    }
}

struct webViewTMP: NSViewRepresentable {
    var html: String
    var webViewHeightConstraint = 0.0
    let htmlStart = "<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"><style>html,body { margin: 0 auto; padding: 0; width: 100%; -webkit-tap-highlight-color: transparent; -webkit-font-smoothing: antialiased; scroll-behavior: smooth; font-family: system-ui; font-weight: 300; font-size: 18px; color: black; background-color: white; } html { height: 100%; border: 1px solid black; } body { width: 100%; height: 100%; display: block; background:#00000033; text-align: center; }</style></head><body>"
    let htmlEnd = "</body></html>"

    func makeNSView(context: Context) -> WKWebView {
//        let view = WKWebView()
//        view.autoresizingMask = [.width, .height]
//        return view
        return WKWebView()
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString("\(htmlStart)\(html)\(htmlEnd)", baseURL: nil)
        nsView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
            print(height ?? -1)
        })
    }
}


struct webView_Previews: PreviewProvider {
    static var previews: some View {
        webView(content: "Test")
    }
}
