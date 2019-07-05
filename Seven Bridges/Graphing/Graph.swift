//
//  Graph.swift
//  Seven Bridges
//
//  Created by Dillon Fagan on 6/23/17.
//

import UIKit

class Graph: UIView {
    
    let colorGenerator = ColorGenerator()
    
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
    
    /// ViewController that contains the graph.
    weak var parentVC: ViewController?
    
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
        colorGenerator.reset()
        
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
            let node = Node(color: colorGenerator.nextColor(), at: location)
            node.label.text = String(nodes.count + 1)
            
            // add node to nodes array
            nodes.append(node)
            
            // add node to matrix representation
            nodeMatrix[node] = Set<Node>()
            
            // add new node to the view
            addSubview(node)
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
        
        if !isDirected {
            // notify user that edges must be directed in order for the algorithm to run
            Announcement.new(title: "Shortest Path", message: "Edges will be made directed in order for the algorithm to run.", action: { (action: UIAlertAction!) -> Void in
                self.isDirected = true
            })
        }
        
        // save source and sink before deselecting nodes
        let a = selectedNodes.first!
        let b = selectedNodes.last!
        
        deselectNodes()
    
        let algorithm = DijkstraShortestPath(self)
        var traversals: [Path] = algorithm.go(from: a, to: b)
        
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
    
    /// Reduces the graph to find a minimum spanning tree using Prim's Algorithm.
    func primMinimumSpanningTree() {
        guard mode == .select && selectedNodes.count == 1 else {
            Announcement.new(title: "Minimum Spanning Tree", message: "Please select a root node before running Prim's Minimum Spanning Tree algorithm.")
            return
        }
        
        mode = .viewOnly // make graph view-only
        
        if isDirected {
            // notify user that edges must be undirected in order for the algorithm to run
            Announcement.new(title: "Minimum Spanning Tree", message: "Edges will be made undirected in order for the algorithm to run.", action: { (action: UIAlertAction!) -> Void in
                self.isDirected = false
            })
        }
        
        let algorithm = PrimMinimumSpanningTree(self)
        let path = algorithm.go()
        path.outline(wait: 0)
    }
    
    /// Kruskal's Algorithm
    func kruskalMinimumSpanningTree() {
        // enter select mode in order to properly clear highlighted edges when algorithm completes
        parentVC?.enterSelectMode((parentVC?.selectModeButton)!)
        
        mode = .viewOnly
        
        if isDirected {
            // notify user that edges must be undirected in order for the algorithm to run
            Announcement.new(title: "Minimum Spanning Tree", message: "Edges will be made undirected in order for the algorithm to run.", action: { (action: UIAlertAction!) -> Void in
                self.isDirected = false
            })
        }
        
        deselectNodes()
        
        let algorithm = KruskalMinimumSpanningTree(self)
        let result = algorithm.go()
        result.outline()
    }
    
    func fordFulkersonMaxFlow() {
        guard mode == .select && selectedNodes.count == 2 else {
            Announcement.new(title: "Ford-Fulkerson", message: "Please select two nodes for calculating max flow before running the Ford-Fulkerson algorithm.")
            return
        }
        
        mode = .viewOnly
        
        let source = selectedNodes.first!
        let sink = selectedNodes.last!
        deselectNodes()
        
        let algorithm = FordFulkersonMaxFlow(self)
        
        let maxFlow = algorithm.go(from: source, to: sink)
        let iterations = algorithm.iterations
        
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
        
        let algorithm = BronKerboschMaxClique(self)
        let maxClique = algorithm.go()
        
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
            let node = Node(color: colorGenerator.nextColor(), at: point)
            
            node.label.text = String(i)
            
            nodeMatrix[node] = Set<Node>()
            nodes.append(node)
            addSubview(node)
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
