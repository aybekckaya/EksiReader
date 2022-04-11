//
//  TodayVC.swift
//  EksiReader
//
//  Created by aybek can kaya on 5.04.2022.
//

import Foundation
import UIKit

class TodayVC: ERViewController {
    private let viewModel: TodayViewModel

    init(viewModel: TodayViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Lifecycle
extension TodayVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // AuthToken.reset()
        EksiCloud.shared.call(endpoint: .today(page: 1), responseType: TodaysResponse.self) { response in
            NSLog("Response 1: \(response)")
            EksiCloud.shared.call(endpoint: .today(page: 2), responseType: TodaysResponse.self) { response in
                NSLog("Response 2: \(response)")
                EksiCloud.shared.call(endpoint: .today(page: 3), responseType: TodaysResponse.self) { response in
                    NSLog("Response 3: \(response)")
                }
            }
        }

        

        EksiCloud.shared.call(endpoint: .today(page: 4), responseType: TodaysResponse.self) { response in
            NSLog("Response 4: \(response)")
        }

        EksiCloud.shared.call(endpoint: .today(page: 5), responseType: TodaysResponse.self) { response in
            NSLog("Response 5: \(response)")
        }

        EksiCloud.shared.call(endpoint: .today(page: 6), responseType: TodaysResponse.self) { response in
            NSLog("Response 6: \(response)")
        }

        EksiCloud.shared.call(endpoint: .today(page: 7), responseType: TodaysResponse.self) { response in
            NSLog("Response 7: \(response)")
        }

        EksiCloud.shared.call(endpoint: .today(page: 8), responseType: TodaysResponse.self) { response in
            NSLog("Response 8: \(response)")
        }

    }
}
