import UIKit

@IBDesignable
class MainToolbar: UIToolbar {
    
    @IBOutlet weak var selectModeButton: UIBarButtonItem!
    @IBOutlet weak var nodesModeButton: UIBarButtonItem!
    @IBOutlet weak var edgesModeButton: UIBarButtonItem!
    @IBOutlet weak var actionsMenuButton: UIBarButtonItem!
    
    private var actionsVC: ActionsController!
    private var actionsNVC: UINavigationController!
    
    var parentVC: ViewController!
    var graphView: GraphView!
    
    func buildActionsController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        actionsNVC = storyboard.instantiateViewController(withIdentifier: "actionsNavController") as? UINavigationController
        actionsNVC.modalPresentationStyle = .popover
        
        actionsVC = actionsNVC.topViewController as? ActionsController
        actionsVC.graphView = graphView
        actionsVC.viewControllerDelegate = parentVC
    }
    
    @IBAction func selectButtonTapped(_ sender: UIBarButtonItem) {
        if graphView.mode != .select && graphView.mode != .viewOnly {
            enterSelectMode(sender)
        } else {
            exitSelectMode(sender)
        }
    }
    
    /// Puts the graph in select mode and updates the selectModeButton.
    func enterSelectMode(_ sender: UIBarButtonItem) {
        graphView.mode = .select
        
        sender.title = "Done"
        sender.style = .done
        
        nodesModeButton.isEnabled = false
        edgesModeButton.isEnabled = false
    }
    
    /// Puts the graph into nodes mode and updates the selectModeButton.
    func exitSelectMode(_ sender: UIBarButtonItem, graphWasJustCleared: Bool = false) {
        if !graphWasJustCleared {
            graphView.deselectNodes(unhighlight: true, resetEdgeProperties: true)
        }
        
        graphView.mode = .nodes
        
        sender.title = "Select"
        sender.style = .plain
        
        // re-enable toolbar buttons
        nodesModeButton.isEnabled = true
        edgesModeButton.isEnabled = true
    }
    
    @IBAction func enterNodesMode(_ sender: UIBarButtonItem) {
        graphView.mode = .nodes
    }
    
    @IBAction func enterEdgesMode(_ sender: UIBarButtonItem) {
        graphView.mode = .edges
    }
    
    @IBAction func openActionsPopover(_ sender: UIBarButtonItem) {
        actionsNVC.popoverPresentationController?.barButtonItem = sender
        parentVC.present(actionsNVC, animated: true)
    }
    
    @IBAction func clearGraph(sender: UIBarButtonItem) {
        // prompt user before clearing graph
        Announcement.new(title: "Clear Graph", message: "Are you sure you want to clear the graph?", action: { (action: UIAlertAction!) -> Void in
            self.graphView.clear()
            self.exitSelectMode(self.selectModeButton, graphWasJustCleared: true)
        }, cancelable: true)
    }
}
