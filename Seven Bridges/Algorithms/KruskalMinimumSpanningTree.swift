import Foundation

public class KruskalMinimumSpanningTree: Algorithm {
    
    func go() -> Path {
        var s = [Edge](graph.edges) // all edges in the graph
        var f = Set<Set<Node>>() // forest of trees
        
        let e = Path() // edges in the final tree
        
        // sort edges by weight
        s = s.sorted(by: {
            $0.weight < $1.weight
        })
        
        // create tree in forest for each node
        for node in graph.nodes {
            var tree = Set<Node>()
            tree.insert(node)
            
            f.insert(tree)
        }
        
        // loop through edges
        for edge in s {
            // tree containing start node of edge
            let u = f.first(where: { set in
                set.contains(edge.startNode!)
            })
            
            // tree containing end node of edge
            let y = f.first(where: { set in
                set.contains(edge.endNode!)
            })
            
            if u != y {
                // union u and y, add to f, and delete u and y
                let uy = u?.union(y!)
                f.remove(u!)
                f.remove(y!)
                f.insert(uy!)
                
                e.append(edge)
            }
        }
        
        return e
    }
}
