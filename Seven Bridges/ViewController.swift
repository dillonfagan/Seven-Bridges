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
        graph.parentVC = self
        
        // set positioning delegate for the main toolbar
        mainToolbar.delegate = self
        
        // prepare the actions menu
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        actionsNVC = storyboard.instantiateViewController(withIdentifier: "actionsNavController") as? UINavigationController
        actionsNVC.modalPresentationStyle = .popover
        
        actionsVC = actionsNVC.topViewController as? ActionsController
        actionsVC.graph = graph
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
    
    @IBOutlet var graph: Graph!
    
    @IBOutlet var graphView: GraphView!
    
    @IBAction func increaseSelectedEdgeWeight(_ sender: UIBarButtonItem) {
        graph.shiftSelectedEdgeWeight(by: 1)
    }
    
    @IBAction func decreaseSelectedEdgeWeight(_ sender: UIBarButtonItem) {
        graph.shiftSelectedEdgeWeight(by: -1)
    }
    
    @IBAction func removeSelectedEdge(_ sender: UIBarButtonItem) {
        graph.removeSelectedEdge()
    }
    
    @IBAction func deleteSelectedNodes(_ sender: UIBarButtonItem) {
        graph.deleteSelectedNodes()
    }
    
    /// Called when the selectModeButton is tapped.
    @IBAction func selectButtonTapped(_ sender: UIBarButtonItem) {
        if graph.mode != .select && graph.mode != .viewOnly {
            enterSelectMode(sender)
        } else {
            exitSelectMode(sender)
        }
    }
    
    /// Puts the graph in select mode and updates the selectModeButton.
    func enterSelectMode(_ sender: UIBarButtonItem) {
        graph.mode = .select
        
        sender.title = "Done"
        sender.style = .done
        
        nodesModeButton.isEnabled = false
        edgesModeButton.isEnabled = false
    }
    
    /// Puts the graph into nodes mode and updates the selectModeButton.
    func exitSelectMode(_ sender: UIBarButtonItem, graphWasJustCleared: Bool = false) {
        if !graphWasJustCleared {
            graph.deselectNodes(unhighlight: true, resetEdgeProperties: true)
        }
        
        graph.mode = .nodes
        
        sender.title = "Select"
        sender.style = .plain
        
        // re-enable toolbar buttons
        nodesModeButton.isEnabled = true
        edgesModeButton.isEnabled = true
    }
    
    @IBAction func enterNodesMode(_ sender: UIBarButtonItem) {
        graph.mode = .nodes
    }
    
    @IBAction func enterEdgesMode(_ sender: UIBarButtonItem) {
        graph.mode = .edges
    }
    
    @IBAction func openActionsPopover(_ sender: UIBarButtonItem) {
        actionsNVC.popoverPresentationController?.barButtonItem = sender
        present(actionsNVC, animated: true)
    }
    
    @IBAction func clearGraph(sender: UIBarButtonItem) {
        // prompt user before clearing graph
        Announcement.new(title: "Clear Graph", message: "Are you sure you want to clear the graph?", action: { (action: UIAlertAction!) -> Void in
            self.graph.clear()
            self.exitSelectMode(self.selectModeButton, graphWasJustCleared: true)
        }, cancelable: true)
    }
}

