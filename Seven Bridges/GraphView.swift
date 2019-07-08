//
//  Graph.swift
//  Seven Bridges
//
//  Created by Dillon Fagan on 6/23/17.
//

import UIKit

class GraphView: UIView {
    
    /// ViewController that contains the graph.
    weak var parentVC: ViewController?
    
    let colorGenerator = ColorGenerator()
    
    var graph = Graph()
    
    /// Nodes that have been selected.
    var selectedNodes = [Node]()
    
    /// Returns the selected edge when exactly two adjacent nodes are selected. Otherwise, returns nil.
    var selectedEdge: Edge? {
        return selectedNodes.count == 2 ? graph.edge(from: selectedNodes.first!, to: selectedNodes.last!, isDirected: false) : nil
    }
    
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
            for edge in graph.edges {
                edge.setNeedsDisplay()
            }
        }
    }
    
    /// Clears the graph of all nodes and edges.
    func clear() {
        // remove all subviews from the graph
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        deselectNodes()
        graph = Graph()
        colorGenerator.reset()
        parentVC?.updatePropertiesToolbar()
    }
    
    /// Adds an edge to the graph between two given nodes.
    ///
    /// - parameter from: The edge's start node.
    /// - parameter to: The edge's end node.
    ///
    func addEdge(from a: Node, to b: Node) {
        if a != b && !b.isAdjacent(to: a) {
            let edge = Edge(from: a, to: b)
            addEdge(edge)
        }
        
        deselectNodes()
    }
    
    /// Adds a given edge to the graph.
    ///
    /// - parameter edge: The edge to be added to the graph.
    ///
    func addEdge(_ edge: Edge) {
        graph.add(edge)
        addSubview(edge)
        sendSubviewToBack(edge)
    }
    
    /// Adds a new node to the graph at the location of the touch(es) given.
    ///
    /// - parameter with: The set of touches used to determine the location of the node.
    ///
    private func addNode(with touches: Set<UITouch>) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = Node(color: colorGenerator.nextColor(), at: location)
            node.label.text = String(graph.nodes.count + 1)
            
            graph.add(node)
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
            parentVC?.updatePropertiesToolbar()
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
            for edge in graph.edges {
                edge.flow = nil
                edge.updateLabel()
            }
        }
        
        // unhighlight all nodes and edges
        if unhighlight {
            for node in graph.nodes {
                node.highlighted(false)
            }
            
            for edge in graph.edges {
                edge.highlighted(false)
            }
        }
        
        // remove nodes from selected array
        selectedNodes.removeAll()
        
        parentVC?.updatePropertiesToolbar()
    }
    
    /// Deletes a given node and its edges.
    ///
    /// - parameter node: The node to be deleted.
    ///
    func delete(_ node: Node) {
        node.removeFromSuperview()
        
        for edge in node.edges {
            edge.removeFromSuperview()
        }
        
        graph.remove(node)
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
        
        parentVC?.updatePropertiesToolbar()
    }
    
    /// Removes the selected edge from the Graph.
    /// The two selected nodes on each end will remain selected after the edge is removed.
    func removeSelectedEdge() {
        if let edge = selectedEdge {
            edge.removeFromSuperview()
            graph.remove(edge)
            parentVC?.updatePropertiesToolbar()
        }
    }
    
    /// Removes all edges from the graph.
    func removeAllEdges() {
        for edge in graph.edges {
            edge.removeFromSuperview()
        }
        
        graph.removeAllEdges()
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
        graph.resetAllEdgeWeights(to: weight)
    }
    
    /// Renumbers all nodes by the order that they were added to the graph.
    func renumberNodes() {
        // proceed if there are any nodes to renumber
        guard !graph.nodes.isEmpty else {
            Announcement.new(title: "Renumber Nodes", message: "There are no nodes to renumber.")
            return
        }
        
        // renumber by index + 1
        for (index, node) in graph.nodes.enumerated() {
            node.label.text = String(index + 1)
            node.setNeedsDisplay()
        }
    }
    
    /// Prepares a pre-designed flow network.
    func prepareFlowNetworkExample() {
        clear()
        graph = Graph.flowNetworkTemplate(graphView: self)
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
