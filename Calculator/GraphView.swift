//
//  GraphView.swift
//  Calculator
//
//  Created by Pascal Attwenger on 27/07/15.
//  Copyright © 2015 Pascal Attwenger. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func valueFor(x x: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {

    weak var dataSource: GraphViewDataSource?
    
    var axesOrigin: CGPoint {
        return convertPoint(self.center, fromView: superview)
    }
    
    @IBInspectable
    var scale: CGFloat = 25
    
    override func drawRect(rect: CGRect) {
        let axesDrawer = AxesDrawer(color: UIColor.blackColor())
        axesDrawer.drawAxesInRect(rect, origin: axesOrigin, pointsPerUnit: scale)
        
        var path = newPath()
        UIColor.blueColor().setStroke()
        
        for i in -140...140 {
            let xValue = CGFloat(i) / 10
            let yValue = dataSource?.valueFor(x: xValue)
            
            // to handle undefined values
            if path.empty {
                if yValue != nil {
                    // start path
                    path.moveToPoint(pointInCoordinateSystem(x: xValue, y: yValue!))
                }
            } else {
                if yValue != nil {
                    // continue path
                    path.addLineToPoint(pointInCoordinateSystem(x: xValue, y: yValue!))
                } else {
                    // end path
                    path.stroke()
                    path = newPath()
                }
            }
        }
        
        path.stroke()
    }
    
    private func pointInCoordinateSystem(x xValue: CGFloat, y yValue: CGFloat) -> CGPoint {
        let x = axesOrigin.x + xValue * scale
        let y = axesOrigin.y - yValue * scale
        return CGPoint(x: x, y: y)
    }
    
    private func newPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.lineWidth = 2
        return path
    }
}
