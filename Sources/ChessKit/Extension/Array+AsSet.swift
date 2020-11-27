//
//  Array+AsSet.swift
//  
//
//  Created by Titouan Van Belle on 17.11.20.
//

import Foundation

extension Array where Element: Hashable {
    var asSet: Set<Element> {
        Set(self)
    }
}
