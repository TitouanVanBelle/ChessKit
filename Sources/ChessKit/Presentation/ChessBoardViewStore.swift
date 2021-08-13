//
//  ChessBoardViewStore.swift
//  
//
//  Created by Titouan Van Belle on 11.11.20.
//

import Combine
import Foundation
import Chess

typealias SquareIndex = Int

protocol ChessBoardViewStoreDelegate: AnyObject {
    func movePiece(from fromIndex: SquareIndex, to toIndex: SquareIndex)
    func removePiece(at squareIndex: SquareIndex)
    func addPiece(_ piece: PieceViewModel, at squareIndex: SquareIndex)
    func redrawPieces()
    func snapDraggedPieceBack()
    func blinkSquare(_ square: Square)
}

final class ChessBoardViewStore {

    // MARK: Public Properties

    weak var delegate: ChessBoardViewDelegate?
    weak var boardView: ChessBoardViewStoreDelegate?

    @Published var highlightedSquareIndexes: Set<SquareIndex> = []
    @Published var selectedSquaresIndexes: Set<SquareIndex> = []

    // MARK: Private Properties

    private let board: ChessBoard = ChessBoard()

    private var moveStartSquare: Square?
    private var moveEndSquare: Square?
}

// MARK: Public

extension ChessBoardViewStore {
    var pgn: PGN {
        board.pgn
    }

    var squares: [SquareViewModel] {
        board.squares.map(SquareViewModel.init)
    }

    func load(pgn: PGN) {
        try? board.load(pgn: pgn)
    }

    func loadNextMove() {
        guard let move = board.loadNextMove() else {
            return
        }

        executeAction(for: move)
    }

    func unloadPreviousMove() {
        guard let move = board.unloadPreviousMove() else {
            return
        }

        boardView?.movePiece(
            from: move.toSquare.location.index,
            to: move.fromSquare.location.index
        )

        if let capturedPiece = move.capturedPiece {
            let piece = PieceViewModel(piece: capturedPiece)
            boardView?.addPiece(piece, at: move.toSquare.location.index)
        }

        if board.currentMoveIndex > 0 {
            let lastMove = board.moves[board.currentMoveIndex - 1]
            selectedSquaresIndexes = [
                lastMove.toSquare.location.index,
                lastMove.fromSquare.location.index
            ]
        } else {
            selectedSquaresIndexes = []
        }

        delegate?.boardViewDidPlayMove(move)
    }

    func loadAllMoves() {
        guard !board.moves.isEmpty else { return }

        board.loadAllMoves()
        boardView?.redrawPieces()

        if board.currentMoveIndex > 0 {
            let lastMove = board.moves[board.currentMoveIndex - 1]
            selectedSquaresIndexes = [
                lastMove.toSquare.location.index,
                lastMove.fromSquare.location.index
            ]
        }

        delegate?.boardViewDidPlayMove(board.moves.last!)
    }

    func unloadAllMoves() {
        guard !board.moves.isEmpty else { return }

        board.unloadAllMoves()
        boardView?.redrawPieces()
        selectedSquaresIndexes = []

        delegate?.boardViewDidPlayMove(board.moves.first!)
    }

    func didTapSquare(at index: SquareIndex) {
        let square = board.squares[index]

        if let moveStartSquare = moveStartSquare {
            playMove(from: moveStartSquare, to: square)
        }
    }

    func didTapPiece(at index: SquareIndex) {
        let square = board.squares[index]

        guard let piece = square.piece else {
            return
        }

        if let moveStartSquare = moveStartSquare {
            if moveStartSquare.location.index == square.location.index {
                selectedSquaresIndexes.remove(moveStartSquare.location.index)
                highlightedSquareIndexes = []
                self.moveStartSquare = nil
                boardView?.snapDraggedPieceBack()
            } else {
                let legalSquares = board.legalSquares(forPieceAt: moveStartSquare)
                    .map(\.location.index)

                if legalSquares.contains(square.location.index) {
                    selectedSquaresIndexes = []
                    playMove(from: moveStartSquare, to: square)
                } else {
                    if piece.color == board.currentPlayer {
                        highlightedSquareIndexes = board.legalSquares(forPieceAt: square)
                            .map(\.location.index)
                            .asSet
                    } else {
                        highlightedSquareIndexes = []
                        boardView?.snapDraggedPieceBack()
                    }

                    selectedSquaresIndexes.remove(moveStartSquare.location.index)
                    selectedSquaresIndexes.insert(square.location.index)

                    self.moveStartSquare = square
                }
            }
        } else {
            selectedSquaresIndexes.insert(square.location.index)

            if piece.color == board.currentPlayer {
                highlightedSquareIndexes = board.legalSquares(forPieceAt: square)
                    .map(\.location.index)
                    .asSet
            }

            moveStartSquare = square
        }
    }

    func didStartDraggingPiece(at index: SquareIndex) {
        didTapPiece(at: index)
    }

    func didStopDraggingPiece(at index: SquareIndex, inBound: Bool) {
        let square = board.squares[index]

        if square.piece == nil {
            didTapSquare(at: index)
        } else {
            didTapPiece(at: index)
        }
    }
}

// MARK: Private

fileprivate extension ChessBoardViewStore {
    func playMove(from fromSquare: Square, to toSquare: Square) {
        do {
            moveStartSquare = nil
            moveEndSquare = nil

            let move = try board.playMove(from: fromSquare, to: toSquare)
            executeAction(for: move)
        } catch {
            selectedSquaresIndexes = []
            highlightedSquareIndexes = []
            boardView?.snapDraggedPieceBack()

            if case ChessBoardError.invalidMove(let reason) = error, case .kingInCheck(let kingSquare) = reason {
                boardView?.blinkSquare(kingSquare)
            }
        }
    }

    func executeAction(for move: Move) {
        let fromIndex = move.fromSquare.location.index
        let toIndex = move.toSquare.location.index

        selectedSquaresIndexes = [fromIndex, toIndex]
        highlightedSquareIndexes = []

        switch move.kind {
        case .move:
            boardView?.movePiece(from: fromIndex, to: toIndex)

        case .capture:
            boardView?.removePiece(at: toIndex)
            boardView?.movePiece(from: fromIndex, to: toIndex)

        case .enPassant:
            return

        case .castle(let side):
            let kingFromIndex = kingInitialIndex(for: move.player)
            let kingToIndex = kingCastledIndex(for: move.player, castleSide: side)
            boardView?.movePiece(from: kingFromIndex, to: kingToIndex)

            let rookFromIndex = rookInitialIndex(for: move.player, castleSide: side)
            let rookToIndex = rookCastledIndex(for: move.player, castleSide: side)
            boardView?.movePiece(from: rookFromIndex, to: rookToIndex)
        }

        delegate?.boardViewDidPlayMove(move)
    }

    func kingCastledIndex(for color: PieceColor, castleSide: CastleSide) -> Int {
        let kindStartIndex = kingInitialIndex(for: color)
        return castleSide == .king ?
            kindStartIndex + 2 :
            kindStartIndex - 2
    }

    func kingInitialIndex(for color: PieceColor) -> Int {
        color == .white ? 4 : 60
    }

    func rookInitialIndex(for color: PieceColor, castleSide: CastleSide) -> Int {
        return color == .white ?
            (castleSide == .king ? 7 : 0) :
            (castleSide == .king ? 63 : 56)
    }

    func rookCastledIndex(for color: PieceColor, castleSide: CastleSide) -> Int {
        let kingEndIndex = kingCastledIndex(for: color, castleSide: castleSide)
        return castleSide == .king ?
            kingEndIndex - 1 :
            kingEndIndex + 1
    }
}
