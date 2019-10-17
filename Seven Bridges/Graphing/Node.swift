//
//  Node.swift
//  Seven Bridges
//
//  Created by Dillon Fagan on 6/23/17.
//

import UIKit

@IBDesignable class Node: UIView {
    
    /// Diameter of the node.
    static let diameter: CGFloat = 48
    
    /// Radius of the node, computed as half the diameter.
    static let radius: CGFloat = diameter / 2
    
    /// Edges connected to the node.
    var edges = Set<Edge>()
    
    /// Flow coming into the node from connected edges.
    var inboundFlow: Int {
        var flowSum = 0
        
        edges.filter({ $0.endNode! == self }).forEach({
            if let flow = $0.flow {
                flowSum += flow
            }
        })
        
        return flowSum
    }
    
    /// Flow coming out of the node from connected edges.
    var outboundFlow: Int {
        var flowSum = 0
        
        edges.filter({ $0.startNode! == self }).forEach({
            if let flow = $0.flow {
                flowSum += flow
            }
        })
        
        return flowSum
    }
    
    /// Width of the node's border.
    static var lineWidth: CGFloat = diameter / 6
    
    /// Whether the node is in the selected state.
    var isSelected: Bool = false {
        didSet {
            if self.isSelected {
                fillColor = UIColor.white
                label.textColor = initialColor
            } else {
                fillColor = initialColor
                label.textColor = UIColor.white
            }
        }
    }
    
    /// Whether the node is highlighted.
    var isHighlighted: Bool = false
    
    /// Color that the node is initialized with.
    private let initialColor: UIColor
    
    /// Color of the node's border stroke.
    var strokeColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Color of the node's center fill.
    var fillColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Unified color of the node's fill and border.
    var color: UIColor! {
        didSet {
            strokeColor = self.color
            fillColor = self.color
        }
    }
    
    /// Label for the node.
    var label = UILabel()
    
    /// Whether the node is currently being dragged by the user.
    private var isBeingDragged = false
    
    override var description: String {
        if let number = label.text {
            return "Node \(number)"
        } else {
            return "Unknown Node"
        }
    }
    
    init(color: UIColor = UIColor.lightGray, at location: CGPoint) {
        initialColor = color
        
        super.init(frame: CGRect(x: location.x - Node.radius, y: location.y - Node.radius, width: Node.diameter, height: Node.diameter))
        
        // set the colors
        self.color = color
        strokeColor = self.color
        fillColor = self.color
        
        // set up the label
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = NSTextAlignment.center
        
        // enable user interaction
        isUserInteractionEnabled = true
        
        // set background color to clear
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        initialColor = UIColor.lightGray
        
        super.init(coder: aDecoder)
        
        isUserInteractionEnabled = true
        backgroundColor = UIColor.clear
    }
    
    /// All nodes adjacent to this node.
    ///
    /// - parameter directed: Whether direction should be accounted for.
    ///
    func adjacentNodes(directed: Bool = true) -> Set<Node> {
        var results = Set<Node>()
        
        for edge in edges {
            if edge.startNode! != self && !directed {
                results.insert(edge.startNode!)
            } else if edge.endNode! != self {
                results.insert(edge.endNode!)
            }
        }
        
        return results
    }
    
    /// Determines whether a given node is adjacent to this node.
    ///
    /// - parameter to: The node to test whether it is adjacent.
    ///
    func isAdjacent(to node: Node, directed: Bool = true) -> Bool {
        if adjacentNodes(directed: directed).contains(node) {
            return true
        } else {
            return false
        }
    }
    
    /// Returns an edge connecting this node to a given node.
    ///
    /// - parameter node: An adjacent node.
    ///
    func getEdge(to node: Node, directed: Bool = false) -> Edge? {
        for edge in edges {
            if edge.startNode! == self && edge.endNode! == node {
                return edge
            }
            
            if !directed && edge.endNode! == self && edge.startNode! == node {
                return edge
            }
        }
        
        return nil
    }
    
    /// Finds the edge with the lowest weight connected to the node.
    ///
    /// - parameter directed: Whether finding the cheapest edge should account for a directed graph.
    ///
    func cheapestEdge(directed: Bool = false) -> Edge? {
        if edges.isEmpty {
            return nil
        }
        
        var cheapest: Edge? = edges.first
        for edge in edges {
            if directed && edge.endNode == self {
                continue
            }
            
            if edge.weight < cheapest!.weight {
                cheapest = edge
            }
        }
        
        return cheapest
    }
    
    /// Highlights or unhighlights the node.
    ///
    /// - parameter enable: Whether the node is being highlighted or unhighlighted.
    /// - parameter color: The color used to highlight the node.
    ///
    func highlighted(_ enable: Bool = true, color: UIColor = UIColor.black) {
        if enable {
            self.color = color
        } else {
            self.color = initialColor
        }
        
        isHighlighted = enable
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: rect.insetBy(dx: Node.lineWidth / 2, dy: Node.lineWidth / 2))
        path.lineWidth = Node.lineWidth
        
        fillColor.setFill()
        path.fill()
        
        strokeColor.setStroke()
        path.stroke()
        
        label.drawText(in: rect)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // bring touched node to front
        superview?.bringSubviewToFront(self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isBeingDragged else {
            isBeingDragged = false
            return
        }
        
        let graph = superview as! GraphView
        
        if graph.mode == .select || graph.mode == .edges {
            graph.select(self)
            
            if graph.mode == .edges && graph.selectedNodes.count == 2 {
                graph.addEdge(from: graph.selectedNodes.first!, to: graph.selectedNodes.last!)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard (superview as! GraphView).mode != .viewOnly else { return }
        
        for touch in touches {
            let location = touch.location(in: self)
            let previousLocation = touch.previousLocation(in: self)
            
            if abs(location.x - previousLocation.x) + abs(location.y - previousLocation.y) < 2 {
                break
            }
            
            isBeingDragged = true
            
            frame = frame.offsetBy(dx: (location.x - previousLocation.x), dy: (location.y - previousLocation.y))
        }
        
        for edge in edges {
            edge.followConnectedNodes()
        }
    }
    
}
