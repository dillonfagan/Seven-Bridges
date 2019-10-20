import Foundation

class Graph {
    
    var nodes: [Node]
    var edges: Set<Edge>
    var nodeMatrix: [Node: Set<Node>]
    
    init() {
        self.nodes = [Node]()
        self.edges = Set<Edge>()
        self.nodeMatrix = [Node: Set<Node>]()
    }
    
    init(_ graph: Graph) {
        self.nodes = graph.nodes
        self.edges = graph.edges
        self.nodeMatrix = graph.nodeMatrix
    }
    
    func add(_ node: Node) {
        nodes.append(node)
        nodeMatrix[node] = Set<Node>()
    }
    
    func add(_ edge: Edge) {
        nodeMatrix[edge.startNode]?.insert(edge.endNode)
        nodeMatrix[edge.endNode]?.insert(edge.startNode)
        edges.insert(edge)
    }
    
    func remove(_ node: Node) {
        for edge in node.edges {
            removeEdgeFromNodes(edge)
        }
        
        nodes.remove(at: nodes.firstIndex(of: node)!)
        nodeMatrix.removeValue(forKey: node)
        
        for (_, var adjacents) in nodeMatrix {
            adjacents.remove(node)
        }
    }
    
    private func removeEdgeFromNodes(_ edge: Edge) {
        // remove edge from its start node
        if let index = edge.startNode?.edges.firstIndex(of: edge) {
            edge.startNode?.edges.remove(at: index)
        }
        
        // remove edge from its end node
        if let index = edge.endNode?.edges.firstIndex(of: edge) {
            edge.endNode?.edges.remove(at: index)
        }
    }
    
    func remove(_ edge: Edge) {
        removeEdgeFromNodes(edge)
        edges.remove(edge)
        nodeMatrix[edge.startNode]?.remove(edge.endNode)
        nodeMatrix[edge.endNode]?.remove(edge.startNode)
    }
    
    func removeAllEdges() {
        for node in nodes {
            node.edges.removeAll()
            nodeMatrix[node]?.removeAll()
        }
        
        edges.removeAll()
    }
    
    func resetAllEdgeWeights(to weight: Int = 1) {
        for edge in edges {
            edge.weight = weight
            edge.updateLabel()
        }
    }
    
    func edge(from a: Node, to b: Node, isDirected: Bool = true) -> Edge? {
        return isDirected ? edges.first(where: { $0.startNode == a && $0.endNode == b })
            : a.edges.first(where: { $0.startNode == b || $0.endNode == b })
    }
    
}

class UndirectedGraph: Graph {
    
    override func edge(from a: Node, to b: Node, isDirected: Bool = true) -> Edge? {
        return a.edges.first(where: { $0.startNode == b || $0.endNode == b })
    }
    
}
