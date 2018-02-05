//
//  Path.swift
//  Seven Bridges
//
//  Created by Dillon Fagan on 11/21/17.
//

import Foundation

class Path {
    
    /// All nodes that make up the path.
    var nodes = [Node]()
    
    /// All edges that make up the path.
    var edges = [Edge]()
    
    /// First node in the path.
    var first: Node? {
        return nodes.first
    }
    
    /// Last node in the path.
    var last: Node? {
        return nodes.last
    }
    
    /// Aggregate weight of all edges in the path.
    var weight: Int {
        var w = 0
        
        for edge in edges {
            w += edge.weight
        }
        
        return w
    }
    
    /// Capacity of the path (the minimum edge flow in the path).
    var capacity: Int? {
        if edges.count < 1 {
            return nil
        }
        
        var minimumFlow = edges.first!.flow!
        
        for edge in edges {
            if let flow = edge.flow {
                if flow < minimumFlow {
                    minimumFlow = flow
                }
            } else {
                // not all edges have an initialized flow
                return nil
            }
        }
        
        return minimumFlow
    }
    
    /// Whether the path is a loop (starting node is the same as the last).
    var isLoop: Bool {
        if first == last {
            return true
        } else {
            return false
        }
    }
    
    var description: String {
        var string = ""
        
        for node in nodes {
            string += node.description
            
            if node != nodes.last! {
                string += " → "
            }
        }
        
        return string
    }
    
    init(_ path: Path) {
        self.nodes = path.nodes
        self.edges = path.edges
    }
    
    init(_ edges: [Edge] = [Edge]()) {
        self.edges = edges
        
        nodes = [Node]()
        
        for edge in edges {
            nodes.append(edge.startNode)
            
            if edge == edges.last {
                nodes.append(edge.endNode)
            }
        }
    }
    
    init(_ nodes: [Node]) {
        self.nodes = nodes
        
        edges = [Edge]()
        
        for (i, _) in nodes.enumerated() {
            if i < nodes.count - 1 {
                if let commonEdge = nodes[i].edges.union(nodes[i + 1].edges).first {
                    edges.append(commonEdge)
                }
            }
        }
    }
    
    /// Appends a new edge to the path, given a node.
    ///
    /// - parameter node: A node adjacent to the last node in the path.
    ///
    func append(_ node: Node) {
        nodes.append(node)
        
        if nodes.count > 1 {
            let secondLastNode = nodes[nodes.count - 2]
            let commonEdges = secondLastNode.edges.union(node.edges)
            
            for edge in commonEdges {
                if edge.startNode == secondLastNode && edge.endNode == node {
                    edges.append(edge)
                    
                    break
                }
            }
        }
    }
    
    /// Appends a new edge to the path.
    ///
    /// - parameter edge: The edge to be appended.
    ///
    func append(_ edge: Edge) {
        edges.append(edge)
        
        if edge.startNode != nodes.last {
            nodes.append(edge.startNode)
        }
        
        nodes.append(edge.endNode)
    }
    
    /// Appends a new edge to the path, given two nodes.
    ///
    /// - parameter from: A node at one end of the edge.
    /// - parameter to: Another node at the other end of the edge.
    ///
    func append(from startNode: Node, to endNode: Node) {
        if let commonEdge = startNode.edges.union(endNode.edges).first {
            append(commonEdge)
        }
    }
    
    /// Determines whether a node is in the path.
    ///
    /// - parameter node: The node being searched for in the path.
    ///
    func contains(_ node: Node) -> Bool {
        return nodes.contains(node)
    }
    
    /// Outlines the path gradually, including nodes and edges.
    ///
    /// - parameter duration: The total duration of the outlining.
    /// - parameter delay: The delay, in seconds, between the highlighting of each node in the path.
    ///
    func outline(duration: Int? = nil, delay: Int = 0) {
        for (index, edge) in edges.enumerated() {
            let deadline = delay + index
            
            // highlight
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(deadline), execute: {
                edge.startNode?.isHighlighted = true
                
                edge.isHighlighted = true
                
                edge.endNode?.isHighlighted = true
            })
            
            // unhighlight - if duration is nil, path is outlined indefinitely
            if duration != nil {
                let runtime = delay + duration!
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(runtime), execute: {
                    edge.startNode?.isHighlighted = false
                    
                    edge.isHighlighted = false
                    
                    edge.endNode?.isHighlighted = false
                })
            }
        }
    }
    
    /// Outlines the path gradually, including nodes and edges.
    ///
    /// - parameter duration: The total duration of the outlining.
    /// - parameter delay: The delay, in seconds, between the highlighting of each node in the path.
    ///
    func outline(delay: Int = 0) {
        var deadline = 0
        
        for (index, edge) in edges.enumerated() {
            deadline = delay + index
            
            // highlight
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(deadline), execute: {
                edge.startNode?.isHighlighted = true
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(deadline + 1), execute: {
                edge.isHighlighted = true
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(nodes.count + edges.count), execute: {
            self.nodes.last?.isHighlighted = true
        })
    }
    
    /// Outlines the path immediately, including nodes and edges.
    func outline() {
        for edge in edges {
            edge.startNode?.isHighlighted = true
            edge.isHighlighted = true
        }
        
        nodes.last?.isHighlighted = true
    }
}
