//
//  webView.swift
//  blitz
//
//  Created by Capstone on 9/20/22.
//

import SwiftUI
import WebKit

struct webView: NSViewRepresentable {
    var html: String
    
    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        //html = "<div style=\"text-align: center\">" + html + "</div>"
        nsView.loadHTMLString(html, baseURL: nil)
    }
}

struct webView_Previews: PreviewProvider {
    static var previews: some View {
        webView(html: "test")
    }
}
