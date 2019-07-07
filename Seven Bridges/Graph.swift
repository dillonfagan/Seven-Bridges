import Foundation

class Graph {
    var nodes = [Node]()
    var edges = Set<Edge>()
    var nodeMatrix = [Node: Set<Node>]()
    
    func edge(from a: Node, to b: Node, isDirected: Bool = true) -> Edge? {
        return isDirected ? edges.first(where: { $0.startNode == a && $0.endNode == b })
            : a.edges.first(where: { $0.startNode == b || $0.endNode == b })
    }
}
