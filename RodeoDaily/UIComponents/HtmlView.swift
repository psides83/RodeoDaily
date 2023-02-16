//
//  HtmlView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/13/23.
//

import WebKit
import SwiftUI

struct HtmlView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
