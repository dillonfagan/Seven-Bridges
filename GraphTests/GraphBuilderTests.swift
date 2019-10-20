import XCTest
@testable import Seven_Bridges

class GraphBuilderTests: XCTestCase {

    func test_emptyGraph() {
        let graph = GraphBuilder().build()
        XCTAssertNotNil(graph)
    }
    
    func test_graphWithOneNode() {
        let graph = GraphBuilder().withNode().build()
        XCTAssert(graph.nodes.count == 1)
    }
    
    func test_graphWithThreeNodes() {
        let graph = GraphBuilder().withNodes(3).build()
        XCTAssert(graph.nodes.count == 3)
    }
    
    func test_graphWithThreeAdjacentEdge() {
        let graph = GraphBuilder()
            .withNodes(3)
            .withEdge(from: 1, to: 2)
            .withEdge(from: 2, to: 3)
            .withEdge(from: 3, to: 1)
            .build()
        
        XCTAssert(graph.nodes[0].isAdjacent(to: graph.nodes[1]))
        XCTAssert(graph.nodes[1].isAdjacent(to: graph.nodes[2]))
        XCTAssert(graph.nodes[2].isAdjacent(to: graph.nodes[0]))
    }
    
    func test_graphWithOneEdge() {
        let graph = GraphBuilder()
            .withNode()
            .withNode()
            .withEdge(from: 1, to: 2, weight: 3)
            .build()
        
        XCTAssert(graph.edges.count == 1)
        XCTAssert(graph.edges.first!.weight == 3)
    }

}

class GraphBuilder {
    
    private var graph: Graph
    
    init() {
        graph = Graph()
    }
    
    func withNodes(_ nodes: Int) -> GraphBuilder {
        for _ in 1...nodes {
            let _ = withNode()
        }
        
        return self
    }
    
    func withNode() -> GraphBuilder {
        graph.add(Node(at: CGPoint(x: 0, y: 0)))
        return self
    }
    
    func withEdge(from a: Int, to b: Int, weight: Int = 1) -> GraphBuilder {
        let nodeA = graph.nodes[a - 1]
        let nodeB = graph.nodes[b - 1]
        
        let edge = Edge(from: nodeA, to: nodeB)
        edge.weight = weight
        graph.add(edge)
        
        return self
    }
    
    func build() -> Graph {
        return graph
    }
    
}
