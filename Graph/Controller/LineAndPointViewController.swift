//
//  lineAndBarViewController.swift
//  Graph
//
//  Created by jaeseung han on 2022/02/25.
//

import UIKit

class LineAndPointViewController: UIViewController {

    @IBOutlet weak var lineChart: LineChart!
    @IBOutlet weak var pointChart: PointChart!
    
    private let lineValue : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 21)
        label.numberOfLines = 2
        return label
    }()
    
    private let pointValue : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 21)
        label.numberOfLines = 2
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChart.addSubview(lineValue)
        pointChart.addSubview(pointValue)
        lineValue.translatesAutoresizingMaskIntoConstraints = false
        lineValue.centerYAnchor.constraint(equalTo: lineChart.centerYAnchor).isActive = true
        lineValue.centerXAnchor.constraint(equalTo: lineChart.centerXAnchor).isActive = true
        lineValue.isHidden = true
        
        pointValue.translatesAutoresizingMaskIntoConstraints = false
        pointValue.centerYAnchor.constraint(equalTo: pointChart.centerYAnchor).isActive = true
        pointValue.centerXAnchor.constraint(equalTo: pointChart.centerXAnchor).isActive = true
        pointValue.isHidden = true
        let tapGR = UILongPressGestureRecognizer(target: self, action: #selector(longPressLine))
        lineChart.addGestureRecognizer(tapGR)
        let tapPoint = UILongPressGestureRecognizer(target: self, action: #selector(longPressPoint))
        pointChart.addGestureRecognizer(tapPoint)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var colors = [UIColor].init(repeating: .white, count: 30)
        colors = colors.map({_ in
            UIColor.init(red: CGFloat(Float.random(in: 0...1)), green: CGFloat(Float.random(in: 0...1)), blue: CGFloat(Float.random(in: 0...1)), alpha: 1)
        })
        let linedataEntries = BarEntry.generateDataEntries(color: colors,size: 90)
        let pointDataEntries = BarEntry.generateDataEntries(color: colors,size: 90)
        lineChart.dataEntries = linedataEntries
        lineChart.backgroundColor = .systemBackground
        pointChart.dataEntries = pointDataEntries
        pointChart.backgroundColor = .systemBackground
        
    }
    
    
    
    @objc func longPressLine(gr:UILongPressGestureRecognizer) {
        let loc:CGPoint = gr.location(in: gr.view)
        //insert your touch based code here
        lineValue.text = lineChart.drawVerticalLine(xPos : loc.x)
        
        if(gr.state == UIGestureRecognizer.State.ended){
            lineChart.removeVerticalLine()
            lineValue.isHidden = true
        } else if gr.state == .began {
            lineValue.isHidden = false
        }
    }
    
    @objc func longPressPoint(gr:UILongPressGestureRecognizer) {
        let loc:CGPoint = gr.location(in: gr.view)
        
        pointValue.text = pointChart.drawVerticalLine(xPos : loc.x)
        
        if(gr.state == UIGestureRecognizer.State.ended){
            pointChart.removeVerticalLine()
            pointValue.isHidden = true
        } else if gr.state == .began {
            pointValue.isHidden = false
        }
    }
    
}
