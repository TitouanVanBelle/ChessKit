//
//  SquareViewModel.swift
//  
//
//  Created by Titouan Van Belle on 11.11.20.
//

import Foundation
import Chess

final class SquareViewModel {
    private let square: Square

    init(square: Square) {
        self.square = square
    }
}

extension SquareViewModel {
    var index: SquareIndex {
        square.location.index
    }

    var isSquareDark: Bool {
        (square.location.file.rawValue + square.location.rank.rawValue).isEven
    }

    var piece: PieceViewModel? {
        square.piece.flatMap(PieceViewModel.init)
    }
}

