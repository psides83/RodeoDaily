//
//  AthleteImage.swift
//  RodeoDaily
//
//  Created by Payton Sides on 5/14/26.
//

import SwiftUI

enum AthleteImage {
    static let noImageUrl = URL(string: "https://pub-a255663807414f4298a369bfdb29c598.r2.dev/no-image/noimage.png")
    static let prcaImageUrlKeys = [
        "image_315_url",
        "Image315Url",
        "PhotoUrl",
        "photo_url",
        "SidearmPhotoUrl",
        "sidearm_photo_url"
    ]

    static func url(preferredImageUrl: String?, fallbackImageUrl: String? = nil) -> URL? {
        let imageUrl = firstValidImageUrl(preferredImageUrl, fallbackImageUrl)
        guard let imageUrl else { return nil }

        if let absoluteUrl = URL(string: imageUrl), absoluteUrl.scheme != nil {
            return absoluteUrl
        }

        return URL(string: "https://d1kfpvgfupbmyo.cloudfront.net\(imageUrl)?width=315&height=315&mode=crop&scale=both&anchor=topcenter")
    }

    private static func firstValidImageUrl(_ imageUrls: String?...) -> String? {
        imageUrls
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }
}

struct AthleteImageView<Placeholder: View>: View {
    let preferredImageUrl: String?
    let fallbackImageUrl: String?
    let width: CGFloat?
    let height: CGFloat?
    let cornerRadius: CGFloat?
    let placeholder: () -> Placeholder

    init(
        preferredImageUrl: String?,
        fallbackImageUrl: String? = nil,
        width: CGFloat? = 48,
        height: CGFloat? = 48,
        cornerRadius: CGFloat? = 12,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.preferredImageUrl = preferredImageUrl
        self.fallbackImageUrl = fallbackImageUrl
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.placeholder = placeholder
    }

    var body: some View {
        let image = AsyncImage(url: AthleteImage.url(preferredImageUrl: preferredImageUrl, fallbackImageUrl: fallbackImageUrl) ?? AthleteImage.noImageUrl) { image in
            image.resizable()
        } placeholder: {
            placeholder()
        }
        .frame(width: width, height: height)

        if let cornerRadius {
            image.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            image
        }
    }
}

extension AthleteImageView where Placeholder == Image {
    init(
        preferredImageUrl: String?,
        fallbackImageUrl: String? = nil,
        width: CGFloat? = 48,
        height: CGFloat? = 48,
        cornerRadius: CGFloat? = 12
    ) {
        self.preferredImageUrl = preferredImageUrl
        self.fallbackImageUrl = fallbackImageUrl
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        placeholder = {
            Image.noImage.resizable()
        }
    }
}
