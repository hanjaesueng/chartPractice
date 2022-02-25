//
//  BasicBarChart.swift
//  BarChart
//
//  Created by Nguyen Vu Nhat Minh on 19/8/17.
//  Copyright © 2017 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit

class BasicBarChart: UIView {
    // variable to save the last position visited, default to zero
    public var lastContentOffset: CGFloat = 0
    
    /// the width of each bar
    let barWidth: CGFloat = 40.0
    
    /// space between each bar
    let space: CGFloat = 5.0
    
    /// space at the bottom of the bar to show the title
    private let bottomSpace: CGFloat = 40.0
    
    /// space at the top of each bar to show the value
    private let topSpace: CGFloat = 40.0
    
    /// contain all layers of the chart
    private let mainLayer: CALayer = CALayer()
    
    /// contain mainLayer to support scrolling
    private let scrollView: UIScrollView = UIScrollView()
    
    public var oldVerticalLine : CAShapeLayer?
    
    public var oldSelectedBar : CALayer?
    
  
    var dataEntries: [BarEntry]? = nil {
        didSet {
            mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
            if let dataEntries = dataEntries {
                scrollView.contentSize = CGSize(width: (barWidth + space)*CGFloat(dataEntries.count), height: self.frame.size.height)
                mainLayer.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
           
                scrollView.delegate = self
                
                
                for i in 0..<dataEntries.count {
                    showEntry(index: i, entry: dataEntries[i])
                }
                drawHorizontalLines()
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
    
    private func showEntry(index: Int, entry: BarEntry) {
        /// Starting x postion of the bar
        let xPos: CGFloat = space + CGFloat(index) * (barWidth + space)
        
        
        if entry.height < 0.7{
            /// Starting y postion of the bar
            let yPos: CGFloat = translateHeightValueToYPosition(value: entry.height)
        
            drawBar(xPos: xPos, yPos: yPos, color: entry.color)
        } else {
            let yPos: CGFloat = translateHeightValueToYPosition(value: 0.7)
            
            drawBar(xPos: xPos, yPos: yPos, color: entry.color)
            let upperYPos: CGFloat = translateHeightValueToYPosition(value: entry.height)
            drawUpperBar(xPos: xPos, yPos: upperYPos, color: entry.color)
        }
        
        /// Draw text above the bar
        //drawTextValue(xPos: xPos - space/2, yPos: yPos - 30, textValue: entry.textValue, color: entry.color)
        
        /// Draw text below the bar
        //drawTitle(xPos: xPos - space/2, yPos: mainLayer.frame.height - bottomSpace + 10, title: entry.title, color: entry.color)
    }
    
    private func drawBar(xPos: CGFloat, yPos: CGFloat, color: UIColor) {
        let barLayer = CALayer()
        barLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth, height: mainLayer.frame.height - bottomSpace - yPos)
        barLayer.backgroundColor = color.cgColor
        barLayer.opacity = 1.0
        
        mainLayer.addSublayer(barLayer)
        
    }
    
    private func drawUpperBar(xPos: CGFloat, yPos: CGFloat, color: UIColor) {
        let barLayer = CALayer()
        barLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth, height: mainLayer.frame.height -   bottomSpace - yPos -  ((mainLayer.frame.height-bottomSpace-topSpace) * 0.7))
        barLayer.backgroundColor = color.cgColor
        barLayer.opacity = 1.0
        mainLayer.addSublayer(barLayer)
        
    }
    
    private func replaceBar(xPos: CGFloat, yPos: CGFloat, color: UIColor){
        let barLayer = CALayer()
        barLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth, height: mainLayer.frame.height - bottomSpace - yPos)
        barLayer.borderColor = UIColor.black.cgColor
        barLayer.borderWidth = 2
        barLayer.backgroundColor = color.cgColor
        barLayer.opacity = 1
        guard (oldSelectedBar != nil) else {
            mainLayer.addSublayer(barLayer);
            oldSelectedBar = barLayer
            return
        }
        mainLayer.replaceSublayer(oldSelectedBar!, with: barLayer)
        oldSelectedBar = barLayer
    }
    
    
    private func drawHorizontalLines() {
        self.layer.sublayers?.forEach({
            if $0 is CAShapeLayer {
                $0.removeFromSuperlayer()
            }
        })
        let horizontalLineInfos = [["value": Float(0.0), "dashed": false], ["value": Float(0.7), "dashed": true], ["value": Float(1.0), "dashed": false]]
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
    
    public func drawVerticalLine(xPos : CGFloat){
        let path = UIBezierPath()
        path.move(to: CGPoint(x: xPos, y: scrollView.frame.size.height))
        path.addLine(to: CGPoint(x: xPos, y: 0))
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.lineWidth = 2
        lineLayer.strokeColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor
        guard (oldVerticalLine != nil) else {
//            self.layer.addSublayer(lineLayer);
            oldVerticalLine = lineLayer
            return
        }
//        self.layer.replaceSublayer(oldVerticalLine!, with: lineLayer)
        oldVerticalLine = lineLayer
        
        /// 선택된 부분 bar생성
        let index = (xPos + lastContentOffset - space)/(barWidth + space)
        let indexInt: Int = Int(index)
        let configXPos: CGFloat = space + CGFloat(indexInt) * (barWidth + space)
        guard indexInt >= 0 else{
            return
        }
        let yPos: CGFloat = translateHeightValueToYPosition(value: (dataEntries?[indexInt].height)!)
        replaceBar(xPos: configXPos, yPos: yPos, color: UIColor.white)
       
    }
    public func removeVerticalLine(){
        oldVerticalLine?.isHidden = true
        oldSelectedBar?.isHidden = true
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
    
    private func upperTranslateHeightValueToYPosition(value: Float) -> CGFloat {
        let height: CGFloat = CGFloat(value) * (mainLayer.frame.height - bottomSpace - topSpace)
        return mainLayer.frame.height - bottomSpace - height
    }
}

extension BasicBarChart : UIScrollViewDelegate{

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.x
    }
    
  
   func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.x
    }
}
