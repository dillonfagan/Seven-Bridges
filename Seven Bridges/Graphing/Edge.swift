//
//  Edge.swift
//  Seven Bridges
//
//  Created by Dillon Fagan on 6/23/17.
//

import UIKit

@IBDesignable class Edge: UIView {
    
    /// Thickness of the line.
    private let lineWidth: CGFloat = 4
    
    /// Color used for highlighting the edge.
    private var highlightColor: UIColor!
    
    /// Path of the line.
    private var path = UIBezierPath()
    
    /// Start point of the line in the parent view.
    private var startPoint: CGPoint?
    
    /// End point of the line in the parent view.
    private var endPoint: CGPoint?
    
    /// Contains active info for the edge, including weight and flow.
    private var label: UILabel!
    
    /// Node at beginning of edge.
    var startNode: Node!
    
    /// Node at end of edge.
    var endNode: Node!
    
    /// Weight of the edge.
    var weight = 1
    
    /// Flow of the edge being used.
    var flow: Int?
    
    /// Remaining capacity of the edge (weight - flow).
    var residualCapacity: Int? {
        if let f = flow {
            return weight - f
        } else {
            return nil
        }
    }
    
    /// Whether the edge appears highlighted.
    var isHighlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// String representation of the edge.
    override var description: String {
        let start = startNode.label.text!
        let end = endNode.label.text!
        
        return "\(start) → \(end)"
    }
    
    init() {
        super.init(frame: CGRect())
    }
    
    init(from startNode: Node, to endNode: Node) {
        self.startNode = startNode
        self.endNode = endNode
        
        super.init(frame: CGRect())
        
        // register edge with nodes
        startNode.edges.insert(self)
        endNode.edges.insert(self)
        
        updateSize()
        
        updateOrigin()
        
        // allow drawing outside its bounds so that its label is not cut off
        clipsToBounds = false
        
        label = UILabel(frame: CGRect(x: bounds.midX, y: bounds.midY, width: 64, height: 64))
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = NSTextAlignment.left
        addSubview(label)
        
        backgroundColor = UIColor.clear
        
        clearsContextBeforeDrawing = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Highlights the edge with a different color (black is the default).
    ///
    /// - parameter enable: If true, the edge is highlighted. If false, it is unhighlighted.
    /// - parameter color: The color that the edge will be highlighted.
    ///
    func highlighted(_ enable: Bool = true, color: UIColor = UIColor.black) {
        if enable {
            highlightColor = color
            isHighlighted = true
        } else {
            isHighlighted = false
        }
    }
    
    /// Reverses the direction of the edge.
    func reverse() {
        swap(&startNode, &endNode)
    }
    
    /// Updates size, origin, and path of line relative to the start node and end node.
    func followConnectedNodes() {
        updateSize()
        updateOrigin()
        updatePath()
        setNeedsDisplay()
    }
    
    /// Updates the content of the edge's label.
    ///
    /// - parameter transitionDuration: How long (in seconds) the transition to the updated label will last for.
    ///
    func updateLabel(transitionDuration: Double = 0.2) {
        guard label != nil else { return }
        
        if weight < 2 && flow == nil {
            // label should be blank (invisible) if the edge's weight is 1 and flow is not displayed
            label.text = nil
        } else if flow != nil {
            // when flow is being displayed
            label.changeTextWithFade(to: "\(flow!) / \(weight)", duration: transitionDuration)
        } else {
            // when the edge has a weight greater than 1 and flow is not displayed
            label.changeTextWithFade(to: String(weight), duration: transitionDuration)
        }
    }
    
    /// Updates size of the frame based on the distance between the start node and end node.
    func updateSize() {
        // determine size of frame
        let width = abs(startNode!.frame.origin.x - endNode!.frame.origin.x) + Node.diameter
        let height = abs(startNode!.frame.origin.y - endNode!.frame.origin.y) + Node.diameter
        let size = CGSize(width: width, height: height)
        
        // set size of frame
        frame.size = size
    }
    
    /// Updates origin of the frame based on the leftmost node.
    func updateOrigin() {
        // set location of frame around nodes
        frame.origin = CGPoint(x: min(startNode!.frame.origin.x, endNode!.frame.origin.x), y: min(startNode!.frame.origin.y, endNode!.frame.origin.y))
    }
    
    /// Determines the corner points of the start node and end node.
    private func locatePointsInFrame() {
        // predefined coordinates of nodes relative to frame
        let upperLeft = CGPoint(x: Node.radius, y: Node.radius)
        let lowerLeft = CGPoint(x: Node.radius, y: frame.size.height - Node.radius)
        let upperRight = CGPoint(x: frame.size.width - Node.radius, y: Node.radius)
        let lowerRight = CGPoint(x: frame.size.width - Node.radius, y: frame.size.height - Node.radius)
        
        // locate nodes within frame and set start and end points of line
        if startNode!.frame.origin.y > frame.origin.y {
            if startNode!.frame.origin.x <= frame.origin.x {
                startPoint = lowerLeft
                endPoint = upperRight
            } else {
                startPoint = lowerRight
                endPoint = upperLeft
            }
        } else if startNode!.frame.origin.y <= frame.origin.y {
            if startNode!.frame.origin.x <= frame.origin.x {
                startPoint = upperLeft
                endPoint = lowerRight
            } else {
                startPoint = upperRight
                endPoint = lowerLeft
            }
        }
    }
    
    /// Updates the line based on the positions of the start node and end node.
    private func updatePath() {
        path = UIBezierPath()
        
        locatePointsInFrame()
        
        let headWidth = Node.radius / 2.2
        let headLength = headWidth
        
        let length = hypot(endPoint!.x - startPoint!.x, endPoint!.y - startPoint!.y)
        let tailLength = length - Node.radius - headLength
        
        let points: [CGPoint] = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: length, y: 0),
        ]
        
        let cosine = (endPoint!.x - startPoint!.x) / length
        let sine = (endPoint!.y - startPoint!.y) / length
        
        // reorient the line to match slope between nodes
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: startPoint!.x, ty: startPoint!.y)
        
        let linePath = CGMutablePath()
        linePath.addLines(between: points, transform: transform)
        
        // add arrow for directed graph
        if (superview as! GraphView).isDirected {
            let tipPoint = CGPoint(x: length - Node.radius, y: 0)
            
            linePath.move(to: tipPoint, transform: transform)
            linePath.addLine(to: CGPoint(x: tailLength, y: headWidth / 1.2), transform: transform)
            
            linePath.move(to: tipPoint, transform: transform)
            linePath.addLine(to: CGPoint(x: tailLength, y: -headWidth / 1.2), transform: transform)
        }
        
        linePath.closeSubpath()
        path.append(UIBezierPath(cgPath: linePath))
        
        // update location of label
        label.frame.origin = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    /// Draws a line from the start node to the end node.
    override func draw(_ rect: CGRect) {
        updatePath()
        
        // if the edge is highlighted, stroke using highlightColor
        if isHighlighted {
            highlightColor.setStroke()
        } else {
            // set color of line to stroke color of start node if graph is directed
            // otherwise, stroke color is gray
            if (superview as! GraphView).isDirected {
                startNode.color.setStroke()
            } else {
                UIColor.lightGray.setStroke()
            }
        }
        
        // set thickness of the line
        path.lineWidth = lineWidth
        
        // stroke the line
        path.stroke()
    }
    
}
