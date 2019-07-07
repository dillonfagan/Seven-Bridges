import UIKit

extension Graph {
    static func flowNetworkTemplate(graphView: GraphView) -> Graph {
        let flowNetwork = Graph()
        
        // the amount by which the x and y coordinates of each node should be adjusted
        // relative to the bounds of the Graph
        let dx = floor(graphView.bounds.width / 3.5)
        let dy = min(floor(graphView.bounds.height / 3), 250)
        
        for i in 1...4 {
            var x = graphView.bounds.midX
            var y = graphView.bounds.midY
            
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
            let node = Node(color: graphView.colorGenerator.nextColor(), at: point)
            node.label.text = String(i)
            
            flowNetwork.add(node)
            graphView.addSubview(node)
        }
        
        // create edge from 1 to 2
        let first = Edge(from: flowNetwork.nodes[0], to: flowNetwork.nodes[1])
        first.weight = 5
        first.updateLabel()
        flowNetwork.add(first)
        graphView.addSubview(first)
        graphView.sendSubviewToBack(first)
        
        // edge from 1 to 3
        let second = Edge(from: flowNetwork.nodes[0], to: flowNetwork.nodes[2])
        second.weight = 5
        second.updateLabel()
        flowNetwork.add(second)
        graphView.addSubview(second)
        graphView.sendSubviewToBack(second)
        
        // edge from 2 to 3
        let third = Edge(from: flowNetwork.nodes[1], to: flowNetwork.nodes[2])
        third.weight = 3
        third.updateLabel()
        flowNetwork.add(third)
        graphView.addSubview(third)
        graphView.sendSubviewToBack(third)
        
        // edge from 2 to 4
        let fourth = Edge(from: flowNetwork.nodes[1], to: flowNetwork.nodes[3])
        fourth.weight = 3
        fourth.updateLabel()
        flowNetwork.add(fourth)
        graphView.addSubview(fourth)
        graphView.sendSubviewToBack(fourth)
        
        // edge from 3 to 4
        let fifth = Edge(from: flowNetwork.nodes[2], to: flowNetwork.nodes[3])
        fifth.weight = 7
        fifth.updateLabel()
        flowNetwork.add(fifth)
        graphView.addSubview(fifth)
        graphView.sendSubviewToBack(fifth)
        
        return flowNetwork
    }
}
