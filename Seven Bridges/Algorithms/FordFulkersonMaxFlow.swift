import Foundation

public class FordFulkersonMaxFlow: Algorithm {
    
    var reverse = [Edge: Edge]()
    var net = [Node: Set<Edge>]()
    var iterations = 0
    
    func go(from source: Node, to sink: Node) -> Int {
        buildFlowNetwork(&reverse, &net)
        
        var maxFlow = 0
        
        // While there is a path from s to t where all edges have capacity > 0...
        while let path = augmentingPath(network: net, from: source, to: sink) {
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
        
        return maxFlow
    }
    
    fileprivate func buildFlowNetwork(_ reverse: inout [Edge : Edge], _ net: inout [Node : Set<Edge>]) {
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
    fileprivate func augmentingPath(network: [Node: Set<Edge>], from source: Node, to sink: Node, along path: Path = Path()) -> Path? {
        if source == sink {
            return path
        }
        
        for edge in network[source]! {
            if edge.residualCapacity! > 0 && !path.edges.contains(edge) {
                let newPath = Path(path)
                newPath.append(edge, ignoreNodes: true)
                
                if let result = augmentingPath(network: network, from: edge.endNode, to: sink, along: newPath) {
                    return result
                }
            }
        }
        
        return nil
    }
}
