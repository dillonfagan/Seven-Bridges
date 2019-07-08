//
//  Announcement.swift
//  Seven Bridges
//
//  Created by Dillon Fagan on 1/14/18.
//

import UIKit

class Announcement {
    
    static func new(title: String, message: String, action: ((UIAlertAction) -> Void)? = nil, cancelable: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // add the "Cancel" button if the announcement is cancelable
        if cancelable {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        
        // add the "OK" button
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: action))
        
        // present the announcement
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
