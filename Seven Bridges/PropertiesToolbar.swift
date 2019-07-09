import UIKit

@IBDesignable
class PropertiesToolbar: UIToolbar {
    
    @IBOutlet weak var edgeWeightPlusButton: UIBarButtonItem!
    @IBOutlet weak var edgeWeightMinusButton: UIBarButtonItem!
    @IBOutlet weak var edgeWeightIndicator: UIBarButtonItem!
    @IBOutlet weak var removeEdgeButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    
    var graphView: GraphView!
    
    @IBAction func increaseSelectedEdgeWeight(_ sender: UIBarButtonItem) {
        graphView.shiftSelectedEdgeWeight(by: 1)
    }
    
    @IBAction func decreaseSelectedEdgeWeight(_ sender: UIBarButtonItem) {
        graphView.shiftSelectedEdgeWeight(by: -1)
    }
    
    @IBAction func removeSelectedEdge(_ sender: UIBarButtonItem) {
        graphView.removeSelectedEdge()
    }
    
    @IBAction func deleteSelectedNodes(_ sender: UIBarButtonItem) {
        graphView.deleteSelectedNodes()
    }
    
    func update() {
        trashButton.isEnabled = !graphView.selectedNodes.isEmpty
        
        // detect a selected edge between two nodes
        // if nil, disable UI elements related to a selected edge
        if let edge = graphView.selectedEdge {
            edgeWeightIndicator.title = String(edge.weight)
            
            edgeWeightMinusButton.title = "-"
            edgeWeightMinusButton.isEnabled = true
            
            edgeWeightPlusButton.title = "+"
            edgeWeightPlusButton.isEnabled = true
            
            removeEdgeButton.title = "Remove \(edge)"
            removeEdgeButton.isEnabled = true
        } else {
            edgeWeightIndicator.title = ""
            edgeWeightIndicator.isEnabled = false
            
            edgeWeightMinusButton.title = ""
            edgeWeightMinusButton.isEnabled = false
            
            edgeWeightPlusButton.title = ""
            edgeWeightPlusButton.isEnabled = false
            
            removeEdgeButton.title = ""
            removeEdgeButton.isEnabled = false
        }
    }
}
