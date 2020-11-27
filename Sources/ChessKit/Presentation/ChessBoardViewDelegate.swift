//
//  ChessBoardViewDelegate.swift
//  
//
//  Created by Titouan Van Belle on 26.11.20.
//

import Foundation
import Chess

public protocol ChessBoardViewDelegate: class {
    func boardViewDidPlayMove(_ move: Move)
}
