//
//  PieceViewModel.swift
//  
//
//  Created by Titouan Van Belle on 12.11.20.
//

import Foundation
import Chess

final class PieceViewModel {
    private let piece: Piece

    init(piece: Piece) {
        self.piece = piece
    }
}

extension PieceViewModel {
    var imageName: String {
        "Pieces/\(piece.color.rawValue)/\(piece.kind.name)"
    }
}
