//
//  PointChart.swift
//  BarChart
//
//  Created by jaeseung han on 2018. 10. 29..
//  Copyright © 2018년 Nguyen Vu Nhat Minh. All rights reserved.
//


import UIKit

protocol SyncDelegate {
    func sync(offset : CGPoint)
}

class PointChart: UIView {
    // variable to save the last position visited, default to zero
    public var lastContentOffset: CGFloat = 0
    
    /// the width of each bar
    let barWidth: CGFloat = 5.0
    
    /// space between each bar
    let space: CGFloat = 1.0
    
    /// space at the bottom of the bar to show the title
    private let bottomSpace: CGFloat = 40.0
    
    /// space at the top of each bar to show the value
    private let topSpace: CGFloat = 40.0
    
    /// contain all layers of the chart
    private let mainLayer: CALayer = CALayer()
    
    /// contain mainLayer to support scrolling
    private let scrollView: UIScrollView = UIScrollView()
    
    private var context : CGContext?
    
    public var oldVerticalLine : CAShapeLayer?
    
    public var oldPoint : CALayer?
   
    var dataEntries: [BarEntry]? = nil {
        didSet {
            mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
            
            if let dataEntries = dataEntries {
                scrollView.contentSize = CGSize(width: (barWidth + space)*CGFloat(dataEntries.count), height: self.frame.size.height)
                mainLayer.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
                drawHorizontalLines()
                
                scrollView.delegate = self
                context = UIGraphicsGetCurrentContext()
                for i in 0..<dataEntries.count {
                    if i<dataEntries.count-1
                    {
                        showEntry(index: i, entry: dataEntries[i] , nextEntry : dataEntries[i+1])
                    }
                }
            }
        }
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
        scrollView.layer.addSublayer(mainLayer)
        self.addSubview(scrollView)
    }
    
    override func layoutSubviews() {
        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    private func showEntry(index: Int, entry: BarEntry , nextEntry : BarEntry) {
        /// Starting x postion of the bar
        let xPos: CGFloat = space + CGFloat(index) * (barWidth + space)
        
        /// Starting y postion of the bar
        let yPos: CGFloat = translateHeightValueToYPosition(value: entry.height)
        
        let xNext : CGFloat = space + CGFloat(index+1) * (barWidth + space)
        
        let yNext: CGFloat = translateHeightValueToYPosition(value: nextEntry.height)
        
        // point draw
        //drawPoint(xPos: xPos, yPos: yPos, color: entry.color)
        
        // line draw
        drawLine(xPos: xPos, yPos: yPos, xNext : xNext , yNext : yNext, color: entry.color)
        
        /// Draw text above the bar
        //drawTextValue(xPos: xPos - space/2, yPos: yPos - 30, textValue: entry.textValue, color: entry.color)
        
        /// Draw text below the bar
        //drawTitle(xPos: xPos - space/2, yPos: mainLayer.frame.height - bottomSpace + 10, title: entry.title, color: entry.color)
    }
    
    private func drawPoint(xPos: CGFloat, yPos: CGFloat, color: UIColor) {
      
        let pointMarker = valueMarker()
        pointMarker.frame = CGRect(x: xPos , y: CGFloat(ceil(yPos) ), width: 10, height: 10)
        pointMarker.backgroundColor = color.cgColor
        mainLayer.addSublayer(pointMarker)
    }

    private func replacePoint(xPos: CGFloat, yPos: CGFloat, color: UIColor) {
        
        let pointMarker = valueMarker()
        pointMarker.frame = CGRect(x: xPos , y: CGFloat(ceil(yPos) ), width: 10, height: 10)
        pointMarker.backgroundColor = color.cgColor
        guard (oldPoint != nil) else {
            mainLayer.addSublayer(pointMarker);
            oldPoint = pointMarker
            return
        }
        mainLayer.replaceSublayer(oldPoint!, with: pointMarker)
        oldPoint = pointMarker
    }


    
    private func drawLine(xPos: CGFloat, yPos: CGFloat, xNext : CGFloat , yNext : CGFloat, color: UIColor){
        let path = UIBezierPath()
        path.move(to: CGPoint(x: xPos + 5, y: CGFloat(ceil(yPos) + 5 )))
        path.addLine(to: CGPoint(x: xNext + 5, y: yNext + 5))
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.lineWidth = 0.5
        lineLayer.strokeColor = color.cgColor
        lineLayer.opacity = 0.5
        mainLayer.insertSublayer(lineLayer, at: 0)
    }
    
    // Returns a point for plotting
    func valueMarker() -> CALayer {
        let pointMarker = CALayer()
        pointMarker.backgroundColor = UIColor.red.cgColor
        pointMarker.cornerRadius = 8
        pointMarker.masksToBounds = true
        
        let markerInner = CALayer()
        markerInner.frame = CGRect(x: 3, y: 3, width: 3, height: 3)
        markerInner.cornerRadius = 5
        markerInner.masksToBounds = true
        markerInner.backgroundColor = UIColor.red.cgColor
        
        pointMarker.addSublayer(markerInner)
        
        return pointMarker
    }
    
    
    private func drawHorizontalLines() {
        self.layer.sublayers?.forEach({
            if $0 is CAShapeLayer {
                $0.removeFromSuperlayer()
            }
        })
        let horizontalLineInfos = [["value": Float(0.0), "dashed": false], ["value": Float(1.0), "dashed": false]]
        for lineInfo in horizontalLineInfos {
            let xPos = CGFloat(0.0)
            let yPos = translateHeightValueToYPosition(value: (lineInfo["value"] as! Float))
            let path = UIBezierPath()
            path.move(to: CGPoint(x: xPos, y: yPos))
            path.addLine(to: CGPoint(x: scrollView.frame.size.width, y: yPos))
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.lineWidth = 0.5
            if lineInfo["dashed"] as! Bool {
                lineLayer.lineDashPattern = [4, 4]
            }
            lineLayer.strokeColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
            self.layer.insertSublayer(lineLayer, at: 0)
        }
    }
    
    func drawVerticalLine(xPos : CGFloat) -> String?{
        let path = UIBezierPath()
        path.move(to: CGPoint(x: xPos, y: scrollView.frame.size.height))
        path.addLine(to: CGPoint(x: xPos, y: 0))
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.lineWidth = 2
        lineLayer.strokeColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor
        guard (oldVerticalLine != nil) else {
            self.layer.addSublayer(lineLayer);
            oldVerticalLine = lineLayer
            return nil
        }
        self.layer.replaceSublayer(oldVerticalLine!, with: lineLayer)
        oldVerticalLine = lineLayer
        
        // index 구함
        let index = (xPos + lastContentOffset - space)/(barWidth + space)
        let indexInt: Int = Int(index)
        let configXPos: CGFloat = space + CGFloat(indexInt) * (barWidth + space)
        guard indexInt >= 0 || indexInt < Int(self.frame.size.width)  else{
            return nil
        }
        let yPos: CGFloat = translateHeightValueToYPosition(value: (dataEntries?[indexInt].height)!)
     
        
        replacePoint(xPos: configXPos, yPos: yPos, color: UIColor.white)
        
        return "time : \(indexInt)min\nvalue: \(dataEntries![indexInt].textValue)"
    }
    public func removeVerticalLine(){
        oldVerticalLine?.opacity = 0
        oldPoint?.opacity = 0
    }
    
    private func drawTextValue(xPos: CGFloat, yPos: CGFloat, textValue: String, color: UIColor) {
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth+space, height: 22)
        textLayer.foregroundColor = color.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = 14
        textLayer.string = textValue
        mainLayer.addSublayer(textLayer)
    }
    
    private func drawTitle(xPos: CGFloat, yPos: CGFloat, title: String, color: UIColor) {
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth + space, height: 22)
        textLayer.foregroundColor = color.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = 14
        textLayer.string = title
        mainLayer.addSublayer(textLayer)
    }
    
    private func translateHeightValueToYPosition(value: Float) -> CGFloat {
        let height: CGFloat = CGFloat(value) * (mainLayer.frame.height - bottomSpace - topSpace)
        return mainLayer.frame.height - bottomSpace - height
    }

}

extension PointChart : UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.x
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.x
    }
}
