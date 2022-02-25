//
//  ViewController.swift
//  Graph
//
//  Created by jaeseung han on 2022/02/25.
//

import UIKit


class RadarCircleViewController: UIViewController {
    
    
    @IBOutlet weak var polygon: RadarChart!
    
    @IBOutlet weak var circlePieIndicatorView: CirclePieIndicatorView!
    
    
    
    
    @IBAction func refreshAction(_ sender: Any) {
        self.circlePieRefresh()
        self.polygonRefresh()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let values = [0, 150, 300, 0, 150, 300, 0, 150, 300, 0, 150, 300,40]
        var totalValues = 0
        for val in values {
            totalValues += val
            
        }
        let totals = [200, 500, 350, 220, 600, 500, 200, 500, 350, 220, 600, 500,50]
        var totalTotals = 0
        for total in totals {
            totalTotals += total
        }
        
        let percent = (Double(totalValues) / Double(totalTotals)) * 100
        circlePieIndicatorView.percentageLabel.text = percent.format(f: ".0") + "%"
        circlePieIndicatorView.descriptionLabel.text = "Setted"
        circlePieIndicatorView.circlePieView.setSegmentValues(
            values: values,
            totals: totals,
            colors: [UIColor.green, UIColor.yellow, UIColor.red, UIColor.green, UIColor.yellow, UIColor.red, UIColor.green, UIColor.yellow, UIColor.red, UIColor.green, UIColor.yellow, UIColor.red, UIColor.red])
    }
   
   
    override func viewDidAppear(_ animated: Bool) {
        
        let dataEntries = generateSoccerData(color: [UIColor.cyan,UIColor.red,UIColor.green,UIColor.brown],size: 6)
        polygon.dataEntries = dataEntries
 
        
    }
    
    
    
    private func generateSoccerData(color : [UIColor],size : Int) -> [BarEntry] {
        let colors = color
        var result: [BarEntry] = []
        let soccer : [String] = ["pass","shoot","tackle","dribble","speed","physical"]
        for i in 0..<size {
            let value = (arc4random() % 90) + 10
            let height: Float = Float(value) / 100.0
            
            result.append(BarEntry(color: colors[i % colors.count], height: height, textValue: "\(value)", title:  soccer[i]))
        }
        return result
    }
 
    private func polygonRefresh(){
        let dataEntries = generateSoccerData(color: [UIColor.cyan,UIColor.red,UIColor.green,UIColor.brown],size: 6)
        polygon.dataEntries = dataEntries
    }
    
    private func circlePieRefresh(){
        let itemCount = Int.random(in: 5...10)
        
        var totals = [Int].init(repeating: 0, count: itemCount)
        
        totals = totals.map { _ in
            Int.random(in: 0...600)
        }
        
        var totalTotals = 0
        for total in totals {
            totalTotals += total
        }
        
        var values = [Int].init(repeating: 0, count: itemCount)
        for (i,ele) in totals.enumerated() {
            values[i] = Int.random(in: 0...ele)
        }
        var totalValues = 0
        for val in values {
            totalValues += val
            
        }
        
        var colors = [UIColor].init(repeating: UIColor.white, count: itemCount)
        colors = colors.map({ _ in
            UIColor.init(red: CGFloat(Float.random(in: 0...1)), green: CGFloat(Float.random(in: 0...1)), blue: CGFloat(Float.random(in: 0...1)), alpha: 1.0)
        })
        
        
        let percent = (Double(totalValues) / Double(totalTotals)) * 100
        circlePieIndicatorView.percentageLabel.text = percent.format(f: ".0") + "%"
        circlePieIndicatorView.descriptionLabel.text = "Setted"
        circlePieIndicatorView.circlePieView.setSegmentValues(
            values: values,
            totals: totals,
            colors: colors)
        circlePieIndicatorView.circlePieView.setNeedsDisplay()
    }
  
 
}

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f" as NSString, self) as String
    }
}

    
