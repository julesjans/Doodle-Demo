//
//  Palette.swift
//  Doodle
//
//  Created by Julian Jans on 27/06/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import UIKit

@objc protocol PaletteOption {
    var selected: Bool { get set }
    var colour: UIColor { get set }
}

typealias PaletteOptionView = PaletteOption & UIView


@IBDesignable
class Palette: UIView, PaletteOption {
    
    @IBInspectable var selected: Bool = false
    
    @IBInspectable dynamic var colour: UIColor = UIColor.white {
        didSet {
            setNeedsLayout()
        }
    }
   
    private var circleLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    private func configure() {
        backgroundColor = UIColor.clear
        layer.addSublayer(circleLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = self.createPath(rect: self.bounds)
        circleLayer.path = path.cgPath
        circleLayer.lineWidth = path.lineWidth
        circleLayer.opacity = 1.0
        setColor()
    }
    
    func reset() {
        selected = false
        isUserInteractionEnabled = true
        alpha = 1.0
        colour = UIColor.white
    }
    
    func createPath(rect: CGRect) -> UIBezierPath {
        let thickness: CGFloat = 4.0
        let path = UIBezierPath(ovalIn: rect.insetBy(dx: thickness/2.0, dy: thickness/2.0))
        path.lineWidth = thickness
        return path
    }
    
    func setColor() {
        circleLayer.fillColor = self.colour.cgColor
        circleLayer.strokeColor = self.colour.adjust(-0.1, green: -0.1, blue: -0.1, alpha: 1.0).cgColor
    }
    
}
