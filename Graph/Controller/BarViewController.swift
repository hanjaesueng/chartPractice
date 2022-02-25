//
//  BarViewController.swift
//  Graph
//
//  Created by jaeseung han on 2022/02/25.
//

import UIKit

class BarViewController: UIViewController {

    
    @IBOutlet weak var barChart: BasicBarChart!
    @IBOutlet weak var horizonBar: HorizontalGraph!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGR = UILongPressGestureRecognizer(target: self, action: #selector(longPressBar))
        barChart.addGestureRecognizer(tapGR)
        let tapHBar = UILongPressGestureRecognizer(target: self, action: #selector(longPressHBar))
        horizonBar.addGestureRecognizer(tapHBar)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var colors = [UIColor].init(repeating: .white, count: 30)
        colors = colors.map({_ in
            UIColor.init(red: CGFloat(Float.random(in: 0...1)), green: CGFloat(Float.random(in: 0...1)), blue: CGFloat(Float.random(in: 0...1)), alpha: 1)
        })
        
        let barDataEntries = BarEntry.generateDataEntries(color: colors,size: 90)
        let hbarDataEntries = BarEntry.generateDataEntries(color: colors,size: 90)
        barChart.dataEntries = barDataEntries
        barChart.backgroundColor = .systemBackground
        
        horizonBar.dataEntries = hbarDataEntries
        horizonBar.backgroundColor = .systemBackground
    }
    
    @objc func longPressBar(gr:UILongPressGestureRecognizer) {
        let loc:CGPoint = gr.location(in: gr.view)
        //insert your touch based code here
//        barChart.drawHorizontalLine(yPos : loc.y)
        barChart.drawVerticalLine(xPos: loc.x)
        if(gr.state == UIGestureRecognizer.State.ended){
            barChart.removeVerticalLine()
        }
    }
    
    @objc func longPressHBar(gr:UILongPressGestureRecognizer) {
        let loc:CGPoint = gr.location(in: gr.view)
        //insert your touch based code here
        horizonBar.drawHorizontalLine(yPos : loc.y)

        if(gr.state == UIGestureRecognizer.State.ended){
            horizonBar.removeVerticalLine()
        }
    }
    
}
