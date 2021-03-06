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
    
    private var _origin: CGPoint?
    var origin: CGPoint {
        get {
            if let point = _origin {
                return point
            } else {
                return defaultOrigin
            }
        }
        set {
            _origin = newValue
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var scale: CGFloat = 35 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var _minValue: CGFloat?
    var minValue: CGFloat? { return _minValue }
    
    private var _maxValue: CGFloat?
    var maxValue: CGFloat? { return _maxValue }
    
    private var innerCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }
    
    private let defaultScale: CGFloat = 35
    private var defaultOrigin: CGPoint {
        return innerCenter
    }
    
    func resetLayout() {
        scale = defaultScale
        origin = defaultOrigin
    }
    
    override func drawRect(rect: CGRect) {
        let axesDrawer = AxesDrawer(color: UIColor.blackColor(), contentScaleFactor: contentScaleFactor)
        axesDrawer.drawAxesInRect(rect, origin: origin, pointsPerUnit: scale)
        
        var path = newPath()
        UIColor.blueColor().setStroke()
        
        _minValue = nil
        _maxValue = nil
        
        for x in 0...Int(bounds.width) {
            let xValue = round(convertToCartesianCoordinates(CGFloat(x)), accuracy: scale / 2)
            
            // to handle undefined values
            if let yValue = dataSource?.valueFor(x: xValue) {
                let point = convertToViewCoordinates(CGPoint(x: xValue, y: yValue))
                if path.empty {
                    // start path
                    path.moveToPoint(point)
                } else {
                    // continue path
                    path.addLineToPoint(point)
                }
                updateMinAndMax(yValue)
                
            } else {
                // end path
                path.stroke()
                path = newPath()
            }
        }
        
        path.stroke()
    }
    
    func moveBy(translation: CGPoint) {
        origin = origin + translation
    }
    
    func centerAt(point: CGPoint) {
        origin = point
    }
    
    func zoom(factor: CGFloat, onPoint zoomPoint: CGPoint? = nil) {
        scale *= factor
        
        let offset = origin - (zoomPoint ?? innerCenter)
        origin = origin - offset + (offset * factor)
    }
    
    private func convertToViewCoordinates(point: CGPoint) -> CGPoint {
        let x = origin.x + point.x * scale
        let y = origin.y - point.y * scale
        return CGPoint(x: x, y: y)
    }
    
    private func convertToCartesianCoordinates(x: CGFloat) -> CGFloat {
        return (x - origin.x) / scale
    }
    
    private func newPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.lineWidth = 2
        return path
    }
    
    private func updateMinAndMax(value: CGFloat) {
        if minValue == nil || value < minValue {
            _minValue = value
        }
        if maxValue == nil || value > maxValue {
            _maxValue = value
        }
    }
}

func round(x: CGFloat, accuracy: CGFloat) -> CGFloat {
    return CGFloat(round(x * accuracy) / accuracy)
}
