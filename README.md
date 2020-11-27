# ChessKit

A chess board view. 

*This project is meant to be used for production apps.*

<br/>
<p align="center">
  <img src="https://i.postimg.cc/GmDFG4f2/ChessKit.png" height="500">
</p>
<br/>

## Features

- Move pieces (dragging + click)
- Load PGN / Extract PGN
- Navigate through PGN


## How to use

## Create a ChessBoardView

Add a chess board view programmatically to your view hierarchy

```swift
let boardView = ChessBoardView()
view.addSubview(boardView)
```

### Load PGN

Load a PGN onto your chess board

```swift
let pgn = "1. e4 e5 2. Nf3 Nc6"
boardView.loadPgn(pgn)
```

### Navigates through PGN

Load or unload moves from the PGN on the chess board

```swift
boardView.loadNextMove()
boardView.unloadPreviousMove()
boardView.loadAllMoves()
boardView.unloadAllMoves()
```

### Print the PGN

Print the PGN of the chess board using the following code

```swift
print(boardView.pgn)
// 1. e4 e5 2. Nf3 Nc6
```

## To Do

- Animate PGN
- Animate invalid move because of king in check
- Play sounds (move, capture, castle, check, checkmate, invalid move)
