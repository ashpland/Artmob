//
//  ASHColourHelper
//  Whiteboard
//
//  Created by Andrew Shopland on 2017-11-22.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import Foundation
import UIKit


public class Colour {
    
    private static let global = Colour()
    
    private var colorScheme: ColorSchemeProtocol = DefaultColorSchemes.marker.get()
    
    class func setDefault(_ newColorScheme: DefaultColorSchemes){
        self.global.colorScheme = newColorScheme.get()
    }
    
    class func setCustom(_ newColorScheme: ColorSchemeProtocol){
        self.global.colorScheme = newColorScheme
    }
    
    class var currentScheme: String { return self.global.colorScheme.title}
    
    class var black:UIColor  { return self.global.colorScheme.black }
    class var white:UIColor  { return self.global.colorScheme.white }
    class var red:UIColor    { return self.global.colorScheme.red }
    class var orange:UIColor { return self.global.colorScheme.orange }
    class var yellow:UIColor { return self.global.colorScheme.yellow }
    class var green:UIColor  { return self.global.colorScheme.green }
    class var blue:UIColor   { return self.global.colorScheme.blue }
    class var purple:UIColor { return self.global.colorScheme.purple }
}


public protocol ColorSchemeProtocol {
    var title: String   { get }
    var black: UIColor  { get }
    var white: UIColor  { get }
    var red:    UIColor { get }
    var orange: UIColor { get }
    var yellow: UIColor { get }
    var green: UIColor  { get }
    var blue: UIColor   { get }
    var purple: UIColor { get }
}


public enum DefaultColorSchemes {
    case marker
    case pastel
    case nature
    
    func get() -> ColorSchemeProtocol {
        switch self {
        case .marker:
            return ColorSchemeMarker()
        case .pastel:
            return ColorSchemePastel()
        case .nature:
            return ColorSchemeNature()
        }
        
    }
}


fileprivate struct ColorSchemeMarker: ColorSchemeProtocol {
    let title = "Marker"
    let black: UIColor  = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    let white: UIColor  = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let red: UIColor    = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
    let orange: UIColor = #colorLiteral(red: 1, green: 0.6157572507, blue: 0.008369489453, alpha: 1)
    let yellow: UIColor = #colorLiteral(red: 0.9864611132, green: 1, blue: 0.1596844197, alpha: 1)
    let green: UIColor  = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    let blue: UIColor   = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
    let purple: UIColor = #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1)
}

fileprivate struct ColorSchemePastel: ColorSchemeProtocol {
    let title = "Pastel"
    let black: UIColor  = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    let white: UIColor  = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let red: UIColor    = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
    let orange: UIColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
    let yellow: UIColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
    let green: UIColor  = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
    let blue: UIColor   = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    let purple: UIColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
}

fileprivate struct ColorSchemeNature: ColorSchemeProtocol {
    let title = "Nature"
    let black: UIColor  = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
    let white: UIColor  = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
    let red: UIColor    = #colorLiteral(red: 0.6170684816, green: 0.1250929994, blue: 0.07557409804, alpha: 1)
    let orange: UIColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
    let yellow: UIColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
    let green: UIColor  = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
    let blue: UIColor   = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
    let purple: UIColor = #colorLiteral(red: 0.3236978054, green: 0.1063579395, blue: 0.574860394, alpha: 1)
}
