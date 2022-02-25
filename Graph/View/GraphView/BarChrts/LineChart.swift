//
//  LineChart.swift
//  BarChart
//
//  Created by jaeseung han on 2018. 11. 8..
//  Copyright © 2018년 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit

class LineChart: UIView {
    
    // variable to save the last position visited, default to zero
    public var lastContentOffset: CGFloat = 0
    
    /// the width of each bar
    let barWidth: CGFloat = 5.0
    
    /// space between each bar
    let space: CGFloat = 30
    
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
        //didSet -> BarEntry가 설정되고 난 직후에 호출, willSet -> BarEntry가 설정되기 직전에 호출
        didSet {
            mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
            if let dataEntries = dataEntries {
                scrollView.contentSize = CGSize(width: (barWidth + space)*CGFloat(dataEntries.count), height: self.frame.size.height)
                mainLayer.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
                
                NotificationCenter.default.addObserver(self, selector: #selector(barNotification), name:  NSNotification.Name(rawValue: "sendToBars"), object: nil)
                scrollView.delegate = self
                drawHorizontalLines()
                
                for i in 0..<dataEntries.count {
                    showEntry(index: i, entry: dataEntries[i])
                }
            }
        }
    }
    
    @objc private func barNotification(_ notification : NSNotification){
        
        if let offset = notification.userInfo?["offset"] as? CGFloat{
            scrollView.contentOffset.x  = offset
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
        
        
        if (index%30)==0{
            drawtimeLine(xPos: xPos - space/2)
            drawTitle(xPos: xPos - space/2, yPos: mainLayer.frame.height - bottomSpace , title: "\(index)", color: entry.color)
        }
        
        /// Starting y postion of the bar
        let yPos: CGFloat = translateHeightValueToYPosition(value: entry.height)
            
        drawLinkingLine(xPos: xPos, yPos: yPos, color: entry.color)
       
        
        /// Draw text above the bar
        //drawTextValue(xPos: xPos - space/2, yPos: yPos - 30, textValue: entry.textValue, color: entry.color)
        
        /// Draw text below the bar
        
    }
    
    private func drawLinkingLine(xPos: CGFloat, yPos: CGFloat, color: UIColor) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: xPos, y: mainLayer.frame.size.height-topSpace))
        path.addLine(to: CGPoint(x: xPos, y: yPos))
        let line = CAShapeLayer()
        line.path = path.cgPath
        line.fillColor = UIColor.clear.cgColor
        line.strokeColor = color.cgColor
        line.lineWidth = 2.0
        mainLayer.addSublayer(line)
        
        let topCircle = CALayer()
        topCircle.frame = CGRect(x: xPos-3, y: yPos, width: 6, height: 6)
        topCircle.backgroundColor = color.cgColor
        topCircle.cornerRadius = 3.0
        mainLayer.addSublayer(topCircle)
    }
   
    private func replaceBar(xPos: CGFloat, yPos: CGFloat, color: UIColor){
      
        let topCircle = CALayer()
        topCircle.frame = CGRect(x: xPos-5, y: yPos, width: 10, height: 10)
        topCircle.backgroundColor = color.cgColor
        topCircle.cornerRadius = 5.0
        mainLayer.addSublayer(topCircle)
        
        guard (oldSelectedBar != nil) else {
            mainLayer.addSublayer(topCircle);
            oldSelectedBar = topCircle
            return
        }
        mainLayer.replaceSublayer(oldSelectedBar!, with: topCircle)
        oldSelectedBar = topCircle
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
    public func drawtimeLine(xPos : CGFloat){
        let path = UIBezierPath()
        path.move(to: CGPoint(x: xPos, y: mainLayer.frame.size.height))
        path.addLine(to: CGPoint(x: xPos, y: 0))
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.lineWidth = 0.5
        lineLayer.strokeColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1).cgColor
        mainLayer.addSublayer(lineLayer);
    }
    
    public func drawVerticalLine(xPos : CGFloat) -> String?{
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
        
        /// 선택된 부분 bar생성
        let index = (xPos + lastContentOffset - space)/(barWidth + space)
        let indexInt: Int = Int(index)
        
        let configXPos: CGFloat = space + CGFloat(indexInt) * (barWidth + space)
        guard indexInt >= 0 else{
            return nil
        }
        let yPos: CGFloat = translateHeightValueToYPosition(value: (dataEntries?[indexInt].height)!)
        replaceBar(xPos: configXPos, yPos: yPos, color: UIColor.white)
        
        return "time : \(indexInt)min\nvalue: \(dataEntries![indexInt].textValue)"
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
        textLayer.frame = CGRect(x: xPos, y: yPos, width: 40 + space, height: 15)
        textLayer.foregroundColor = UIColor.white.cgColor
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

extension LineChart : UIScrollViewDelegate{
    public func getScrollsOffset() -> CGFloat{
        return lastContentOffset
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.x
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendToPoints"), object: nil, userInfo: ["offset" : lastContentOffset])
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.x
    }
}
