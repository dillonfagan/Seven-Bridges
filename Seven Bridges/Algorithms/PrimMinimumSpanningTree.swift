import Foundation

public class PrimMinimumSpanningTree: Algorithm {
    
    private var pool: Set<Node>!
    private var distance = [Node: Int]() // distance from a node to the root
    private var parent = [Node: Node?]()
    private var children = [Node: [Node]]()
    
    override init(_ graph: Graph) {
        super.init(graph)
        pool = Set<Node>(self.graph.nodes)
    }
    
    func go() -> Path {
        // finds the node with the minimum distance from a dictionary
        func getMin(from d: [Node: Int]) -> Node {
            var shortest: Node?
            
            for (node, distance) in d {
                if shortest == nil || distance < d[shortest!]! {
                    shortest = node
                }
            }
            
            return shortest!
        }
        
        // "initialize" all nodes
        for node in pool {
            distance[node] = Int.max // distance is "infinity"
            parent[node] = nil
            children[node] = [Node]()
        }
        
        let root = graph.selectedNodes.first!
        distance[root] = 0 // distance from root to itself is 0
        
        while !pool.isEmpty {
            let currentNode = getMin(from: distance)
            
            distance.removeValue(forKey: currentNode)
            pool.remove(currentNode)
            
            for nextNode in currentNode.adjacentNodes(directed: false) {
                if let edge = currentNode.getEdge(to: nextNode) {
                    let newDistance = edge.weight
                    
                    if pool.contains(nextNode) && newDistance < distance[nextNode]! {
                        parent[nextNode] = currentNode
                        children[currentNode]!.append(nextNode)
                        distance[nextNode] = newDistance
                    }
                }
            }
        }
        
        graph.deselectNodes()
        
        return buildPath(from: root)
    }
    
    private func buildPath(from parent: Node, path: Path = Path()) -> Path {
        for child in children[parent]! {
            if let edge = parent.getEdge(to: child) {
                path.append(edge)
                let _ = buildPath(from: child, path: path)
            }
        }
        
        return path
    }
}
