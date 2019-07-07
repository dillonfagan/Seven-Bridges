import Foundation

class FordFulkersonMaxFlow: Algorithm {
    
    private var net: [Node: Set<Edge>]!
    private var reverse = [Edge: Edge]()
    
    var iterations = 0
    var maxFlow = 0
    
    override init(_ graph: Graph) {
        super.init(graph)
        buildNetwork()
    }
    
    func go(from source: Node, to sink: Node) {
        // While there is a path from s to t where all edges have capacity > 0...
        while let path = augmentingPath(from: source, to: sink) {
            // ...move flow along edges in path.
            if let residualCapacity = path.residualCapacity {
                maxFlow += residualCapacity
                
                for edge in path.edges {
                    edge.flow! += residualCapacity
                    reverse[edge]!.flow! -= residualCapacity
                    
                    // Update the edge's label in sync with the path outlining.
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4 * iterations), execute: {
                        edge.updateLabel(transitionDuration: 1)
                    })
                }
                
                // Skip outlining paths that contain backward edges.
                if path.isSequential {
                    path.outline(duration: 2, wait: 4 * iterations)
                    
                    iterations += 1
                }
            }
        }
    }
    
    private func buildNetwork() {
        net = [Node: Set<Edge>]()
        for edge in graph.edges {
            edge.flow = 0
            
            let backwardEdge = Edge()
            backwardEdge.isHidden = true
            backwardEdge.startNode = edge.endNode
            backwardEdge.endNode = edge.startNode
            backwardEdge.weight = 0
            backwardEdge.flow = 0
            
            reverse[edge] = backwardEdge
            reverse[backwardEdge] = edge
            
            if net[edge.startNode] == nil {
                net[edge.startNode] = Set<Edge>()
            }
            
            if net[backwardEdge.startNode] == nil {
                net[backwardEdge.startNode] = Set<Edge>()
            }
            
            net[edge.startNode]?.insert(edge)
            net[backwardEdge.startNode]?.insert(backwardEdge)
        }
    }
    
    // Returns an augmenting path if one exists. Otherwise, returns nil.
    private func augmentingPath(from source: Node, to sink: Node, along path: Path = Path()) -> Path? {
        if source == sink {
            return path
        }
        
        for edge in net[source]! {
            if edge.residualCapacity! > 0 && !path.edges.contains(edge) {
                let newPath = Path(path)
                newPath.append(edge, ignoreNodes: true)
                
                if let result = augmentingPath(from: edge.endNode, to: sink, along: newPath) {
                    return result
                }
            }
        }
        
        return nil
    }
}
