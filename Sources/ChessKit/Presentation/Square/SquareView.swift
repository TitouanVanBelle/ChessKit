//
//  SquareView.swift
//  
//
//  Created by Titouan Van Belle on 11.11.20.
//

import Combine
import PureLayout
import UIKit

class SquareView: UIView {

    // MARK: Constants

    enum Constants {
        static let lightSquareColor: UIColor = #colorLiteral(red: 0.8078431373, green: 0.7529411765, blue: 0.631372549, alpha: 1)
        static let darkSquareColor: UIColor = #colorLiteral(red: 0.6666666667, green: 0.5764705882, blue: 0.4823529412, alpha: 1)
    }

    // MARK: Public Properties

    var isSelected: Bool = false {
        didSet { updateSelected() }
    }

    var isHighlighted: Bool = false {
        didSet { updateHighlighted() }
    }

    // MARK: Private Properties

    private lazy var selectedLayer: CALayer = makeSelectedLayer()
    private lazy var highlightedLayer: CALayer = makeHighlightedLayer()

    private var cancellables = Set<AnyCancellable>()

    private let viewModel: SquareViewModel

    // MARK: Init

    init(viewModel: SquareViewModel) {
        self.viewModel = viewModel
    
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SquareView {
    func blink() {
        Array(repeating: [UIColor.red, backgroundColor!], count: 3)
            .flatMap { $0 }
            .publisher
            .publish(every: 0.3, on: .main, in: .default)
            .sink { self.backgroundColor = $0 }
            .store(in: &cancellables)
    }
}

// MARK: UI

fileprivate extension SquareView {
    func setupUI() {
        setupView()
    }

    func setupView() {
        backgroundColor = viewModel.isSquareDark ?
            Constants.darkSquareColor :
            Constants.lightSquareColor
    }

    func updateSelected() {
        if isSelected {
            layer.addSublayer(selectedLayer)
        } else {
            selectedLayer.removeFromSuperlayer()
        }
    }

    func updateHighlighted() {
        if isHighlighted {
            layer.addSublayer(highlightedLayer)
        } else {
            highlightedLayer.removeFromSuperlayer()
        }
    }

    func makeSelectedLayer() -> CALayer {
        let layer = CALayer()
        layer.frame = bounds
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.2).cgColor
        return layer
    }

    func makeHighlightedLayer() -> CALayer {
        let layer = CALayer()
        layer.frame = CGRect(
            x: bounds.width / 3.0 ,
            y: bounds.width / 3.0,
            width:  bounds.width / 3.0,
            height: bounds.height / 3.0
        )
        layer.cornerRadius = layer.frame.size.width / 2.0
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.2).cgColor
        return layer
    }
}
