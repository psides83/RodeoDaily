//
//  VimeoPlayer.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/3/24.
//

import SwiftUI
import WebKit

struct VimeoPlayer: UIViewRepresentable {
    let video: String?
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let hasVideo = video {
            let request = URLRequest(url: URL(string: "https://player.vimeo.com\(hasVideo)")!)
            
            webView.load(request)
        }
    }
}
