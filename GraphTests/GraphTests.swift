import XCTest
@testable import Seven_Bridges

class GraphTests: XCTestCase {
    
    private var graph: Graph!

    override func setUp() {
        graph = buildGraph()
    }
    
    private func buildGraph() -> Graph {
        let graph = Graph()
        
        let nodeA = Node(at: CGPoint(x: 0, y: 0))
        let nodeB = Node(at: CGPoint(x: 10, y: 10))
        let edge = Edge(from: nodeA, to: nodeB)
        
        graph.add(nodeA)
        graph.add(nodeB)
        graph.add(edge)
        
        return graph
    }

    func test_addTwoNodesToGraph() {
        XCTAssertEqual(graph.nodes.count, 2)
    }
    
    func test_addEdgeBetweenNodes_graphHasOneEdge() {
        XCTAssert(graph.edges.count == 1)
    }

    func test_addEdgeBetweenNodes_correctStartNode() {
        XCTAssert(graph.edges.first!.startNode == graph.nodes.first!)
    }

    func test_addEdgeBetweenNodes_correctEndNode() {
        XCTAssert(graph.edges.first!.endNode == graph.nodes.last!)
    }
    
    func test_swapToUndirectedGraph() {
        graph = buildGraph()
        graph = UndirectedGraph(graph)
        
        XCTAssert(graph.nodes.count == 2)
    }

}
