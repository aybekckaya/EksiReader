//
//  Debouncer.swift
//  Debouncer
//
//  Created by Aybek Can Kaya on 24.07.2021.
//

import Foundation

public class Debouncer: NSObject {
    private var timer: Timer?
    private var timeInterval: TimeInterval = 0
    private var closure: (()->())?
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    public init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    public func tick(_ closure: @escaping ()->()) {
        self.closure = closure
    }
    
    public func ping() {
        self.timer?.invalidate()
        self.timer = nil
        self.timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if let cl = self.closure { cl() }
            self.timer?.invalidate()
            self.timer = nil
        }
    }
}
