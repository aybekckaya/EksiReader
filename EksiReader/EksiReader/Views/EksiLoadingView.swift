//
//  EksiLoadingView.swift
//  EksiReader
//
//  Created by aybek can kaya on 11.04.2022.
//

import Foundation
import UIKit
import Lottie

class EksiLoadingView: UIView {

    private let bgView = UIVisualEffectView
        .visualEffectView()
        .blurEffect(.regular)
        .backgroundColor(.black.withAlphaComponent(0.2))
        .asVisualEffectsView()

    private let contentView = UIView
        .view()
        .backgroundColor(.white.withAlphaComponent(0.1))
        .roundCorners(by: 4, maskToBounds: true, maskedCorners: nil)


    init() {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        bgView
            .add(into: self)
            .fit()

        contentView
            .add(into: self)
            .centerX(.constant(0))
            .centerY(.constant(0))
            .width(.constant(100))
            .height(.constant(100))

        let loadingAnimationView = AnimationView()
        loadingAnimationView.translatesAutoresizingMaskIntoConstraints = false
        let loadingAnimation = Animation.named("EksiLoadingView")
        loadingAnimationView.animation = loadingAnimation
        contentView.addSubview(loadingAnimationView)

        loadingAnimationView
            .centerX(.constant(0))
            .centerY(.constant(0))
            .width(.constant(150))
            .height(.constant(150))

        loadingAnimationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop) { _ in

        }
    }
}

extension EksiLoadingView {
    static func show() {
        DispatchQueue.main.async {
            let vv = KeyWindow.subviews.first { $0.tag == ERKey.loadingViewTag }
            guard vv == nil else {
                return
            }
            let view = EksiLoadingView()
            view.tag = ERKey.loadingViewTag
            KeyWindow.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.fit()
        }
    }

    static func hide() {
        DispatchQueue.main.async {
            let vv = KeyWindow.subviews.first { $0.tag == ERKey.loadingViewTag }
            guard  let view = vv else { return }
            view.removeFromSuperview()
        }
    }
}
