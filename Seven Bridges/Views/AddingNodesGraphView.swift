import UIKit

public class AddingNodesGraphView: GraphView {
    
    let colorGenerator = ColorGenerator()
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        addNode(with: touches)
    }
    
    private func addNode(with touches: Set<UITouch>) {
        for touch in touches {
            let location = touch.location(in: self)
            
            let node = Node(color: colorGenerator.nextColor(), at: location)
            node.label.text = String(graph.nodes.count + 1)
            
            graph.nodes.append(node)
            graph.nodeMatrix[node] = Set<Node>()
            
            addSubview(node)
        }
    }
}
