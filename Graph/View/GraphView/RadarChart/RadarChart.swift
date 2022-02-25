//
//  RadarChart.swift
//  BarChart
//
//  Created by jaeseung han on 2018. 11. 13..
//  Copyright © 2018년 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit


class RadarChart: UIView {
    
    
    /// contain all layers of the chart
    private let mainLayer: CALayer = CALayer()
    
    private let UnitScalar = 150
    
    private var initialValue = CGPoint(x : 150, y : 150 )
    
    private var centor : CGPoint?
    
    public var oldVerticalLine : CAShapeLayer?
    
    private var drawData = UIBezierPath()
    
    private var dataPolygon = CAShapeLayer()
    
    private var currentDegree = 0
    
    private var oldPolygon = CAShapeLayer()
    
    var dataEntries: [BarEntry]? = nil {
        didSet {
            mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
            if let dataEntries = dataEntries {
               
                mainLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
                centor = CGPoint(x : self.frame.size.width/2 , y: self.frame.size.height/2)
                let degree = 360 / CGFloat(dataEntries.count)
                drawPolygon(degree: degree,size : dataEntries.count)
                drawLine(degree: degree,size : dataEntries.count)
                drawInerPolygon(degree: degree,size : dataEntries.count)
                drawInerestPolygon(degree: degree,size : dataEntries.count)
                drawData = UIBezierPath()
                currentDegree = 0
                dataPolygon = CAShapeLayer()
             
                mainLayer.addSublayer(dataPolygon)
               
                dataPolygon.opacity = 0.5
                dataPolygon.lineWidth = 2
                dataPolygon.lineJoin = CAShapeLayerLineJoin.miter
                dataPolygon.strokeColor = UIColor.yellow.cgColor
                dataPolygon.fillColor = UIColor.red.cgColor
                
                
                for i in 0..<dataEntries.count {
                    showEntry(index: i, entry: dataEntries[i],degree : degree)
                }
            }
        }
    }
    
    private func showEntry(index: Int, entry: BarEntry, degree : CGFloat) {
       
        initialValue = CGPoint(x : CGFloat(UnitScalar) * CGFloat(entry.height) , y : CGFloat(UnitScalar) * CGFloat(entry.height))
     
        currentDegree = index * Int(degree)
        if index == 0{
            drawData.move(to: centor!.plus(var1: initialValue.euler(degree: currentDegree)))
        } else {
            drawData.addLine(to: centor!.plus(var1: initialValue.euler(degree: currentDegree)))
        }
        if index == dataEntries!.count - 1 {
            drawData.close()
            dataPolygon.path = drawData.cgPath
        }
        drawTextValue(xPos : centor!.plus(var1: initialValue.euler(degree: currentDegree)).x, yPos: centor!.plus(var1: initialValue.euler(degree: currentDegree)).y, textValue: entry.textValue,color: entry.color)
        initialValue = CGPoint(x : CGFloat(UnitScalar) * 1.0 , y : CGFloat(UnitScalar) * 1.0)
        drawTitle(xPos : centor!.plus(var1: initialValue.euler(degree: currentDegree)).x, yPos: centor!.plus(var1: initialValue.euler(degree: currentDegree)).y, title: entry.title,color: entry.color)
        
        
        
    }
    
    private func drawTitle(xPos: CGFloat, yPos: CGFloat, title: String, color: UIColor) {
        let textLayer = CATextLayer()
        if xPos < self.frame.size.width/2{
            textLayer.frame = CGRect(x: xPos-50, y: yPos, width: 50 , height: 20)
        } else if yPos < self.frame.size.height/2 {
            textLayer.frame = CGRect(x: xPos, y: yPos-20, width: 50 , height: 20)
        } else if xPos < self.frame.size.width/2 && yPos < self.frame.size.height/2 {
            textLayer.frame = CGRect(x: xPos-50, y: yPos-20, width: 50 , height: 20)
        } else {
            textLayer.frame = CGRect(x: xPos, y: yPos, width: 50 , height: 20)
        }
 
        textLayer.foregroundColor = color.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = 14
        textLayer.string = title
        mainLayer.addSublayer(textLayer)
    }
    
    private func drawTextValue(xPos: CGFloat, yPos: CGFloat, textValue: String, color: UIColor) {
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(x: xPos, y: yPos, width: 20, height: 22)
        textLayer.foregroundColor = color.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = 14
        textLayer.string = textValue
        mainLayer.addSublayer(textLayer)
    }
    private func drawLine(degree : CGFloat,size : Int){
        guard centor != nil else {
            return
        }
        let shape = CAShapeLayer()
        mainLayer.addSublayer(shape)
        shape.opacity = 0.5
        shape.lineWidth = 1
        shape.lineJoin = CAShapeLayerLineJoin.miter
        shape.strokeColor = UIColor.black.cgColor
        shape.lineDashPattern = [5,5]
        shape.fillColor = UIColor.clear.cgColor
        
        let path = UIBezierPath()
        var current = 0
        path.move(to: centor!)
        for i in 0 ..< size + 1 {
            current = i * Int(degree)
            path.addLine(to: centor!.plus(var1: initialValue.euler(degree: current)) )
            path.move(to: centor!)
        }
        path.close()
        
        shape.path = path.cgPath
        
    }
    private func drawPolygon(degree : CGFloat,size : Int){
        guard centor != nil else {
            return
        }
        let shape = CAShapeLayer()
        mainLayer.addSublayer(shape)
        shape.opacity = 0.5
        shape.lineWidth = 2
        shape.lineJoin = CAShapeLayerLineJoin.miter
        shape.strokeColor = UIColor.purple.cgColor
        shape.fillColor = UIColor.clear.cgColor
        
        let path = UIBezierPath()
        var current = 0
        path.move(to: centor!.plus(var1: initialValue.euler(degree: current)))
        for i in 1 ..< size + 1 {
            current = i * Int(degree)
            path.addLine(to: centor!.plus(var1: initialValue.euler(degree: current)) )
        }
        path.close()
        
        shape.path = path.cgPath
        
    }
    private func drawInerPolygon(degree : CGFloat,size : Int){
        guard centor != nil else {
            return
        }
        let shape = CAShapeLayer()
        mainLayer.addSublayer(shape)
        shape.opacity = 0.5
        shape.lineWidth = 2
        shape.lineJoin = CAShapeLayerLineJoin.miter
        shape.strokeColor = UIColor.blue.cgColor
        shape.fillColor = UIColor.clear.cgColor
        
        let path = UIBezierPath()
        var current = 0
        initialValue = CGPoint(x : CGFloat(UnitScalar) * 0.4 , y : CGFloat(UnitScalar) * 0.4)
        path.move(to: centor!.plus(var1: initialValue.euler(degree: current)))
        for i in 1 ..< size + 1 {
            current = i * Int(degree)
            path.addLine(to: centor!.plus(var1: initialValue.euler(degree: current)) )
        }
        path.close()
        shape.path = path.cgPath
    }
    
    private func drawInerestPolygon(degree : CGFloat,size : Int){
        guard centor != nil else {
            return
        }
        let shape = CAShapeLayer()
        mainLayer.addSublayer(shape)
        shape.opacity = 0.5
        shape.lineWidth = 2
        shape.lineJoin = CAShapeLayerLineJoin.miter
        shape.strokeColor = UIColor.red.cgColor
        shape.fillColor = UIColor.clear.cgColor
        
        let path = UIBezierPath()
        var current = 0
        initialValue = CGPoint(x : CGFloat(UnitScalar) * 0.7 , y : CGFloat(UnitScalar) * 0.7)
        path.move(to: centor!.plus(var1: initialValue.euler(degree: current)))
        for i in 1 ..< size + 1 {
            current = i * Int(degree)
            path.addLine(to: centor!.plus(var1: initialValue.euler(degree: current)) )
        }
        path.close()
        shape.path = path.cgPath
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        self.layer.addSublayer(mainLayer)
    }
    
}


extension CGPoint{
    func plus( var1 : CGPoint) -> CGPoint{
        return CGPoint(x : self.x + var1.x, y : self.y + var1.y)
    }
    
    func euler( degree : Int) -> CGPoint{
        return CGPoint(x: self.x * cos(CGFloat(degree) * CGFloat.pi / 180), y: self.y * sin(CGFloat(degree) * CGFloat.pi / 180))
    }
}
