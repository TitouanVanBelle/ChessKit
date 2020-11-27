//
//  ViewController.swift
//  ChessKitDemo
//
//  Created by Titouan Van Belle on 11.11.20.
//

import Chess
import ChessKit
import PureLayout
import UIKit

class ViewController: UIViewController {

    // MARK: Private Properties

    private lazy var boardView: ChessBoardView = makeChessBoardView()

    private lazy var loadNextButton: UIButton = makeLoadNextButton()
    private lazy var unloadPreviousButton: UIButton = makeUnloadPreviousButton()
    private lazy var loadAllButton: UIButton = makeLoadAllButton()
    private lazy var unloadAllButton: UIButton = makeUnloadAllButton()
    private lazy var controlsStack: UIStackView = makeControlsStack()

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let pgn = "1. e4 d5 2. Bb5+ Bd7 3. d4 Bxb5 4. Nf3 Nf6 4. O-O O-O"
        boardView.load(pgn: pgn)
    }
}

// MARK: UI

fileprivate extension ViewController {
    func setupUI() {
        setupView()
        setupConstraints()
    }

    func setupView() {
        view.addSubview(boardView)
        view.addSubview(controlsStack)
    }

    func setupConstraints() {
        boardView.autoPinEdge(toSuperviewEdge: .left)
        boardView.autoPinEdge(toSuperviewEdge: .right)
        boardView.autoCenterInSuperview()
        boardView.autoMatch(.height, to: .width, of: boardView)

        controlsStack.autoPinEdge(toSuperviewEdge: .left)
        controlsStack.autoPinEdge(toSuperviewEdge: .right)
        controlsStack.autoSetDimension(.height, toSize: 60)
        controlsStack.autoPinEdge(.top, to: .bottom, of: boardView)
    }

    func makeChessBoardView() -> ChessBoardView {
        let view = ChessBoardView()
        view.delegate = self
        return view
    }

    func makeControlsStack() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [
            unloadAllButton,
            unloadPreviousButton,
            loadNextButton,
            loadAllButton
        ])

        stack.distribution = .fillEqually

        return stack
    }

    func makeUnloadPreviousButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Previous", for: .normal)
        button.addTarget(self, action: #selector(unloadPrevious), for: .touchUpInside)
        return button
    }

    func makeLoadNextButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.addTarget(self, action: #selector(loadNext), for: .touchUpInside)
        return button
    }

    func makeLoadAllButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Last", for: .normal)
        button.addTarget(self, action: #selector(loadAll), for: .touchUpInside)
        return button
    }

    func makeUnloadAllButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("First", for: .normal)
        button.addTarget(self, action: #selector(unloadAll), for: .touchUpInside)
        return button
    }
}

// MARK: Actions

fileprivate extension ViewController {
    @objc func loadNext() {
        boardView.loadNextMove()
    }

    @objc func unloadPrevious() {
        boardView.unloadPreviousMove()
    }

    @objc func loadAll() {
        boardView.loadAllMoves()
    }

    @objc func unloadAll() {
        boardView.unloadAllMoves()
    }
}

// MARK: ChessBoardViewDelegate

extension ViewController: ChessBoardViewDelegate {
    func boardViewDidPlayMove(_ move: Move) {

    }
}
