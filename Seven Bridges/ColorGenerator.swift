import UIKit

public class ColorGenerator {
    
    /// Current index in the colors array for cycling through.
    private var colorIndex = 0
    
    /// Colors to cycle through when adding a new node to the graph.
    private let colors = [
        // green
        UIColor(red: 100/255, green: 210/255, blue: 185/255, alpha: 1.0),
        
        // pink
        UIColor(red: 235/255, green: 120/255, blue: 180/255, alpha: 1.0),
        
        // blue
        UIColor(red: 90/255, green: 160/255, blue: 235/255, alpha: 1.0),
        
        // yellow
        UIColor(red: 245/255, green: 200/255, blue: 90/255, alpha: 1.0),
        
        // purple
        UIColor(red: 195/255, green: 155/255, blue: 245/255, alpha: 1.0)
    ]
    
    public func nextColor() -> UIColor {
        let color = colors[colorIndex]
        
        if colorIndex < colors.count - 1 {
            colorIndex += 1
        } else {
            colorIndex = 0
        }
        
        return color
    }
    
    public func reset() {
        colorIndex = 0
    }
}
