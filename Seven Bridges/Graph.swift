//
//  Graph.swift
//  Seven Bridges
//
//  Created by Dillon Fagan on 6/23/17.
//

import UIKit

/// Used to define the behavior or presentation of a Graph object.
enum GraphMode {
    case select
    case viewOnly
    case nodes
    case edges
}

class Graph: UIScrollView {
    
    /// Determines the interactive behavior of the graph.
    /// When the graph is in view-only mode, the actions menu in the main view controller will be disabled.
    var mode: GraphMode = .nodes {
        didSet {
            if mode == .viewOnly {
                parentVC?.actionsMenuButton.isEnabled = false
            } else {
                parentVC?.actionsMenuButton.isEnabled = true
            }
        }
    }
    
    /// Determines whether the graph draws directed or undirected edges.
    var isDirected: Bool = true {
        didSet {
            for edge in edges {
                edge.setNeedsDisplay()
            }
        }
    }
    
    /// All nodes in the graph.
    var nodes = [Node]()
    
    /// All edges in the graph.
    var edges = Set<Edge>()
    
    /// Matrix representation of the graph.
    var nodeMatrix = [Node: Set<Node>]()
    
    /// Nodes that have been selected.
    var selectedNodes = [Node]()
    
    /// Returns the selected edge when exactly two adjacent nodes are selected. Otherwise, returns nil.
    var selectedEdge: Edge? {
        guard selectedNodes.count == 2 else { return nil }
        
        return edge(from: selectedNodes.first!, to: selectedNodes.last!, directed: false)
    }
    
    /// Current index in the colors array for cycling through.
    private var colorCycle = 0
    
    /// Colors to cycle through when adding a new node to the graph.
    private let colors = [
        // green
        UIColor(red: 100/255, green: 210/255, blue: 185/255, alpha: 1.0),
        
        // pink
        UIColor(red: 235/255, green: 120/255, blue: 180/255, alpha: 1.0),
        
        // blue
        UIColor(red: 90/255, green: 160/255, blue: 235/255, alpha: 1.0),
        
        // yellow
        UIColor(red: 245/255, green: 200/255, blue: 90/255, alpha: 1.0),
        
        // purple
        UIColor(red: 195/255, green: 155/255, blue: 245/255, alpha: 1.0)
    ]
    
    /// ViewController that contains the graph.
    weak var parentVC: ViewController?
    
    /// Increments the cycle of the color assigned to the next node that is created.
    private func incrementColorCycle() {
        if colorCycle < colors.count - 1 {
            colorCycle += 1
        } else {
            colorCycle = 0
        }
    }
    
    /// Clears the graph of all nodes and edges.
    func clear() {
        // remove all subviews from the graph
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        // delete all nodes
        nodes.removeAll()
        
        // delete all edges
        edges.removeAll()
        
        // reset matrix form
        nodeMatrix.removeAll()
        
        // reset color cycle
        colorCycle = 0
        
        // deselect all selected nodes
        selectedNodes.removeAll()
        
        // update the properties toolbar so that it is hidden
        updatePropertiesToolbar()
    }
    
    /// Returns an edge in the graph given a start node and an end node. If no matching edge exists, returns nil.
    ///
    /// - parameter from: The edge's start node.
    /// - parameter to: The edge's end node.
    /// - parameter directed: Whether edge direction should be considered.
    ///
    func edge(from a: Node, to b: Node, directed: Bool = true) -> Edge? {
        if directed {
            return edges.first(where: { $0.startNode == a && $0.endNode == b })
        } else {
            for edge in a.edges {
                if edge.endNode == b || edge.startNode == b {
                    return edge
                }
            }
            
            // a matching edge could not be found
            return nil
        }
    }
    
    /// Adds an edge to the graph between two given nodes.
    ///
    /// - parameter from: The edge's start node.
    /// - parameter to: The edge's end node.
    ///
    func addEdge(from a: Node, to b: Node) {
        // check to make sure a and b are not the same node and do not already have a common edge
        if a != b && !b.isAdjacent(to: a) {
            // create the edge
            let edge = Edge(from: a, to: b)
            
            // add edge to the graph
            addSubview(edge)
            
            // send edge to the back
            sendSubviewToBack(edge)
            
            // add to edge set
            edges.insert(edge)
            
            // add connection to matrix
            nodeMatrix[a]?.insert(b)
        }
        
        // deselect nodes
        a.isSelected = false
        b.isSelected = false
        
        // clear selected nodes
        selectedNodes.removeAll()
    }
    
    /// Adds a given edge to the graph.
    ///
    /// - parameter edge: The edge to be added to the graph.
    ///
    func addEdge(_ edge: Edge) {
        // add edge to the graph
        addSubview(edge)
        
        // send edge to the back
        sendSubviewToBack(edge)
        
        // add to edge set
        edges.insert(edge)
        
        // add connection to matrix
        nodeMatrix[edge.startNode]?.insert(edge.endNode)
    }
    
    /// Adds a new node to the graph at the location of the touch(es) given.
    ///
    /// - parameter with: The set of touches used to determine the location of the node.
    ///
    private func addNode(with touches: Set<UITouch>) {
        for touch in touches {
            // get location of the touch
            let location = touch.location(in: self)
            
            // create new node at location of touch
            let node = Node(color: colors[colorCycle], at: location)
            node.label.text = String(nodes.count + 1)
            
            // add node to nodes array
            nodes.append(node)
            
            // add node to matrix representation
            nodeMatrix[node] = Set<Node>()
            
            // add new node to the view
            addSubview(node)
            
            incrementColorCycle()
        }
    }
    
    /// Adds the given node to the selectedNodes array and updates the state of the node.
    ///
    /// - parameter node: The node to be selected.
    ///
    func select(_ node: Node) {
        // if the node is already selected, deselect it
        // otherwise, select it
        if (selectedNodes.contains(node)) {
            // update state of node
            node.isSelected = false
            
            // remove node from the array
            selectedNodes.remove(at: selectedNodes.firstIndex(of: node)!)
        } else {
            // update state of node
            node.isSelected = true
            
            // add node to array
            selectedNodes.append(node)
        }
        
        // as long as the graph is in select mode, update the properties toolbar
        if mode == .select {
            updatePropertiesToolbar()
        }
    }
    
    /// Updates the appearance of the properties toolbar based on which nodes are selected.
    private func updatePropertiesToolbar() {
        // hide the toolbar if no nodes are selected
        if selectedNodes.isEmpty {
            parentVC?.trashButton.isEnabled = false
        } else {
            parentVC?.trashButton.isEnabled = true
        }
        
        // detect a selected edge between two nodes
        // if nil, disable UI elements related to a selected edge
        if let edge = selectedEdge {
            parentVC?.edgeWeightIndicator.title = String(edge.weight)
            
            parentVC?.edgeWeightMinusButton.title = "-"
            parentVC?.edgeWeightMinusButton.isEnabled = true
            
            parentVC?.edgeWeightPlusButton.title = "+"
            parentVC?.edgeWeightPlusButton.isEnabled = true
            
            parentVC?.removeEdgeButton.title = "Remove \(edge)"
            parentVC?.removeEdgeButton.isEnabled = true
        } else {
            parentVC?.edgeWeightIndicator.title = ""
            parentVC?.edgeWeightIndicator.isEnabled = false
            
            parentVC?.edgeWeightMinusButton.title = ""
            parentVC?.edgeWeightMinusButton.isEnabled = false
            
            parentVC?.edgeWeightPlusButton.title = ""
            parentVC?.edgeWeightPlusButton.isEnabled = false
            
            parentVC?.removeEdgeButton.title = ""
            parentVC?.removeEdgeButton.isEnabled = false
        }
    }
    
    /// Clears the selected nodes array and returns the nodes to their original state.
    ///
    /// - parameter unhighlight: If unhighlight is true, all nodes and edges will be unhighlighted.
    /// - parameter resetEdgeProperties: If true, edge flow for each edge will be reset to nil.
    ///
    func deselectNodes(unhighlight: Bool = false, resetEdgeProperties: Bool = false) {
        // return all nodes in selected nodes array to original state
        for node in selectedNodes {
            node.isSelected = false
        }
        
        // if resetEdgeProperties is true, reset flow for all edges back to nil
        if resetEdgeProperties {
            for edge in edges {
                edge.flow = nil
                edge.updateLabel()
            }
        }
        
        // unhighlight all nodes and edges
        if unhighlight {
            for node in nodes {
                node.highlighted(false)
            }
            
            for edge in edges {
                edge.highlighted(false)
            }
        }
        
        // remove nodes from selected array
        selectedNodes.removeAll()
        
        updatePropertiesToolbar()
    }
    
    /// Deletes a given node and its edges.
    ///
    /// - parameter node: The node to be deleted.
    ///
    func delete(_ node: Node) {
        // remove it from view
        node.removeFromSuperview()
        
        for edge in node.edges {
            // remove edge from view
            edge.removeFromSuperview()
            
            // remove edge from its start node
            if let index = edge.startNode?.edges.firstIndex(of: edge) {
                edge.startNode?.edges.remove(at: index)
            }
            
            // remove edge from its end node
            if let index = edge.endNode?.edges.firstIndex(of: edge) {
                edge.endNode?.edges.remove(at: index)
            }
        }
        
        // remove node from the nodes array
        nodes.remove(at: nodes.firstIndex(of: node)!)
        
        // remove node from the matrix
        nodeMatrix.removeValue(forKey: node)
    }
    
    /// Deletes all selected nodes and their edges.
    func deleteSelectedNodes() {
        // proceed only if selectedNodes is not empty
        guard !selectedNodes.isEmpty else { return }
        
        // delete all selected nodes
        for node in selectedNodes {
            delete(node)
        }
        
        // empty the selectedNodes array
        selectedNodes.removeAll()
        
        updatePropertiesToolbar()
    }
    
    /// Removes the selected edge from the Graph.
    /// The two selected nodes on each end will remain selected after the edge is removed.
    func removeSelectedEdge() {
        if let edge = selectedEdge {
            // remove from view
            edge.removeFromSuperview()
            
            // remove from both ends (nodes)
            selectedNodes.first!.edges.remove(edge)
            selectedNodes.last!.edges.remove(edge)
            
            // remove from edges set
            edges.remove(edge)
            
            // remove edge from matrix
            nodeMatrix[edge.startNode]?.remove(edge.endNode)
            
            updatePropertiesToolbar()
        }
    }
    
    /// Removes all edges from the graph.
    func removeAllEdges() {
        // remove all edges from each node and empty all connections from the matrix
        for node in nodes {
            node.edges.removeAll()
            nodeMatrix[node]?.removeAll()
        }
        
        // remove all edges from view
        for edge in edges {
            edge.removeFromSuperview()
        }
        
        // remove all from edges set
        edges.removeAll()
    }
    
    /// Shifts a selected edge's weight by a given integer value.
    ///
    /// - parameter by: The value by which to shift the edge's weight.
    ///
    func shiftSelectedEdgeWeight(by delta: Int) {
        if let edge = selectedEdge {
            edge.weight += delta
            edge.updateLabel()
            
            // update weight label
            parentVC?.edgeWeightIndicator.title = String(edge.weight)
        }
    }
    
    /// Changes all edge weights to the given weight or resets them all to the default value of 1.
    ///
    /// - parameter to: The weight that will be applied to all edges.
    ///
    func resetAllEdgeWeights(to weight: Int = 1) {
        for edge in edges {
            edge.weight = weight
            edge.updateLabel()
        }
    }
    
    /// Renumbers all nodes by the order that they were added to the graph.
    func renumberNodes() {
        // proceed if there are any nodes to renumber
        guard !nodes.isEmpty else {
            Announcement.new(title: "Renumber Nodes", message: "There are no nodes to renumber.")
            return
        }
        
        // renumber by index + 1
        for (index, node) in nodes.enumerated() {
            node.label.text = String(index + 1)
            node.setNeedsDisplay()
        }
    }
    
    /// Finds and identifies the shortest path between two selected nodes.
    func shortestPath() {
        guard mode == .select && selectedNodes.count == 2 else {
            Announcement.new(title: "Shortest Path", message: "Please select an origin node and a target node before using the Shortest Path algorithm.")
            return
        }
        
        // do not allow the graph to be altered during execution
        mode = .viewOnly
        
        // the function that will be resumed should requirements be met
        func resumeFunction() {
            var traversals = [Path]()
            
            func findShortestPath(from source: Node, to sink: Node, along path: Path = Path()) -> Path? {
                let path = Path(path)
                path.append(source)
                
                if sink == source {
                    return path
                }
                
                // the shortest path that will be returned
                var shortest: Path?
                
                // equals 0 when shortest is nil
                var shortestAggregateWeight = 0
                
                for node in source.adjacentNodes(directed: isDirected) {
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
            
            // save source and sink before deselecting nodes
            let a = selectedNodes.first!
            let b = selectedNodes.last!
            
            deselectNodes()
            
            if let path = findShortestPath(from: a, to: b) {
                // remove the shortest path from the traversal history
                traversals.removeLast()
                
                // outline the traversals
                for (i, path) in traversals.enumerated() {
                    path.outline(duration: 2, wait: i * 4, color: UIColor.lightGray)
                }
                
                // outline the shortest path
                path.outline(wait: traversals.count * 4)
            } else {
                // create modal alert for no path found
                Announcement.new(title: "Shortest Path", message: "No path found from \(a) to \(b).")
            }
        }
        
        if !isDirected {
            // notify user that edges must be directed in order for the algorithm to run
            Announcement.new(title: "Shortest Path", message: "Edges will be made directed in order for the algorithm to run.", action: { (action: UIAlertAction!) -> Void in
                self.isDirected = true
                resumeFunction()
            })
        } else {
            resumeFunction()
        }
    }
    
    /// Reduces the graph to find a minimum spanning tree using Prim's Algorithm.
    func primMinimumSpanningTree() {
        guard mode == .select && selectedNodes.count == 1 else {
            Announcement.new(title: "Minimum Spanning Tree", message: "Please select a root node before running Prim's Minimum Spanning Tree algorithm.")
            return
        }
        
        mode = .viewOnly // make graph view-only
        
        func resumeFunction() {
            var pool = Set<Node>(nodes) // all nodes
            var distance = [Node: Int]() // distance from a node to the root
            var parent = [Node: Node?]()
            var children = [Node: [Node]]()
            
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
            
            var root = selectedNodes.first!
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
            
            deselectNodes()
            
            // tree as path of edges
            var path = Path()
            
            // recurses through the children dictionary to build a path of edges
            func buildPath(from parent: Node) {
                for child in children[parent]! {
                    if let edge = parent.getEdge(to: child) {
                        path.append(edge)
                        buildPath(from: child)
                    }
                }
            }
            
            buildPath(from: root)
            
            path.outline(wait: 0)
        }
        
        if isDirected {
            // notify user that edges must be undirected in order for the algorithm to run
            Announcement.new(title: "Minimum Spanning Tree", message: "Edges will be made undirected in order for the algorithm to run.", action: { (action: UIAlertAction!) -> Void in
                self.isDirected = false
                resumeFunction()
            })
        } else {
            resumeFunction()
        }
    }
    
    /// Kruskal's Algorithm
    func kruskalMinimumSpanningTree() {
        // enter select mode in order to properly clear highlighted edges when algorithm completes
        parentVC?.enterSelectMode((parentVC?.selectModeButton)!)
        
        mode = .viewOnly
        
        func resumeFunction() {
            var s = [Edge](edges) // all edges in the graph
            var f = Set<Set<Node>>() // forest of trees
            
            let e = Path() // edges in the final tree
            
            // sort edges by weight
            s = s.sorted(by: {
                $0.weight < $1.weight
            })
            
            // create tree in forest for each node
            for node in nodes {
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
            
            deselectNodes()
            
            e.outline()
        }
        
        if isDirected {
            // notify user that edges must be undirected in order for the algorithm to run
            Announcement.new(title: "Minimum Spanning Tree", message: "Edges will be made undirected in order for the algorithm to run.", action: { (action: UIAlertAction!) -> Void in
                self.isDirected = false
                resumeFunction()
            })
        } else {
            resumeFunction()
        }
    }
    
    /// Ford-Fulkerson max flow algorithm
    func fordFulkersonMaxFlow() {
        guard mode == .select && selectedNodes.count == 2 else {
            Announcement.new(title: "Ford-Fulkerson", message: "Please select two nodes for calculating max flow before running the Ford-Fulkerson algorithm.")
            return
        }
        
        mode = .viewOnly
        
        let source = selectedNodes.first!
        let sink = selectedNodes.last!
        deselectNodes()
        
        // Create a network structure to emulate a residual graph.
        var reverse = [Edge: Edge]()
        var net = [Node: Set<Edge>]()
        for edge in edges {
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
        
        // Returns an augmenting path if one exists. Otherwise, returns nil.
        func augmentingPath(from source: Node, to sink: Node, along path: Path = Path()) -> Path? {
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
        
        // Counts the path iterations in order to properly delay the announcement after path outlining is done.
        var iterations = 0
        
        var maxFlow = 0
        
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
        
        // Announce the max flow when all path outlining has completed.
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4 * iterations), execute: {
            Announcement.new(title: "Ford-Fulkerson Max Flow", message: "The max flow is \(maxFlow).")
        })
    }
    
    /// Bron-Kerbosch maximal clique algorithm
    func bronKerbosch() {
        guard nodes.count > 1 else {
            Announcement.new(title: "Bron-Kerbosch Maximal Clique", message: "The graph must have 2 or more nodes in order for Bron-Kerbosch to run.")
            return
        }
        
        // enter select mode in order to properly clear highlighted nodes when algorithm completes
        parentVC?.enterSelectMode((parentVC?.selectModeButton)!)
        
        mode = .viewOnly
        
        // stores the clique iteration with the most nodes
        // this will hold the maximal clique
        var maxClique: Set<Node>?
        
        // recursively finds a clique
        // when finished, the maximal clique should be stored in the maxClique variable
        func recurse(r: inout Set<Node>, p: inout Set<Node>, x: inout Set<Node>) {
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
        
        // initial sets for the algorithm
        var r = Set<Node>()
        var p = Set<Node>(nodes)
        var x = Set<Node>()
        
        recurse(r: &r, p: &p, x: &x)
        
        if maxClique == nil || (maxClique?.isEmpty)! {
            Announcement.new(title: "Bron-Kerbosch", message: "No community could be found in the graph.")
        } else {
            // highlight the max clique
            maxClique?.forEach({ $0.highlighted() })
        }
    }
    
    /// Prepares a pre-designed flow network.
    func prepareFlowNetworkExample() {
        clear()
        
        // the amount by which the x and y coordinates of each node should be adjusted
        // relative to the bounds of the Graph
        let dx = floor(bounds.width / 3.5)
        let dy = min(floor(bounds.height / 3), 250)
        
        for i in 1...4 {
            var x = bounds.midX
            var y = bounds.midY
            
            switch i {
            case 1:
                x -= dx
            case 2:
                y -= dy
            case 3:
                y += dy
            case 4:
                x += dx
            default:
                continue
            }
            
            let point = CGPoint(x: x, y: y)
            let node = Node(color: colors[colorCycle], at: point)
            
            node.label.text = String(i)
            
            nodeMatrix[node] = Set<Node>()
            nodes.append(node)
            addSubview(node)
            
            incrementColorCycle()
        }
        
        // create edge from 1 to 2
        let first = Edge(from: nodes[0], to: nodes[1])
        first.weight = 5
        first.updateLabel()
        addEdge(first)
        
        // edge from 1 to 3
        let second = Edge(from: nodes[0], to: nodes[2])
        second.weight = 5
        second.updateLabel()
        addEdge(second)
        
        // edge from 2 to 3
        let third = Edge(from: nodes[1], to: nodes[2])
        third.weight = 3
        third.updateLabel()
        addEdge(third)
        
        // edge from 2 to 4
        let fourth = Edge(from: nodes[1], to: nodes[3])
        fourth.weight = 3
        fourth.updateLabel()
        addEdge(fourth)
        
        // edge from 3 to 4
        let fifth = Edge(from: nodes[2], to: nodes[3])
        fifth.weight = 7
        fifth.updateLabel()
        addEdge(fifth)
    }
    
    /// Called when all touches on the screen have ended.
    ///
    /// - parameter touches: The set of touches on the screen.
    /// - parameter with: The UIEvent associated with the touches.
    ///
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // continue only if graph is in nodes mode
        guard mode == .nodes else { return }
        
        // make new node where the graph view was touched
        addNode(with: touches)
    }
    
}
