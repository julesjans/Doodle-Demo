//
//  UIColor.swift
//  Drawing
//
//  Created by Julian Jans on 27/06/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import UIKit

extension UIColor {

   static func randomColor(_ alpha: CGFloat) -> UIColor {
    
        let time = UInt32(NSDate().timeIntervalSinceReferenceDate)
        srand48(Int(time))
    
        let randomR:CGFloat = CGFloat(drand48())
        let randomG:CGFloat = CGFloat(drand48())
        let randomB:CGFloat = CGFloat(drand48())
        return UIColor(red: randomR, green: randomG, blue: randomB, alpha: alpha)
    }
    
    func adjust(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha:CGFloat) -> UIColor{
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r+red, green: g+green, blue: b+blue, alpha: a+alpha)
    }
}
