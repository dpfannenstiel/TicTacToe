import Foundation

/// A  TicTacToe Board
///
/// The Board is represented as an immutable structure that depends on the `with(tile:at:)` method to generate new boards with updated values.
/// The state of the game may be checked via `checkVictory()` for a current victor.
/// New games should be generated through `TicTacToeBoard.standardGame()` to produce a 3x3 game, but the initalizer may produce larger games
/// if desired.
struct TicTacToeBoard {
    /// A tile within a Tic-Tac-Toe board.
    enum Tile: CustomStringConvertible {
        /// A tile that has not been selected yet
        case empty

        /// A tile that has been selected by the "ex" player.
        case ex

        /// A tile that has been selected by the "oh" player.
        case oh

        /// Conformance to `CustomStringConvertible`
        ///
        /// Return the `stringValue` representation
        var description: String {
            return stringValue
        }

        /// The string value representing the tile
        var stringValue: String {
            switch self {
            case .empty: return "⬜️"
            case .ex: return "❌"
            case .oh: return "⭕️"
            }
        }

        /// The mapping of a tile to the victor.
        var victoryValue: Victor {
            switch self {
            case .empty: return .none
            case .ex: return .ex
            case .oh: return .oh
            }
        }
    }

    /// The winner of a Tic-Tac-Toe game.
    ///
    /// Whereas a tile may have three states, a game may have a fourth that requires representation.  The "Cat's Game" in the unlikely event of a stalemate.
    enum Victor: CustomStringConvertible {

        /// There is no victor.
        case none

        /// The "ex" player is the victor of the game.
        case ex

        /// The "oh" player is the victor of the game.
        case oh

        /// A stalemate has occurred.
        case cat

        /// Conformance to `CustomStringConvertible`
        ///
        /// Return the `stringValue` representation
        var description: String {
            return stringValue
        }

        /// The string value representing the tile
        var stringValue: String {
            switch self {
            case .none: return "🚫"
            case .ex: return "❌"
            case .oh: return "⭕️"
            case .cat: return "😼"
            }
        }
    }

    /// The Tic-Tac-Toe board stored as an array of tiles.
    private let board: [Tile]

    /// The length of a side of a board.  By conventions of the game all boards are square
    private let sideLength: Int

    /// Designated Initalizer
    ///
    /// Create an immutable game with a size and a seeded board
    /// - parameters:
    ///     - boardSide: the size of a board length
    ///     - seededBoard: the game board
    init(boardSide: Int, seededBoard: [Tile]) {
        sideLength = boardSide
        board = seededBoard
    }

    /// A Convienience Initalizer
    ///
    /// Creates a board of empty tiles with the desired side length.
    /// - parameters:
    ///     - boardSide: the size of a board length
    init(boardSide: Int) {
        self.init(
            boardSide: boardSide,
            seededBoard: Array(repeating: .empty, count: boardSide * boardSide)
        )
    }

    /// Produce a Tic-Tac-Toe board with a standard board size of "3".
    /// - returns:
    ///     An empty game board ready for play.
    static func standard() -> TicTacToeBoard {
        return TicTacToeBoard(boardSide: 3)
    }

    /// Produce a new board with the desired tile at the assigned index.
    ///
    /// This does not apply any validation logic associated with turns or availability of the tiles.  Just assignes values and returns the new board.
    /// - parameters:
    ///     - tile: value to update in the board
    ///     - index: to assign the value to
    /// - returns:
    ///     an updated board with the tile placed at the assigned index.
    func with(tile: Tile, at index: Int) -> TicTacToeBoard {
        var newboard = board
        newboard.replaceSubrange(index...index, with: [tile])
        return TicTacToeBoard(boardSide: sideLength, seededBoard: newboard)
    }

    /// Check if there is a victor in any of the vertical columns
    /// - returns:
    ///     A `Victor` value for evaluation.
    private func verticalCheck() -> Victor {
        for start in 0..<sideLength {
            let victor = victoryStride(from: start, to: board.count, by: sideLength)
            if victor != .none {
                return victor
            }
        }
        return .none
    }

    /// Check the various victory algorithims for a victory.
    ///
    /// - returns:
    ///     The `Victor` of the game state.
    func checkVictory() -> Victor {
        if case let horizontal = horizontalCheck(), horizontal != .none {
            return horizontal
        }
        if case let vertical = verticalCheck(), vertical != .none {
            return vertical
        }
        if case let diagonal = diagonalCheck(), diagonal != .none {
            return diagonal
        }
        if case let cat = catCheck(), cat != .none {
            return cat
        }
        return .none
    }

    /// Check if there is a victor in any of the horizontal rows
    /// - returns:
    ///     A `Victor` value for evaluation.
    private func horizontalCheck() -> Victor {
        let chunks = board.chunks(sideLength).map { $0.victor }
        return Set(chunks).victor
    }

    /// Check if there is a victor in either of the diagonals of the board
    /// - returns:
    ///     A `Victor` value for evaluation.
    private func diagonalCheck() -> Victor {
        let leftDiagonal = victoryStride(from: 0, to: board.count, by: sideLength + 1)
        if leftDiagonal != .none {
            return leftDiagonal
        }
        let rightDiagonal = victoryStride(from: sideLength - 1, to: board.count - (sideLength - 1), by: sideLength - 1)
        return rightDiagonal
    }

    /// Check if the game has reached a stalemate condition.
    private func catCheck() -> Victor {
        return self.board
            .map { $0 == .empty ? Victor.none : Victor.cat }
            .reduce(into: Set([])) { $0.insert($1) }
            .victor
    }

    /// Check a specific stride for a victory condition
    ///
    /// - parameters:
    ///     - start: The starting value to use for the sequence.
    ///     - end: An end value to limit the sequence. end is never an element of the resulting sequence.
    ///     - length: The amount to step by with each iteration. A positive `length` iterates upward; a negative `length` iterates downward.
    private func victoryStride(from start: Int, to end: Int, by length: Int) -> Victor {
        return stride(from: start, to: end, by: length)
            .map { self.board[$0] }
            .victor
    }
}

extension TicTacToeBoard: CustomStringConvertible {
    /// Conformance to `CustomStringConvertible`
    ///
    /// Break the board into chunks present each chunk on it's own line for easy reading.
    var description: String {
        return board.chunks(sideLength)
            .map { tilearray in
                tilearray.map{ $0.stringValue }
                    .joined(separator: "-")
        }
        .joined(separator: "\n")
        + "\n"
        + "sideLength: \(sideLength)"
    }
}

extension TicTacToeBoard: CustomPlaygroundDisplayConvertible {
    /// Conformance to `CustomPlaygroundDisplayConvertible`
    var playgroundDescription: Any {
        return self.description
    }
}

extension Array {
    /// Produce an array of arrays based on the desired chunk size.
    ///
    /// - parameters:
    ///     - chunkSize: the size of a desired internal array
    /// - returns:
    ///     An array of arrays
    func chunks(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

extension Array where Element == TicTacToeBoard.Tile {
    /// Reduce the Array of `TicTacToeBoard.Tile` into a single `Victor` value
    var victor: TicTacToeBoard.Victor {
        return self.reduce(into: Set([])) { $0.insert($1.victoryValue)}
        .victor
    }
}

extension Set where Element == TicTacToeBoard.Victor {
    /// Reduce the Set of `TicTacToeBoard.Tile` into a single `Victor` value
    var victor: Element {
        return self.count == 1 ? self.first! : TicTacToeBoard.Victor.none
    }
}

// Example use
var standardGame = TicTacToeBoard.standard()
standardGame = standardGame.with(tile: .ex, at: 0)
standardGame = standardGame.with(tile: .oh, at: 4)
standardGame = standardGame.with(tile: .ex, at: 3)
standardGame.checkVictory()
standardGame = standardGame.with(tile: .oh, at: 1)
standardGame = standardGame.with(tile: .ex, at: 6)
standardGame.checkVictory()
