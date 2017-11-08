//
//  GraphView.swift
//  Seven Bridges
//
//  Created by Dillon Fagan on 6/23/17.
//

import UIKit

@IBDesignable class Graph: UIScrollView {
    
    /// Border color of the Graph.
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            
            return nil
        }
        
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        
        set {
            layer.borderWidth = newValue
        }
    }
    
    /// Mode defining the action performed by user interaction.
    enum Mode {
        case select
        case view
        case nodes
        case edges
    }
    
    /// Determines the interactive behavior of the Graph.
    var mode = Mode.nodes
    
    /// Determines whether the graph draws directed or undirected edges.
    var isDirected: Bool = true {
        didSet {
            for edge in edges {
                edge.setNeedsDisplay()
            }
        }
    }
    
    /// The root node of the graph; mostly used for tree algorithms.
    /// By default, the root is the first node added to the Graph.
    var root: Node!
    
    /// All nodes in the graph.
    var nodes = [Node]()
    
    /// All edges in the graph.
    var edges = Set<Edge>()
    
    /// Matrix representation of the graph.
    var matrixForm = [Node: Set<Node>]()
    
    /// List representation of the graph.
    var listForm = [Node: Node?]()
    
    /// Nodes that have been selected.
    var selectedNodes = [Node]()
    
    /// Current index in the colors array for cycling through.
    private var colorCycle = 0
    
    /// Colors to cycle through when making a new node.
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
    
    private var vc: ViewController?
    
    func assignViewController(_ vc: ViewController) {
        self.vc = vc
    }
    
    /// Clears the graph of all nodes and edges.
    func clear() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        // delete all nodes
        nodes.removeAll()
        
        // delete all edges
        edges.removeAll()
        
        // reset matrix form
        matrixForm.removeAll()
        
        // reset list form
        listForm.removeAll()
        
        // reset color cycle
        colorCycle = 0
        
        // deselect all selected nodes
        selectedNodes.removeAll()
    }
    
    // Selects a start node for making a new edge.
    func makeEdge(from startNode: Node) {
        selectedNodes.append(startNode)
        
        startNode.isSelected = true
    }
    
    // Makes a new edge between the selected node and an end node.
    func makeEdge(to endNode: Node) {
        guard selectedNodes.count == 1 else { return }
        
        // check if start node and end node are not the same
        // if so, make an edge
        if endNode != selectedNodes[0] && !endNode.isAdjacent(to: selectedNodes[0]) {
            // create the edge
            let edge = Edge(from: selectedNodes[0], to: endNode)
            
            // add the edge to the graph
            addSubview(edge)
            
            // send edge to the back
            sendSubview(toBack: edge)
            
            edges.insert(edge)
            
            // add new edge to matrix representation
            matrixForm[selectedNodes[0]]?.insert(endNode)
            
            // add new edge to list representation
            listForm[selectedNodes[0]] = endNode
        }
        
        // return selected node to original color config
        selectedNodes[0].isSelected = false
        
        // clear the selected node
        selectedNodes.removeAll()
    }
    
    func getEdge(between firstNode: Node, and secondNode: Node) -> Edge? {
        var selectedEdge: Edge?
        
        // get the edge
        for edge in firstNode.edges {
            if edge.endNode == secondNode || edge.startNode == secondNode {
                selectedEdge = edge
                break
            }
        }
        
        return selectedEdge
    }
    
    // Adds the given node to an array and updates the state of the node.
    func selectNode(_ node: Node) {
        if (selectedNodes.contains(node)) {
            node.isSelected = false
            
            selectedNodes.remove(at: selectedNodes.index(of: node)!)
            
            // hide properties toolbar if no nodes are selected
            if selectedNodes.count == 0 {
                vc?.propertiesToolbar.isHidden = true
            }
        } else {
            // update state of node
            node.isSelected = true
            
            // add node to array
            selectedNodes.append(node)
            
            // show properties toolbar
            vc?.propertiesToolbar.isHidden = false
            
            // update items in the toolbars based on selection
            if selectedNodes.count == 2 {
                if let selectedEdge = getEdge(between: selectedNodes.first!, and: selectedNodes.last!) {
                    vc?.edgeWeightButton.title = "Weight: \(selectedEdge.weight)"
                    vc?.edgeWeightButton.isEnabled = true
                    
                    vc?.removeEdgeButton.title = "Remove \(selectedEdge.description)"
                    vc?.removeEdgeButton.isEnabled = true
                }
            } else {
                vc?.edgeWeightButton.title = ""
                vc?.edgeWeightButton.isEnabled = false
                
                vc?.removeEdgeButton.title = ""
                vc?.removeEdgeButton.isEnabled = false
            }
        }
    }
    
    // Clears the selected nodes array and returns the nodes to their original state.
    func deselectNodes(unhighlight: Bool = false) {
        // return all nodes in selected nodes array to original state
        for node in selectedNodes {
            node.isSelected = false
        }
        
        // unhighlight all nodes
        if unhighlight {
            for node in nodes {
                node.isHighlighted = false
                
                for edge in node.edges {
                    edge.isHighlighted = false
                }
            }
        }
        
        // remove nodes from selected array
        selectedNodes.removeAll()
        
        // hide properties toolbar
        vc?.propertiesToolbar.isHidden = true
    }
    
    /// Deletes a given node and its edges.
    ///
    /// - parameter _: The node to be deleted.
    func deleteNode(_ node: Node) {
        node.removeFromSuperview()
        
        for edge in node.edges {
            edge.removeFromSuperview()
            
            if let index = edge.startNode?.edges.index(of: edge) {
                edge.startNode?.edges.remove(at: index)
            }
            
            if let index = edge.endNode?.edges.index(of: edge) {
                edge.endNode?.edges.remove(at: index)
            }
        }
        
        nodes.remove(at: nodes.index(of: node)!)
        
        matrixForm.removeValue(forKey: node)
        listForm.removeValue(forKey: node)
    }
    
    /// Deletes all selected nodes and their edges.
    func deleteSelectedNodes() {
        guard selectedNodes.count != 0 else { return }
        
        for node in selectedNodes {
            deleteNode(node)
        }
        
        selectedNodes.removeAll()
        
        vc?.propertiesToolbar.isHidden = true
    }
    
    /// Removes the selected edge from the Graph.
    func removeSelectedEdge() {
        if let selectedEdge = getEdge(between: selectedNodes.first!, and: selectedNodes.last!) {
            selectedNodes.first!.edges.remove(selectedEdge)
            selectedNodes.last!.edges.remove(selectedEdge)
            
            edges.remove(selectedEdge)
            
            // remove edge from matrix and list forms
            matrixForm[selectedEdge.startNode]?.remove(selectedEdge.endNode)
            
            listForm[selectedEdge.startNode]? = nil
            
            selectedEdge.removeFromSuperview()
        }
    }
    
    /// Renumbers all nodes by the order that they were added to the graph.
    func renumberNodes() {
        guard !nodes.isEmpty else { return }
        
        outlinePath(nodes, duration: nodes.count, delay: 1)
        
        for (index, node) in nodes.enumerated() {
            node.label.text = String(index + 1)
        }
    }
    
    // Returns the aggregate weight of a given path.
    func aggregateWeight(of path: [Node]) -> Int {
        var weight = 0
        
        for (index, node) in path.enumerated() {
            for edge in node.edges {
                guard index != path.count - 1 else { break }
                
                if edge.startNode == node && edge.endNode == path[index + 1] {
                    weight += edge.weight
                }
            }
        }
        
        return weight
    }
    
    // Outlines each path in an array of paths.
    private func outlineTraversals(_ traversals: [[Node]]) {
        for (index, path) in traversals.enumerated() {
            outlinePath(path, duration: path.count, delay: index * path.count)
        }
    }
    
    /// Outlines a given path, including nodes and edges.
    ///
    /// - parameter _: An array of nodes.
    /// - parameter duration: The total duration of the outlining.
    /// - parameter delay: The delay, in seconds, between the highlighting of each node in the path.
    private func outlinePath(_ path: [Node], duration: Int? = nil, delay: Int = 0) {
        for (index, node) in path.enumerated() {
            var deadline = delay + index
            
            // highlight node after 'index' seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(deadline), execute: {
                node.isHighlighted = true
            })
            
            // unhighlight node after set duration
            if duration != nil {
                let runtime = delay + duration!
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(runtime), execute: {
                    node.isHighlighted = false
                })
            }
            
            // only iterate over edges if this is not the last node in the path
            if index < path.count - 1 {
                for edge in node.edges {
                    // directed
                    if edge.startNode == node && edge.endNode == path[index + 1] {
                        deadline += 1
                        
                        // highlight edge after 'index + 1' seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(deadline), execute: {
                            edge.isHighlighted = true
                        })
                        
                        // unhighlight edge after set duration
                        if duration != nil {
                            let runtime = delay + duration!
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(runtime), execute: {
                                edge.isHighlighted = false
                            })
                        }
                    }
                }
            }
        }
    }
    
    /// Outlines a given path, including nodes and edges.
    ///
    /// - parameter _: An array of edges.
    /// - parameter duration: The total duration of the outlining.
    /// - parameter delay: The delay, in seconds, between the highlighting of each node in the path.
    private func outlinePath(_ path: [Edge], duration: Int? = nil, delay: Int = 0) {
        for (index, edge) in path.enumerated() {
            let deadline = delay + index
            
            let startNode = edge.startNode
            let endNode = edge.endNode
            
            // highlight nodes after 'index' seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(deadline), execute: {
                startNode?.isHighlighted = true
                endNode?.isHighlighted = true
                
                edge.isHighlighted = true
            })
            
            // unhighlight node after set duration
            if duration != nil {
                let runtime = delay + duration!
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(runtime), execute: {
                    startNode?.isHighlighted = false
                    endNode?.isHighlighted = false
                    
                    edge.isHighlighted = false
                })
            }
        }
    }
    
    /// Finds and identifies the shortest path between two selected nodes.
    func findShortestPath() {
        guard mode == .select && selectedNodes.count == 2 else { return }
        
        mode = .view // make the graph view-only during execution (e.g. no dragging)
        
        var traversals = [[Node]]()
        var steps = 0
        
        func findShortestPath(from origin: Node, to target: Node, shortestPath: [Node] = [Node]()) -> [Node]? {
            var path = shortestPath
            path.append(origin)
            
            if target == origin {
                return path
            }
            
            var shortest: [Node]?
            var shortestAggregateWeight = 0 // equals 0 when shortest is nil
            
            for node in matrixForm[origin]! {
                if !path.contains(node) {
                    if let newPath = findShortestPath(from: node, to: target, shortestPath: path) {
                        
                        // add the new path to the history of traversals
                        traversals.append(newPath)
                        
                        // add the count of the nodes to the steps???
                        steps += newPath.count
                        
                        // calculate the aggregate weight of newPath
                        let aggregateWeight = self.aggregateWeight(of: newPath)
                        
                        if shortest == nil || aggregateWeight < shortestAggregateWeight {
                            shortest = newPath
                            shortestAggregateWeight = aggregateWeight
                        }
                    }
                }
            }
            
            return shortest
        }
        
        let originNode = selectedNodes.first!
        let targetNode = selectedNodes.last!
        
        deselectNodes()
        
        if let path = findShortestPath(from: originNode, to: targetNode) {
            // remove the shortest path from the traversal history
            traversals.removeLast()
            
            // outline the traversals
            outlineTraversals(traversals)
            
            // outline the shortest path
            outlinePath(path, delay: steps)
        } else {
            // create modal alert for no path found
            let message = "No path found from \(originNode) to \(targetNode)."
            
            let alert = UIAlertController(title: "Shortest Path", message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // present alert
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Reduces the graph to find a minimum spanning tree using Prim's Algorithm.
    func prim() {
        guard mode == .select && selectedNodes.count == 1 else { return }
        
        mode = .view
        
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
        
        root = selectedNodes.first!
        distance[root] = 0 // distance from root to itself is 0
        
        while !pool.isEmpty {
            let currentNode = getMin(from: distance)
            distance.removeValue(forKey: currentNode)
            pool.remove(currentNode)
            
            for nextNode in currentNode.adjacentNodes {
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
        
        // tree as path of edges
        var path = [Edge]()
        
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
        
        outlinePath(path)
    }
    
    /// Kruskal's Algorithm
    func kruskal() {
        var s = [Edge](edges) // all edges in the graph
        var f = Set<Set<Node>>() // forest of trees
        var e = [Edge]() // edges in the final tree
        
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
        
        outlinePath(e)
    }
    
    func editSelectedEdgeWeight() {
        guard selectedNodes.count == 2 else { return }
        
        if let editingEdge = getEdge(between: selectedNodes.first!, and: selectedNodes.last!) {
            // TODO: set weight from number chooser
            if editingEdge.weight < nodes.count {
                editingEdge.weight += 1
            } else {
                editingEdge.weight = 1
            }
            
            // update weight label
            vc?.edgeWeightButton.title = "Weight: \(editingEdge.weight)"
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // continue if graph is in nodes mode
        guard mode == .nodes else { return }
        
        // make new node where the graph view was touched
        makeNode(with: touches)
    }
    
    /// Makes a new node at the location of the touch(es) given.
    private func makeNode(with touches: Set<UITouch>) {
        for touch in touches {
            // get location of the touch
            let location = touch.location(in: self)
            
            // create new node at location of touch
            let node = Node(color: colors[colorCycle], at: location)
            node.label.text = String(nodes.count + 1)
            
            // add node to nodes array
            nodes.append(node)
            
            // add node to matrix representation
            matrixForm[node] = Set<Node>()
            
            // add node to list representation
            listForm[node] = nil
            
            // add new node to the view
            addSubview(node)
            
            // cycle through colors
            if colorCycle < colors.count - 1 {
                colorCycle += 1
            } else {
                colorCycle = 0
            }
        }
    }
    
}
