//
//  ActionsController.swift
//  Seven Bridges
//
//  Created by Dillon Fagan on 9/12/17.
//

import UIKit

class ActionsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var viewControllerDelegate: ViewController?
    
    weak var graph: Graph?
    
    @IBOutlet weak var tableView: UITableView!
    
    private let actions = [
        "Toggle Direction",
        "Renumber Nodes",
        "Reset Edge Weights",
        "Remove All Edges",
        "Find Shortest Path",
        "Minimum Spanning Tree (Prim)",
        "Minimum Spanning Tree (Kruskal)",
        "Find Max Flow (Ford-Fulkerson)"
    ]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = actions[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = actions[indexPath.row]
        didSelectAction(action)
    }
    
    private func didSelectAction(_ action: String) {
        dismiss(animated: true, completion: nil)
        
        switch action {
        case "Toggle Direction":
            graph?.isDirected = !(graph?.isDirected)!
        case "Find Max Flow (Ford-Fulkerson)":
            graph?.fordFulkersonMaxFlow()
        case "Minimum Spanning Tree (Kruskal)":
            graph?.kruskalMinimumSpanningTree()
        case "Minimum Spanning Tree (Prim)":
            graph?.primMinimumSpanningTree()
        case "Find Shortest Path":
            graph?.shortestPath()
        case "Renumber Nodes":
            graph?.renumberNodes()
        case "Reset Edge Weights":
            graph?.resetAllEdgeWeights()
        case "Remove All Edges":
            graph?.removeAllEdges()
        default:
            print("An action with that name could not be found.")
        }
    }
    
}
