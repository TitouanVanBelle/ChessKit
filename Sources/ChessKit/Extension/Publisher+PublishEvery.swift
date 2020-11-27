//
//  Publisher+PublishEvery.swift
//  
//
//  Created by Titouan Van Belle on 27.11.20.
//

import Foundation
import Combine

extension Publisher {
    func publish(
        every interval: TimeInterval,
        on runLoop: RunLoop,
        in mode: RunLoop.Mode
    ) -> AnyPublisher<Self.Output, Self.Failure> {
        Timer.publish(every: interval, on: runLoop, in: mode)
            .autoconnect()
            .eraseToAnyPublisher()
            .setFailureType(to: Self.Failure.self)
            .merge(with: Just(Date()).setFailureType(to: Self.Failure.self))
            .zip(self)
            .map(\.1)
            .eraseToAnyPublisher()
    }
}
