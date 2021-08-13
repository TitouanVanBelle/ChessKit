//
//  PieceView.swift
//  
//
//  Created by Titouan Van Belle on 12.11.20.
//

import UIKit

class PieceView: UIImageView {

    static let draggingScaleFactor: CGFloat = 1.6

    static let draggingTransform: CGAffineTransform = {
        CGAffineTransform(
            scaleX: draggingScaleFactor,
            y: draggingScaleFactor
        ).concatenating(CGAffineTransform(translationX: 0, y: -25))
    }()

    // MARK: Public Properties

    var isDragging: Bool = false {
        didSet { updateIsDragging() }
    }

    // MARK: Private Properties

    private let viewModel: PieceViewModel

    // MARK: Init

    init(viewModel: PieceViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UI

fileprivate extension PieceView {
    func setupView() {
        image = UIImage(named: viewModel.imageName, in: .module, compatibleWith: nil)?
            .with(inset: 20.0)
    }

    func updateIsDragging() {
        transform = isDragging ? PieceView.draggingTransform : .identity
    }
}

