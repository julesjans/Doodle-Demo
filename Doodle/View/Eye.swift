//
//  Eye.swift
//  Eye
//
//  Created by Julian Jans on 02/07/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import UIKit

class CircleView: UIView {
    
    @IBInspectable var colour: UIColor = UIColor.white
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    func configure() {
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func draw(_ rect: CGRect) {
        let circle:UIBezierPath = UIBezierPath(ovalIn: bounds)
        colour.setFill()
        circle.fill()
    }
    
}

@IBDesignable
class Eye: CircleView, PaletteOption {
    
    @IBInspectable var selected: Bool = false
    
    var iris: CircleView!
    
    override func configure() {
        super.configure()
        iris = CircleView()
        iris.colour = UIColor.black
        configureIris()
        addSubview(iris)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configureIris()
    }
    
    private func configureIris() {
        iris.frame = self.bounds.insetBy(dx: min(self.bounds.width, self.bounds.height) * 0.26, dy: min(self.bounds.width, self.bounds.height) * 0.26)
    }
    
}
