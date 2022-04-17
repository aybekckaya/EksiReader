//
//  UIImageCacheExtension.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 4.03.2022.
//

import Foundation
import UIKit
import Kingfisher

// MARK: - ImageView Builder Size
enum ImageViewOptionsSize {
    case constant(value: CGSize)
    case imageViewBounds
}

// MARK: - ImageView Builder Options
class ImageViewOptionsBuilder {
    private var url: URL?
    private var downSamplingSize: ImageViewOptionsSize?
    private var shouldCacheOriginalImage: Bool = false
    private var isBackgroundDecodeEnabled: Bool = false
    private var imageLoadedClosure: (() -> ())?

    @discardableResult
     func downSample(_ size: ImageViewOptionsSize) -> Self {
        self.downSamplingSize = size
        return self
    }

    @discardableResult
     func cacheOriginalImage(_ value: Bool) -> Self {
        self.shouldCacheOriginalImage = value
        return self
    }

    @discardableResult
     func decodeInBackground(_ value: Bool) -> Self {
        self.isBackgroundDecodeEnabled = value
        return self
    }

    @discardableResult
     func url(_ url: URL?) -> Self {
        self.url = url
        return self
    }

    @discardableResult
     func url(path: String) -> Self {
        self.url(URL(string: path))
        return self
    }

    @discardableResult
    func imageLoaded(_ closure: @escaping ()->()) -> Self {
        self.imageLoadedClosure = closure
        return self
    }

    fileprivate func setImage(with imageView: UIImageView) {
        guard let url = url else {
            return
        }
        var options: [KingfisherOptionsInfoItem] = []
        if isBackgroundDecodeEnabled {
            options.append(.backgroundDecode)
        }

        if shouldCacheOriginalImage {
            options.append(.cacheOriginalImage)
        }

        if let downsamplingSize = downSamplingSize {
            var size: CGSize = .zero
            switch downsamplingSize {
            case .constant(let value):
                size = value
            case .imageViewBounds:
                size = imageView.bounds.size
            }

            let downSamplingProcessor = DownsamplingImageProcessor(size: size)
            let processor = KingfisherOptionsInfoItem.processor(downSamplingProcessor)

            options.append(processor)
        }

        imageView
            .kf
            .setImage(with: url, placeholder: nil, options: options) { [weak self] result in
                guard let imageLoadedClosure = self?.imageLoadedClosure else {
                    return
                }
                imageLoadedClosure()
            }
    }

}

// MARK: - Manager Actions
extension UIImageView {
    static func clearCache() {
        ImageCache.default.clearCache()
    }
}

// Options : KingfisherOptionsInfoItem
// https://github.com/onevcat/Kingfisher/wiki/Cheat-Sheet#prefetch

// MARK: - Set Image (Single Methods)
extension UIImageView {
    enum CachedType {
        case none
        case memory
        case disk

        var debugDescription: String {
            switch self {
            case .none:
                return "No Cache"
            case .memory:
                return "Cached Memory"
            case .disk:
                return "Cached Disk"
            }
        }
    }

    func setImage(with urlPath: String?) {
        guard
            let urlPath = urlPath,
            let url = URL(string: urlPath)
        else {
            return
        }
        setImage(with: url)
    }

    func setImage(with url: URL?) {
        let builder = ImageViewOptionsBuilder()
            .url(url)
        self.setImage(with: builder)
    }

    func setImage(with builder: ImageViewOptionsBuilder) {
        builder.setImage(with: self)
    }

    static func cacheType(_ urlPath: String) -> UIImageView.CachedType {
        let type = ImageCache.default.imageCachedType(forKey: urlPath)

        switch type {
        case .none:
            return .none
        case .disk:
            return .disk
        case .memory:
            return .memory
        }
    }
}


// MARK: - UINavigation Bar
extension UINavigationBar {

}
