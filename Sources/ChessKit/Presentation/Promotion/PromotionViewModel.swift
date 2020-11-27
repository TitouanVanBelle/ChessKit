//
//  PromotionViewModel.swift
//  
//
//  Created by Titouan Van Belle on 11.11.20.
//

import Foundation
import Chess

final class PromotionViewModel {
    let color: PieceColor
    let availablePromotions: [Promotion] = [.queen, .rook, .bishop, .knight]

    init(color: PieceColor) {
        self.color = color
    }

    func imageName(for promotion: Promotion) -> String {
        "\(promotion.name) - \(color.rawValue)"
    }
}
