import UIKit

class AlgorithmController {
    
    func dijkstraShortestPath(_ graphView: GraphView) {
        guard graphView.mode == .select && graphView.selectedNodes.count == 2 else {
            Announcement.new(title: "Shortest Path", message: "Please select an origin node and a target node before using the Shortest Path algorithm.")
            return
        }
        
        // do not allow the graph to be altered during execution
        graphView.mode = .viewOnly
        
        if !graphView.isDirected {
            // notify user that edges must be directed in order for the algorithm to run
            Announcement.new(title: "Shortest Path", message: "Edges will be made directed in order for the algorithm to run.", action: { (action: UIAlertAction!) -> Void in
                graphView.isDirected = true
            })
        }
        
        // save source and sink before deselecting nodes
        let a = graphView.selectedNodes.first!
        let b = graphView.selectedNodes.last!
        
        graphView.deselectNodes()
        
        let algorithm = DijkstraShortestPath(graphView.graph)
        var traversals: [Path] = algorithm.go(from: a, to: b, isDirected: graphView.isDirected)
        
        if traversals.count > 1 {
            let shortestPath = traversals.removeLast()
            
            for (i, path) in traversals.enumerated() {
                path.outline(duration: 2, wait: i * 4, color: UIColor.lightGray)
            }
            
            shortestPath.outline(wait: traversals.count * 4)
        } else {
            Announcement.new(title: "Shortest Path", message: "No path found from \(a) to \(b).")
        }
    }
    
    func primMinimumSpanningTree(_ graphView: GraphView) {
        guard graphView.mode == .select && graphView.selectedNodes.count == 1 else {
            Announcement.new(title: "Minimum Spanning Tree", message: "Please select a root node before running Prim's Minimum Spanning Tree algorithm.")
            return
        }
        
        graphView.mode = .viewOnly // make graph view-only
        
        if graphView.isDirected {
            // notify user that edges must be undirected in order for the algorithm to run
            Announcement.new(title: "Minimum Spanning Tree", message: "Edges will be made undirected in order for the algorithm to run.", action: { (action: UIAlertAction!) -> Void in
                graphView.isDirected = false
            })
        }
        
        let algorithm = PrimMinimumSpanningTree(graphView.graph)
        let path = algorithm.go(root: graphView.selectedNodes.first!)
        graphView.deselectNodes()
        path.outline(wait: 0)
    }
    
    func kruskalMinimumSpanningTree(_ graphView: GraphView) {
        // enter select mode in order to properly clear highlighted edges when algorithm completes
        graphView.parentVC?.enterSelectMode((graphView.parentVC?.selectModeButton)!)
        
        graphView.mode = .viewOnly
        
        graphView.deselectNodes()
        
        let algorithm = KruskalMinimumSpanningTree(graphView.graph)
        let tree = algorithm.go()
        
        if graphView.isDirected {
            // notify user that edges must be undirected in order for the algorithm to run
            Announcement.new(title: "Minimum Spanning Tree", message: "Edges will be made undirected in order for the algorithm to run.", action: { (action: UIAlertAction!) -> Void in
                graphView.isDirected = false
                tree.outline()
            })
        } else {
            tree.outline()
        }
    }
    
    func fordFulkersonMaxFlow(_ graphView: GraphView) {
        guard graphView.mode == .select && graphView.selectedNodes.count == 2 else {
            Announcement.new(title: "Ford-Fulkerson", message: "Please select two nodes for calculating max flow before running the Ford-Fulkerson algorithm.")
            return
        }
        
        graphView.mode = .viewOnly
        
        let source = graphView.selectedNodes.first!
        let sink = graphView.selectedNodes.last!
        graphView.deselectNodes()
        
        let algorithm = FordFulkersonMaxFlow(graphView.graph)
        algorithm.go(from: source, to: sink)
        
        // Announce the max flow when all path outlining has completed.
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4 * algorithm.iterations), execute: {
            Announcement.new(title: "Ford-Fulkerson Max Flow", message: "The max flow is \(algorithm.maxFlow).")
        })
    }
    
    func bronKerboschMaxClique(_ graphView: GraphView) {
        guard graphView.graph.nodes.count > 1 else {
            Announcement.new(title: "Bron-Kerbosch Maximal Clique", message: "The graph must have 2 or more nodes in order for Bron-Kerbosch to run.")
            return
        }
        
        // enter select mode in order to properly clear highlighted nodes when algorithm completes
        graphView.parentVC?.enterSelectMode((graphView.parentVC?.selectModeButton)!)
        
        graphView.mode = .viewOnly
        
        let algorithm = BronKerboschMaxClique(graphView.graph)
        let maxClique = algorithm.go()
        
        if maxClique == nil || (maxClique?.isEmpty)! {
            Announcement.new(title: "Bron-Kerbosch", message: "No community could be found in the graph.")
        } else {
            graphView.deselectNodes()
            maxClique?.forEach({ $0.highlighted() })
        }
    }
}
