//
//  EksiFooterLoadingView.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation
import UIKit
import Lottie

class EksiFooterLoadingView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        self.translatesAutoresizingMaskIntoConstraints = true 
        backgroundColor = .clear
        let loadingAnimationView = AnimationView()
        loadingAnimationView.translatesAutoresizingMaskIntoConstraints = true
        let loadingAnimation = Animation.named("EksiLoadingView")
        loadingAnimationView.animation = loadingAnimation
        self.addSubview(loadingAnimationView)

        loadingAnimationView.frame = CGRect(origin: .zero,
                                            size: .init(width: frame.size.width, height: frame.size.height))

        loadingAnimationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop) { _ in

        }
    }
}
