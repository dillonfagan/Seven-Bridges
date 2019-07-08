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
        addEdge(first, toGraph: flowNetwork, toView: graphView)
        
        // edge from 1 to 3
        let second = Edge(from: flowNetwork.nodes[0], to: flowNetwork.nodes[2])
        second.weight = 5
        addEdge(second, toGraph: flowNetwork, toView: graphView)
        
        // edge from 2 to 3
        let third = Edge(from: flowNetwork.nodes[1], to: flowNetwork.nodes[2])
        third.weight = 3
        addEdge(third, toGraph: flowNetwork, toView: graphView)
        
        // edge from 2 to 4
        let fourth = Edge(from: flowNetwork.nodes[1], to: flowNetwork.nodes[3])
        fourth.weight = 3
        addEdge(fourth, toGraph: flowNetwork, toView: graphView)
        
        // edge from 3 to 4
        let fifth = Edge(from: flowNetwork.nodes[2], to: flowNetwork.nodes[3])
        fifth.weight = 7
        addEdge(fifth, toGraph: flowNetwork, toView: graphView)
        
        return flowNetwork
    }
    
    private static func addEdge(_ edge: Edge, toGraph graph: Graph, toView view: GraphView) {
        edge.updateLabel()
        graph.add(edge)
        view.addSubview(edge)
        view.sendSubviewToBack(edge)
    }
}
