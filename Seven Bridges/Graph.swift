import Foundation

class Graph {
    var nodes = [Node]()
    var edges = Set<Edge>()
    var nodeMatrix = [Node: Set<Node>]()
}
