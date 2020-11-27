//
//  ChessBoardView.swift
//  ChessKit
//
//  Created by Titouan Van Belle on 11.11.20.
//  Copyright © 2019 Titouan Van Belle. All rights reserved.
//

import Chess
import Combine
import UIKit

public class ChessBoardView: UIView {

    // MARK: Public Properties

    public weak var delegate: ChessBoardViewDelegate? {
        didSet {
            store.delegate = delegate
        }
    }

    // MARK: Private Properties

    private var draggedPiece: UIView?
    private var pieces = [Int: UIView]()
    private var squares = [SquareView]()

    private var originalDraggingPoint: CGPoint?
    private var movementStartIndex: Int?
    private var selectedSquareView: SquareView?

    private lazy var squareFrames: [CGRect] = makeSquareFrames()

    private var cancellables = Set<AnyCancellable>()

    private let store: ChessBoardViewStore

    // MARK: Init

    public init() {
        store = ChessBoardViewStore()

        super.init(frame: .zero)

        store.boardView = self

        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycle

    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        draw()
    }
}

// MARK: Bindings

fileprivate extension ChessBoardView {
    func setupBindings() {
        store.$highlightedSquareIndexes
            .scan(Set<SquareIndex>()) { [weak self] indexesToReset, indexesToHighlight in
                self?.dehightlightSquares(at: indexesToReset)
                return indexesToHighlight
            }
            .sink { [weak self] indexesToHighlight in
                self?.hightlightSquares(at: indexesToHighlight)
            }
            .store(in: &cancellables)

        store.$selectedSquaresIndexes
            .scan(Set<SquareIndex>()) { [weak self] oldIndexes, newIndexes in
                let indexesToDeselect = oldIndexes.subtracting(newIndexes)
                self?.deselectSquares(at: indexesToDeselect)
                return newIndexes
            }
            .sink { [weak self] indexesToSelect in
                self?.selectSquares(at: indexesToSelect)
            }
            .store(in: &cancellables)
    }
}

// MARK: Public

public extension ChessBoardView {
    var pgn: PGN {
        store.pgn
    }

    func load(pgn: PGN) {
        store.load(pgn: pgn)
    }

    func loadNextMove() {
        store.loadNextMove()
    }

    func unloadPreviousMove() {
        store.unloadPreviousMove()
    }

    func loadAllMoves() {
        store.loadAllMoves()
    }

    func unloadAllMoves() {
        store.unloadAllMoves()
    }
}

// MARK: ChessBoardViewStoreDelegate

extension ChessBoardView: ChessBoardViewStoreDelegate {
    func redrawPieces() {
        pieces.values.forEach { $0.removeFromSuperview() }
        store.squares
            .forEach(drawPiece)
    }

    func movePiece(from fromIndex: SquareIndex, to toIndex: SquareIndex) {
        guard let piece = pieces[fromIndex] else {
            return
        }

        piece.frame = squareFrames[toIndex]

        pieces[fromIndex] = nil
        pieces[toIndex] = piece
    }

    func removePiece(at squareIndex: SquareIndex) {
        guard let piece = pieces[squareIndex] else {
            return
        }

        piece.removeFromSuperview()
        pieces[squareIndex] = nil
    }

    func addPiece(_ piece: PieceViewModel, at squareIndex: SquareIndex) {
        let pieceView = PieceView(viewModel: piece)
        drawPieceView(pieceView, at: squareIndex)
    }

    func selectSquares(at indexes: Set<SquareIndex>) {
        indexes
            .map{ squares[$0] }
            .forEach { $0.isSelected = true }
    }

    func deselectSquares(at indexes: Set<SquareIndex>) {
        indexes
            .map{ squares[$0] }
            .forEach { $0.isSelected = false }
    }

    func hightlightSquares(at indexes: Set<SquareIndex>) {
        indexes
            .map{ squares[$0] }
            .forEach { $0.isHighlighted = true }
    }

    func dehightlightSquares(at indexes: Set<SquareIndex>) {
        indexes
            .map{ squares[$0] }
            .forEach { $0.isHighlighted = false }
    }

    func snapDraggedPieceBack() {
        guard let originalDraggingPoint = originalDraggingPoint else {
            return
        }

        draggedPiece?.center = originalDraggingPoint
        draggedPiece = nil
    }
}

// MARK: UI

fileprivate extension ChessBoardView {
    func makeSquareFrames() -> [CGRect] {
        var rects = [CGRect]()
        let squareWidth = bounds.size.width / CGFloat(8)

        for i in 0...7 {
            let y = frame.height - (CGFloat(i) * squareWidth) - squareWidth
            for j in 0...7 {
                let fullWidth = squareWidth * 8
                let xOffset = (bounds.width - fullWidth) / 2
                let x = xOffset + CGFloat(j) * squareWidth
                let rect = CGRect(x: x, y: y, width: squareWidth, height: squareWidth)
                rects.append(rect)
            }
        }

        return rects
    }

    func draw() {
        store.squares
            .forEach(drawSquare)

        store.squares
            .forEach(drawPiece)

    }

    func drawSquare(square: SquareViewModel) {
        let index = square.index
        let squareView = SquareView(viewModel: square)
        squareView.frame = squareFrames[index]

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSquareTapGesture))
        squareView.isUserInteractionEnabled = true
        squareView.addGestureRecognizer(tapGesture)

        addSubview(squareView)

        squares.insert(squareView, at: index)
    }

    func drawPiece(at square: SquareViewModel) {
        guard let piece = square.piece else {
            return
        }

        let pieceView = PieceView(viewModel: piece)
        drawPieceView(pieceView, at: square.index)
    }

    func drawPieceView(_ view: PieceView, at index: SquareIndex) {
        view.frame = squareFrames[index]

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        view.addGestureRecognizer(panGesture)
        view.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePieceTapGesture))
        view.addGestureRecognizer(tapGesture)

        addSubview(view)

        bringSubviewToFront(view)

        pieces[index] = view
    }
}


// MARK: Actions

fileprivate extension ChessBoardView {
    @objc func handleSquareTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let squareView = gestureRecognizer.view else {
            return
        }

        let index = self.index(for: squareView.center)
        store.didTapSquare(at: index)
    }

    @objc func handlePieceTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let pieceView = gestureRecognizer.view else {
            return
        }

        let index = self.index(for: pieceView.center)
        store.didTapPiece(at: index)
    }

    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let piece = gestureRecognizer.view as? PieceView else {
            return
        }

        switch gestureRecognizer.state {
        case .began:
            startDragging(pieceView: piece, gestureRecognizer: gestureRecognizer)
        case .changed:
            dragging(pieceView: piece, gestureRecognizer: gestureRecognizer)
        case .ended:
            stopDragging(pieceView: piece, gestureRecognizer: gestureRecognizer)
        default:
            return
        }
    }

    // MARK: Dragging

    func startDragging(pieceView: PieceView, gestureRecognizer: UIPanGestureRecognizer) {
        bringSubviewToFront(pieceView)
        draggedPiece = pieceView
        originalDraggingPoint = pieceView.center

        pieceView.isDragging = true

        let index = self.index(for: pieceView.center)
        store.didStartDraggingPiece(at: index)
    }

    func dragging(pieceView: PieceView, gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self)
        pieceView.center = CGPoint(
            x: pieceView.center.x + translation.x,
            y: pieceView.center.y + translation.y
        )

        gestureRecognizer.setTranslation(CGPoint.zero, in: self)
    }

    func stopDragging(pieceView: PieceView, gestureRecognizer: UIPanGestureRecognizer) {
        pieceView.isDragging = false

        let inBound = bounds.contains(pieceView.center)
        let index = self.index(for: pieceView.center)

        store.didStopDraggingPiece(at: index, inBound: inBound)
    }

    // MARK: Helpers

    func index(for center: CGPoint) -> Int {
        let squareWidth = bounds.size.width / CGFloat(8)
        let rank = floor((frame.height - center.y) / squareWidth)
        let file = floor(center.x / squareWidth)
        return Int((rank * 8) + file)
    }
}

extension ChessBoardView {


    func snapDraggedPiece(to square: Square) {
        let index = square.location.index
        draggedPiece?.frame = squareFrames[index]
        draggedPiece = nil
    }

    func select(square: Square?) {
        guard let square = square else {
            return
        }

        let squareView = self.squareView(for: square)
        squareView.isSelected = true
        selectedSquareView = squareView
    }

    func deselectSelectedSquareIfNeeded() {
        selectedSquareView?.isSelected = false
        selectedSquareView = nil
    }

    func updatePiece(at index: Int) {
        removePiece(at: index)
    }

    func showPromotionView(_ promotionView: PromotionView) {
        promotionView.frame = bounds
        addSubview(promotionView)
    }

    func dismissPromotionView(_ promotionView: PromotionView) {
        promotionView.removeFromSuperview()
    }

    func squareView(for square: Square) -> SquareView {
        squares[square.location.index]
    }
}
