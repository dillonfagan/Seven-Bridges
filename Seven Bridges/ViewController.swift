//
//  ViewController.swift
//  Seven Bridges
//
//  Created by Dillon Fagan on 6/23/17.
//

import UIKit

class ViewController: UIViewController, UIBarPositioningDelegate, UIToolbarDelegate {
    
    /// If the device is an iPhone, portrait is the only supported orientation.
    /// Otherwise, all but upside down is supported.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.portrait
        }
        
        return UIInterfaceOrientationMask.allButUpsideDown
    }
    
    /// Perform additional setup when the view is ready to be shown.
    override func viewDidLoad() {
        graphView.parentVC = self
        
        // set positioning delegate for the main toolbar
        mainToolbar.delegate = self
        
        // prepare the actions menu
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        actionsNVC = storyboard.instantiateViewController(withIdentifier: "actionsNavController") as? UINavigationController
        actionsNVC.modalPresentationStyle = .popover
        
        actionsVC = actionsNVC.topViewController as? ActionsController
        actionsVC.graphView = graphView
        actionsVC.viewControllerDelegate = self
    }
    
    /// Sets the position of the main toolbar to top so that its shadow is cast down instead of up.
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.top
    }
    
    /// The actions menu table view.
    private var actionsVC: ActionsController!
    
    /// The actions menu navigation controller.
    private var actionsNVC: UINavigationController!
    
    @IBOutlet weak var selectModeButton: UIBarButtonItem!
    
    @IBOutlet weak var nodesModeButton: UIBarButtonItem!
    
    @IBOutlet weak var edgesModeButton: UIBarButtonItem!
    
    @IBOutlet weak var actionsMenuButton: UIBarButtonItem!
    
    @IBOutlet weak var mainToolbar: UIToolbar!
    
    @IBOutlet weak var propertiesToolbar: UIToolbar!
    
    @IBOutlet weak var edgeWeightPlusButton: UIBarButtonItem!
    
    @IBOutlet weak var edgeWeightMinusButton: UIBarButtonItem!
    
    @IBOutlet weak var edgeWeightIndicator: UIBarButtonItem!
    
    @IBOutlet weak var removeEdgeButton: UIBarButtonItem!
    
    @IBOutlet weak var trashButton: UIBarButtonItem!
    
    @IBOutlet var graphView: GraphView!
    
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
    
    /// Called when the selectModeButton is tapped.
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
        present(actionsNVC, animated: true)
    }
    
    @IBAction func clearGraph(sender: UIBarButtonItem) {
        // prompt user before clearing graph
        Announcement.new(title: "Clear Graph", message: "Are you sure you want to clear the graph?", action: { (action: UIAlertAction!) -> Void in
            self.graphView.clear()
            self.exitSelectMode(self.selectModeButton, graphWasJustCleared: true)
        }, cancelable: true)
    }
    
    // TODO: create states for the properties toolbar
    func updatePropertiesToolbar() {
        // hide the toolbar if no nodes are selected
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

