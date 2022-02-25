//
//  HorizontalGraph.swift
//  BarChart
//
//  Created by jaeseung han on 2018. 11. 8..
//  Copyright © 2018년 Nguyen Vu Nhat Minh. All rights reserved.
//


import UIKit

class HorizontalGraph: UIView {
    // variable to save the last position visited, default to zero
    public var lastContentOffset: CGFloat = 0
    
    /// the width of each bar
    let barWidth: CGFloat = 40.0
    
    /// space between each bar
    let space: CGFloat = 5.0
    
    /// space at the bottom of the bar to show the title
    private let rightSpace: CGFloat = 40.0
    
    /// space at the top of each bar to show the value
    private let leftSpace: CGFloat = 40.0
    
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
                scrollView.contentSize = CGSize(width: self.frame.size.width, height: (barWidth + space)*CGFloat(dataEntries.count))
                mainLayer.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
                
                scrollView.delegate = self
                drawVerticalLines()
                
                for i in 0..<dataEntries.count {
                    showEntry(index: i, entry: dataEntries[i])
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
    
    private func showEntry(index: Int, entry: BarEntry) {
        /// Starting y postion of the bar
        let yPos: CGFloat = space + CGFloat(index) * (barWidth + space)
        
        /// Starting x postion of the bar
       
        let xPos: CGFloat = translateWidthValueToXPosition(value: entry.height)
      
        if (index%30)==0{
            drawtimeLine(yPos: yPos - space/2)
            drawTitle(xPos: leftSpace - (40 + space),yPos: yPos - space/2 , title: "\(index)", color: UIColor.white)
        }
            
        drawBar(xPos: xPos, yPos: yPos, color: entry.color)
       
        
        /// Draw text above the bar
        //drawTextValue(xPos: xPos - space/2, yPos: yPos - 30, textValue: entry.textValue, color: entry.color)
        
        /// Draw text below the bar
        //drawTitle(xPos: xPos - space/2, yPos: mainLayer.frame.height - bottomSpace + 10, title: entry.title, color: entry.color)
    }
    
    private func drawBar(xPos: CGFloat, yPos: CGFloat, color: UIColor) {
        let barLayer = CALayer()
        barLayer.frame = CGRect(x: leftSpace, y: yPos, width: xPos-leftSpace, height: barWidth)
        barLayer.backgroundColor = color.cgColor
        barLayer.opacity = 1.0
        
        mainLayer.addSublayer(barLayer)
        
    }
    
    private func drawUpperBar(xPos: CGFloat, yPos: CGFloat, color: UIColor) {
        let barLayer = CALayer()
        barLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth, height: mainLayer.frame.height - rightSpace - yPos -  ((mainLayer.frame.height-rightSpace-leftSpace) * 0.7))
        barLayer.backgroundColor = color.cgColor
        barLayer.opacity = 0.9
        mainLayer.addSublayer(barLayer)
        
    }
    
    private func replaceBar(xPos: CGFloat, yPos: CGFloat, color: UIColor){
        let barLayer = CALayer()
        barLayer.frame = CGRect(x: leftSpace, y: yPos, width: xPos - leftSpace, height: barWidth)
        
        barLayer.backgroundColor = color.cgColor
        barLayer.borderColor = UIColor.black.cgColor
        barLayer.borderWidth = 2
        barLayer.opacity = 1.0
        guard (oldSelectedBar != nil) else {
            mainLayer.addSublayer(barLayer);
            oldSelectedBar = barLayer
            return
        }
        mainLayer.replaceSublayer(oldSelectedBar!, with: barLayer)
        oldSelectedBar = barLayer
    }
    
    public func drawtimeLine(yPos : CGFloat){
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: yPos))
        path.addLine(to: CGPoint(x: mainLayer.frame.size.width, y: yPos))
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.lineWidth = 0.5
        lineLayer.strokeColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1).cgColor
        mainLayer.addSublayer(lineLayer);
    }
    
    private func drawVerticalLines() {
        self.layer.sublayers?.forEach({
            if $0 is CAShapeLayer {
                $0.removeFromSuperlayer()
            }
        })
        let horizontalLineInfos = [["value": Float(0.0), "dashed": false], ["value": Float(0.7), "dashed": true], ["value": Float(1.0), "dashed": false]]
        for lineInfo in horizontalLineInfos {
            let yPos = CGFloat(0.0)
            let xPos = translateWidthValueToXPosition(value: (lineInfo["value"] as! Float))
            let path = UIBezierPath()
            path.move(to: CGPoint(x: xPos, y: yPos))
            path.addLine(to: CGPoint(x: xPos, y: scrollView.frame.size.height))
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.lineWidth = 0.5
            if lineInfo["dashed"] as! Bool {
                lineLayer.lineDashPattern = [4, 4]
            }
            lineLayer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
            self.layer.insertSublayer(lineLayer, at: 0)
        }
    }
    
    public func drawHorizontalLine(yPos : CGFloat){
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: yPos))
        path.addLine(to: CGPoint(x: scrollView.frame.size.width, y: yPos))
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.lineWidth = 2
        lineLayer.strokeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        guard (oldVerticalLine != nil) else {
//            self.layer.addSublayer(lineLayer);
            oldVerticalLine = lineLayer
            return
        }
//        self.layer.replaceSublayer(oldVerticalLine!, with: lineLayer)
        oldVerticalLine = lineLayer
        
        /// 선택된 부분 bar생성
        let index = (yPos + lastContentOffset - space)/(barWidth + space)
        let indexInt: Int = Int(index)
        let configYPos: CGFloat = space + CGFloat(indexInt) * (barWidth + space)
        guard indexInt >= 0 else{
            return
        }
        let xPos: CGFloat = translateWidthValueToXPosition(value: (dataEntries?[indexInt].height)!)
        replaceBar(xPos: xPos, yPos: configYPos, color: UIColor.white)
        
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
        textLayer.frame = CGRect(x: xPos, y: yPos, width: 40+space, height: 22)
        textLayer.foregroundColor = color.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = 14
        textLayer.string = title
        //90 도 회전
        let degrees = 90.0
        let radians = CGFloat(degrees * M_PI / 180)
        textLayer.transform = CATransform3DMakeRotation(radians, 0, 0, 1.0)
        mainLayer.addSublayer(textLayer)
    }
    
    private func translateWidthValueToXPosition(value: Float) -> CGFloat {
        let width: CGFloat = CGFloat(value) * (mainLayer.frame.width - rightSpace - leftSpace)
        return leftSpace + width
    }
    
    private func upperTranslateHeightValueToYPosition(value: Float) -> CGFloat {
        let height: CGFloat = CGFloat(value) * (mainLayer.frame.height - rightSpace - leftSpace)
        return mainLayer.frame.height - rightSpace - height
    }
}

extension HorizontalGraph : UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
}

