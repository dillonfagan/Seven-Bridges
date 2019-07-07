//
//  ActionsController.swift
//  Seven Bridges
//
//  Created by Dillon Fagan on 9/12/17.
//

import UIKit

class ActionsController: UITableViewController {
    
    /// The parent view controller that contains the graph.
    weak var viewControllerDelegate: ViewController!
    
    /// The graph that the actions will be applied to.
    weak var graphView: GraphView!
    
    /// Dismisses the view when the close button is tapped.
    ///
    /// - parameter sender: The close button.
    ///
    @IBAction func close(_ sender: UIBarButtonItem) {
        dismissView()
    }
    
    /// Toggles directed edges in the graph.
    ///
    /// - parameter sender: The toggle switch.
    ///
    @IBAction func toggleDirectedEdges(_ sender: UISwitch) {
        graphView.isDirected = sender.isOn
    }
    
    /// Called when a cell in the table is selected.
    /// Matches the cell to an action and executes the appropriate method.
    ///
    /// - parameter tableView: The table view that contains the cells.
    /// - parameter didSelectRowAt: The section and row of the cell.
    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // skip section 0, since this only contains the directed edges toggle
        guard indexPath.section != 0 else {
            return
        }
        
        dismissView()
        
        switch indexPath.section {
        case 1:
            self.quickAction(at: indexPath.row)
        case 2:
            self.algorithm(at: indexPath.row)
        case 3:
            self.template(at: indexPath.row)
        default:
            print("A cell was selected in section: \(indexPath.section)")
        }
        
        // deselect the cell so that the highlight disappears
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    /// Executes a quick action method given a table row.
    ///
    /// - parameter at: The row of the cell.
    ///
    private func quickAction(at row: Int) {
        switch row {
        case 0:
            graphView.renumberNodes()
        case 1:
            graphView.resetAllEdgeWeights()
        case 2:
            graphView.removeAllEdges()
        default:
            print("A cell was selected in row: \(row)")
        }
    }
    
    /// Executives an algorithm method given a table row.
    ///
    /// - parameter at: The row of the cell.
    ///
    private func algorithm(at row: Int) {
        let algorithmController = AlgorithmController()
        
        switch row {
        case 0:
            algorithmController.dijkstraShortestPath(graphView)
        case 1:
            algorithmController.primMinimumSpanningTree(graphView)
        case 2:
            algorithmController.kruskalMinimumSpanningTree(graphView)
        case 3:
            algorithmController.fordFulkersonMaxFlow(graphView)
        case 4:
            algorithmController.bronKerboschMaxClique(graphView)
        default:
            print("A cell was selected in row: \(row)")
        }
    }
    
    /// Executes a template method given a table row.
    ///
    /// - parameter at: The row of the cell.
    ///
    private func template(at row: Int) {
        switch row {
        case 0:
            graphView.prepareFlowNetworkExample()
        default:
            print("A cell was selected in row: \(row)")
        }
    }
    
    /// Dismisses the view with a fade animation.
    private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
