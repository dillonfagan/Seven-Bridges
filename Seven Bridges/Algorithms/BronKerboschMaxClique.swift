import Foundation

public class BronKerboschMaxClique: Algorithm {
    
    fileprivate var maxClique: Set<Node>?
    
    func go() -> Set<Node>? {
        // initial sets for the algorithm
        var r = Set<Node>()
        var p = Set<Node>(graph.nodes)
        var x = Set<Node>()
        
        recurse(r: &r, p: &p, x: &x)
        
        return maxClique
    }
    
    // recursively finds a clique
    // when finished, the maximal clique should be stored in the maxClique variable
    fileprivate func recurse(r: inout Set<Node>, p: inout Set<Node>, x: inout Set<Node>) {
        if p.isEmpty && x.isEmpty {
            // r should now be a maximal clique, so insert into cliques and return
            if maxClique == nil || r.count > (maxClique?.count)! {
                maxClique = r
            }
            
            return
        }
        
        // create mutable copies of p and x
        var pCopy = Set<Node>(p)
        var xCopy = Set<Node>(x)
        
        for node in p {
            r.insert(node)
            
            var pu = pCopy.intersection(node.adjacentNodes(directed: false))
            var xu = xCopy.intersection(node.adjacentNodes(directed: false))
            
            recurse(r: &r, p: &pu, x: &xu)
            
            r.remove(node)
            pCopy.remove(node)
            xCopy.insert(node)
        }
    }
}
