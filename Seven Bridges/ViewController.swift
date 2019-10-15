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
        
        mainToolbar.delegate = self
        mainToolbar.parentVC = self
        mainToolbar.graphView = graphView
        mainToolbar.buildActionsController()
        propertiesToolbar.graphView = graphView
    }
    
    /// Sets the position of the main toolbar to top so that its shadow is cast down instead of up.
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.top
    }
    
    @IBOutlet weak var mainToolbar: MainToolbar!
    @IBOutlet weak var propertiesToolbar: PropertiesToolbar!
    
    @IBOutlet var graphView: GraphView!
    
    var previousGraphMode: GraphMode?
    
    /// Puts the graph in select mode and updates the selectModeButton.
    func enterSelectMode(_ sender: UIBarButtonItem) {
        mainToolbar.enterSelectMode(sender)
        previousGraphMode = graphView.mode
    }
    
    /// Puts the graph into nodes mode and updates the selectModeButton.
    func exitSelectMode(_ sender: UIBarButtonItem, graphWasJustCleared: Bool = false) {
        if !graphWasJustCleared {
            graphView.deselectNodes(unhighlight: true, resetEdgeProperties: true)
        }
        
        graphView.mode = previousGraphMode ?? .nodes
        
        sender.title = "Select"
        sender.style = .plain
    }
    
    // TODO: create states for the properties toolbar
    func updatePropertiesToolbar() {
        propertiesToolbar.update()
    }
}

