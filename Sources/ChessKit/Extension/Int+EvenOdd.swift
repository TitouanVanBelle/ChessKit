//
//  Int+EvenOdd.swift
//  Chess
//
//  Created by Titouan Van Belle on 11.11.20.
//  Copyright © 2019 Titouan Van Belle. All rights reserved.
//

import Foundation

extension Int {
    var isEven: Bool {
        self % 2 == 0
    }

    var isOdd: Bool {
        !isEven
    }
}
