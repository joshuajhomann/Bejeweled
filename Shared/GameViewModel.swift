//
//  GameViewModel.swift
//  Bejeweled
//
//  Created by Joshua Homann
//

import SwiftUI

@MainActor
final class GameViewModel: ObservableObject {

    @Published private(set) var cells: [Cell] = []
    var hasMatches: Bool { !Self.matches(for: cells).isEmpty }
    var canCollapse: Bool { cells.contains { $0.isMatched } }
    
    enum Constant {
        static let boardWidth = 8
        static let boardHeight = 8
        static let rows = (0..<boardHeight)
        static let columns = (0..<boardWidth)
        static var cellCount: Int { boardWidth * boardHeight }
        static let aspectRatio = Double(boardWidth) / Double(boardHeight)
        static let adjacentOffsets: [[(Int, Int)]] = [
            [(0, 1), (0, 0), (0, -1)],
            [(1, 0), (0, 0), (-1, 0)],
            [(-1, -1), (0, 0), (1, 1)],
            [(-1, 1), (0, 0), (1, -1)]
        ]
        static let cellContents = ["suit.spade.fill", "circlebadge.fill", "flame.fill", "tag.circle.fill", "ladybug.fill", "face.dashed.fill", "suit.diamond.fill"]
        static let colors = [#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.8623957038, green: 0.2169953585, blue: 1, alpha: 1), #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 1, green: 0.8398167491, blue: 0, alpha: 1), #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)]
    }

    struct Cell: Identifiable, Hashable {
        let id: UUID = .init()
        var position: Int
        var content: Int = Constant.cellContents.indices.randomElement() ?? 0
        var isMatched = false
    }

    init() {
        cells = Self.newBoard()
    }

    func exchange(_ sourceIndex: Int, with destinationIndex: Int) {
        cells.swapAt(sourceIndex, destinationIndex)
        cells[sourceIndex].position = sourceIndex
        cells[destinationIndex].position = destinationIndex
    }

    func removeMatches() {
        cells = Self.removeMatches(cells, removing: Self.matches(for: cells))
    }

    func collapse() {
        cells = Self.collapsed(board: cells)
    }

    static func isAdjacent(_ sourceIndex: Int, to destinationIndex: Int) -> Bool {
        let (sourceX, sourceY) = Self.coordinate(for: sourceIndex)
        let (destinationX, destinationY) = Self.coordinate(for: destinationIndex)
        let dx = abs(sourceX - destinationX)
        let dy = abs(sourceY - destinationY)
        return dx + dy == 1
    }

    private static func index(x: Int, y: Int) -> Int? {
        Constant.columns.contains(x) && Constant.rows.contains(y)
            ? x + y * Constant.boardWidth
            : nil
    }

    private static func coordinate(for index: Int) -> (Int, Int) {
        (index % Constant.boardWidth, index / Constant.boardWidth)
    }

    private static func newBoard() -> [Cell] {
        var board: [Cell]
        repeat {
            board = .init(
                (0..<Constant.cellCount).map { index in
                    Cell(position: index)
                }
            )
        } while (!Self.matches(for: board).isEmpty)
        return board
    }

    private static func matches(for board: [Cell]) -> Set<Int> {
        Set(
            Constant.columns.flatMap { x in
                Constant.rows.map { y in
                    (x, y)
                }
            }
                .flatMap { coordinate in
                    Constant
                        .adjacentOffsets
                        .map { offsets in
                            offsets.compactMap { offset in
                                let (x, y) = coordinate
                                let (dx, dy) = offset
                                return Self.index(x: x + dx, y: y + dy)
                            }
                        }
                        .filter { (indices: [Int]) in
                            guard indices.count == 3 else { return false }
                            let cells = indices.map { board[$0] }
                            return cells.allSatisfy { $0.isMatched == false }
                            && cells.dropFirst().allSatisfy { $0.content == cells[0].content }
                        }
                        .flatMap { $0 }
                }
        )
    }

    private static func removeMatches(_ board: [Cell], removing matches: Set<Int>) -> [Cell] {
        with(board) { board in
            matches.forEach { index in
                board[index].isMatched = true
            }
        }
    }

    private static func collapsed(board: [Cell]) -> [Cell] {
        Constant.columns.map { x -> [Cell] in
            let indices = Constant.rows.compactMap { y in
                Self.index(x: x, y: y)
            }
            guard let indexOfMatch = indices.lastIndex(where: { index in board[index].isMatched }) else {
                return indices.map { board[$0] }
            }
            return [Cell(position: indices[0])]
                + indices.prefix(upTo: indexOfMatch).map { with(board[$0]) { $0.position += Constant.boardWidth } }
                + indices.suffix(from: indexOfMatch).dropFirst().map { board[$0] }
        }
        .reduce(into: with(board) { _ in }) { board, column in
            for cell in column {
                board[cell.position] = cell
            }
        }
    }
}
