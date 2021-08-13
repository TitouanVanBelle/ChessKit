//
//  ChessBoardViewDelegate.swift
//  
//
//  Created by Titouan Van Belle on 26.11.20.
//

import Foundation
import Chess

public protocol ChessBoardViewDelegate: AnyObject {
    func boardViewDidPlayMove(_ move: Move)
}
