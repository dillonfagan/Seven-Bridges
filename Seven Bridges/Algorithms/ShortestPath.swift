import Foundation

public class ShortestPath: Algorithm {
    
    private var traversals = [Path]()
    
    func go(from source: Node, to sink: Node) -> [Path] {
        let _ = findShortestPath(from: source, to: sink)
        return traversals
    }
    
    private func findShortestPath(from source: Node, to sink: Node, along path: Path = Path()) -> Path? {
        let path = Path(path)
        path.append(source)
        
        if sink == source {
            return path
        }
        
        // the shortest path that will be returned
        var shortest: Path?
        
        // equals 0 when shortest is nil
        var shortestAggregateWeight = 0
        
        for node in source.adjacentNodes(directed: graph.isDirected) {
            if !path.contains(node) {
                if let newPath = findShortestPath(from: node, to: sink, along: path) {
                    // add the new path to the history of traversals
                    traversals.append(newPath)
                    
                    // calculate the aggregate weight of newPath
                    let aggregateWeight = newPath.weight
                    
                    if shortest == nil || aggregateWeight < shortestAggregateWeight {
                        shortest = newPath
                        shortestAggregateWeight = aggregateWeight
                    }
                }
            }
        }
        
        return shortest
    }
}
