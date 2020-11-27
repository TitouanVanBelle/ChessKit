//
//  PromotionView.swift
//  
//
//  Created by Titouan Van Belle on 11.11.20.
//

import UIKit
import Chess

protocol PromotionViewDelegate: AnyObject {
    func promotionView(_ promotionView: PromotionView, didEndPromotionWith promotion: Promotion)
    func promotionViewDidCancelPromotion(_ promotionView: PromotionView)
}

class PromotionView: UIView {

    private let viewModel: PromotionViewModel

    init(viewModel: PromotionViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }

    lazy var stackView: UIStackView = {
        let rect = CGRect(x: 0, y: 0, width: 300.0, height: 60)
        let stackView = UIStackView(frame: rect)
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        addSubview(stackView)
        return stackView
    }()

    weak var delegate: PromotionViewDelegate?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        backgroundColor = UIColor.white.withAlphaComponent(0.2)
        tag = -1

        setupStackView()
        var views = stackView.arrangedSubviews
        views.append(self)
        setupTapGestureRecognizer(on: views)
    }

    private func setupTapGestureRecognizer(on views: [UIView]) {
        for view in views {
            let tapHandler = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(tapHandler)
        }
    }

    @objc
    private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let tag = gestureRecognizer.view?.tag else {
            return
        }

        guard let promotion = Promotion(rawValue: tag) else {
            delegate?.promotionViewDidCancelPromotion(self)
            return
        }

        delegate?.promotionView(self, didEndPromotionWith: promotion)
    }

    private func setupStackView() {
        viewModel.availablePromotions.map(imageView(for:))
            .forEach(stackView.addArrangedSubview)

        stackView.center = center
    }

    private func imageView(for promotion: Promotion) -> UIImageView {
        let imageName = viewModel.imageName(for: promotion)
        let image = UIImage(named: imageName)!
        let rect = CGRect(x: 0, y: 0, width: 50, height: 50)
        let imageView = UIImageView(frame: rect)
        imageView.image = image.with(inset: 20.0)
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 4.0
        imageView.tag = promotion.rawValue

        return imageView
    }
}

