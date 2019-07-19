//
//  ViewController.swift
//  Doodle
//
//  Created by Julian Jans on 27/06/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    @IBOutlet var drawingView: UIView!
    @IBOutlet var tempImageView: UIImageView!
    @IBOutlet var mainImageView: UIImageView!
    
    @IBOutlet var palettes: [PaletteOptionView]!
    @IBOutlet var palette: UIStackView!
    
    var colour: UIColor? {
        return self.palettes.filter({$0.selected}).first!.colour
    }
    
    var brushWidth: CGFloat = 5.0
    var opacity: CGFloat = 1.0
    
    var counter = 0
    var points = [CGPoint]()
    
    var swipe = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let eye = self.palettes.filter({$0 is Eye}).first as? Eye {
            EyeAnimator.shared.animate(eye: eye)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configurePalettes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      
        if let touch = touches.first {
            
            // guard !palette.frame.contains(touch.location(in: drawingView)) else { return }
            
            if (palettes.filter({$0.selected}).first is Eye)  {
                
                if touch.majorRadius > 0 {
                    let eye = Eye(frame: CGRect(x: 0, y: 0, width: touch.majorRadius * 1.5, height: touch.majorRadius * 1.5))
                    eye.center = touch.location(in: drawingView)
                    self.drawingView.addSubview(eye)
                   
                    EyeAnimator.shared.animate(eye: eye)
                    
                }
                return
            }
            

            counter = 0
            points.insert(touch.location(in: drawingView), at: 0)
            
            UIGraphicsBeginImageContextWithOptions(drawingView.frame.size, false, 2.0)
            // Is this necessary?
            // tempImageView.image?.draw(in: drawingView.bounds)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard !(palettes.filter({$0.selected}).first is Eye) else { return }
        
        if let touch = touches.first {
            
            guard !palette.frame.contains(touch.location(in: drawingView)) else { return }
            
            swipe = true
            
            brushWidth = 2 * (touch.majorRadius / 10.0)
            
            counter += 1
            points.insert(touch.location(in: drawingView), at: counter)
            
            if counter == 4 {
                
                points[3] = CGPoint(x: (points[2].x + points[4].x)/2.0, y: (points[2].y + points[4].y) / 2.0)
                
                let context = UIGraphicsGetCurrentContext()
                context?.move(to: points[0])
                context?.addCurve(to: points[3], control1: points[1], control2: points[2])
                context?.setLineCap(.round)
                context?.setLineWidth(brushWidth)
                context?.setStrokeColor(colour!.cgColor)
                context?.setBlendMode(.normal)
                context?.strokePath()
                
                tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
                tempImageView.alpha = opacity
                
                points[0] = points[3]
                points[1] = points[4]
                counter = 1
            }

        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
  
        guard !(palettes.filter({$0.selected}).first is Eye) else { return }
        
        // If the touch did not move, i.e. a dot
        if !swipe {
            if let touch = touches.first, let last_point = points.first  {
                if !palette.frame.contains(touch.location(in: drawingView)) {
                    let context = UIGraphicsGetCurrentContext()
                    context?.move(to: last_point)
                    context?.addLine(to: touch.location(in: drawingView))
                    context?.setLineCap(.round)
                    context?.setLineWidth(brushWidth)
                    context?.setStrokeColor(colour!.cgColor)
                    context?.setBlendMode(.normal)
                    context?.strokePath()
                }
            }
        }
        swipe = false
        counter = 0
        
        mainImageView.image?.draw(in: drawingView.bounds, blendMode: .normal, alpha: 1.0)
        tempImageView.image?.draw(in: drawingView.bounds, blendMode: .normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        tempImageView.image = nil
    }
    
    var notRandomColours = [
        UIColor(red: 0, green: 144, blue: 81),
        UIColor(red: 255, green: 182, blue: 228),
        UIColor(red: 118, green: 214, blue: 255)
    ]
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            UIView.animate(withDuration: 0.5, animations: {
                self.mainImageView.alpha = 0.0
                self.tempImageView.alpha = 0.0
                self.drawingView.backgroundColor = self.notRandomColours.popLast() ?? UIColor.randomColor(1.0)
                self.drawingView.subviews.filter({$0 is Eye}).forEach({ $0.alpha = 0})
            }) { (done) in
                self.clear()
            }
        }
    }
    
    func clear() {
        self.mainImageView.image = nil
        self.tempImageView.image = nil
        self.mainImageView.alpha = 1.0
        self.tempImageView.alpha = 1.0
        self.drawingView.subviews.filter({$0 is Eye}).forEach({ EyeAnimator.shared.clear(eye: $0 as! Eye)})
        self.drawingView.subviews.filter({$0 is Eye}).forEach({ $0.removeFromSuperview()})
    }
    
    @IBAction func selectPalette(sender: UITapGestureRecognizer) {
        if let palette = sender.view as? PaletteOptionView {
            palettes.forEach({$0.selected = false})
            palette.selected = true
            self.configurePalettes()
        }
    }
    
    func configurePalettes() {
        for palette in self.palettes {
            if palette.selected {
                palette.layer.zPosition = CGFloat(MAXFLOAT)
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    palette.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
                }) { (completed) in
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                        palette.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    }, completion: {(completed) in
                        palette.layer.zPosition = 0
                    })
                }
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    palette.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            }
        }
    }

    // MARK: Photo handling, to move to Photos.swift
    
    @IBAction func selectPhoto(sender: UIButton) {
        let alert = UIAlertController(title: "Add Photo?", message: "Do you want to add a photo from the photo library?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes please!", style: .destructive, handler: { (alert) in
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.allowsEditing = false
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No thanks!", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        clear()
        
        UIGraphicsBeginImageContextWithOptions(self.drawingView.frame.size, false, 0)
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage

        let aspect = chosenImage.size.width / chosenImage.size.height
    
        let rect: CGRect
        if self.drawingView.bounds.size.width / aspect > self.drawingView.bounds.size.height {
            let height = self.drawingView.bounds.size.width / aspect
            rect = CGRect(x: 0, y: (self.drawingView.bounds.size.height - height) / 2, width: self.drawingView.bounds.size.width, height: height)
        } else {
            let width = self.drawingView.bounds.size.height * aspect
            rect = CGRect(x: (self.drawingView.bounds.size.width - width) / 2, y: 0, width: width, height: self.drawingView.bounds.size.height)
        }
        chosenImage.draw(in: rect)
        
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        dismiss(animated:true, completion: nil)
    }
    

    // MARK: File functions
    
    @IBAction func save() {
        let alert = UIAlertController(title: "Save Doodle?", message: "Do you want to save this doodle to Photos?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes please!", style: .destructive, handler: { (alert) in
            UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 2.0)
            self.drawingView.layer.render(in: UIGraphicsGetCurrentContext()!)
            CustomPhotoAlbum.sharedInstance.save(image: UIGraphicsGetImageFromCurrentImageContext()!)
            UIGraphicsEndImageContext()
        }))
        alert.addAction(UIAlertAction(title: "No thanks!", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
