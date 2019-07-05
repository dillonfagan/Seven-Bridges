import UIKit

public class AddingEdgesGraphView: GraphView {
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if graph.selectedNodes.count == 2 {
            addEdge(from: graph.selectedNodes.first!, to: graph.selectedNodes.last!)
        }
    }
    
    private func addEdge(from a: Node, to b: Node) {
        if a != b && !b.isAdjacent(to: a) {
            let edge = Edge(from: a, to: b)
            
            addSubview(edge)
            sendSubviewToBack(edge)
            
            graph.edges.insert(edge)
            graph.nodeMatrix[a]?.insert(b)
        }
        
        a.isSelected = false
        b.isSelected = false
        
        graph.selectedNodes.removeAll()
    }
}
