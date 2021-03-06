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
        .blurEffect(.light)
        .backgroundColor(.clear)
        .opacity(0.0)
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
            .width(.constant(120))
            .height(.constant(120))

        let loadingAnimationView = AnimationView()
        loadingAnimationView.translatesAutoresizingMaskIntoConstraints = false
        let loadingAnimation = Animation.named("lemonLoading")
        loadingAnimationView.animation = loadingAnimation
        contentView.addSubview(loadingAnimationView)

        loadingAnimationView
            .centerX(.constant(0))
            .centerY(.constant(0))
            .width(.constant(200))
            .height(.constant(200))

        loadingAnimationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop) { _ in

        }
    }
}

extension EksiLoadingView {
    static func show(in view: UIView? = nil) {
        DispatchQueue.main.async {
            let superView = view ?? KeyWindow
            let vv = superView.subviews.first { $0.tag == ERKey.loadingViewTag }
            guard vv == nil else {
                return
            }
            let view = EksiLoadingView()
            view.tag = ERKey.loadingViewTag
            superView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.fit()
        }
    }

    static func hide(from view: UIView? = nil) {
        DispatchQueue.main.async {
            let superView = view ?? KeyWindow
            let vv = superView.subviews.first { $0.tag == ERKey.loadingViewTag }
            guard  let view = vv else { return }
            view.removeFromSuperview()
        }
    }
}
