import XCTest
@testable import Seven_Bridges

class GraphTests: XCTestCase {
    
    private var graph: Graph!

    override func setUp() {
        graph = Graph()
    }

    func test_addNodeToGraph() {
        let node = Node(at: CGPoint(x: 0, y: 0))
        graph.add(node)
        
        XCTAssertEqual(graph.nodes.count, 1)
    }
    
    func test_addEdgeBetweenNodes_graphHasOneEdge() {
        let _ = addEdgeBetweenNodes()
        XCTAssert(graph.edges.count == 1)
    }

    private func addEdgeBetweenNodes() -> (Node, Node) {
        let nodeA = Node(at: CGPoint(x: 0, y: 0))
        let nodeB = Node(at: CGPoint(x: 10, y: 10))
        let edge = Edge(from: nodeA, to: nodeB)

        graph.add(nodeA)
        graph.add(nodeB)
        graph.add(edge)

        return (nodeA, nodeB)
    }

    func test_addEdgeBetweenNodes_correctStartNode() {
        let (nodeA, _) = addEdgeBetweenNodes()
        XCTAssert(graph.edges.first!.startNode == nodeA)
    }

    func test_addEdgeBetweenNodes_correctEndNode() {
        let (_, nodeB) = addEdgeBetweenNodes()
        XCTAssert(graph.edges.first!.endNode == nodeB)
    }
    
//    func test_dank() {
//        let nodeA = Node(at: CGPoint(x: 0, y: 0))
//        let nodeB = Node(at: CGPoint(x: 10, y: 10))
//        let nodeC = Node(at: CGPoint(x: 10, y: 20))
//
//        let edgeAB = Edge(from: nodeA, to: nodeB)
//        let edgeBC = Edge(from: nodeA, to: nodeC)
//
//        graph.add(nodeA)
//        graph.add(nodeB)
//        graph.add(nodeC)
//        graph.add(edgeAB)
//        graph.add(edgeBC)
//    }

}
