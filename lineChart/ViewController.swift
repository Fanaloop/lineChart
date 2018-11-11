//
//  ViewController.swift
//  lineChart
//
//  Created by Robert Crowther on 10/11/2018.
//  Copyright © 2018 Robert Crowther. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lineChart: LineChart!

    var points: [CGPoint]?
    var deviationPoints: [CGPoint]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        points = [CGPoint]()
        deviationPoints = [CGPoint]()
        
        points = [
            
            CGPoint(x: 0, y: 50.0),CGPoint(x: 1, y: 40.0),CGPoint(x: 2, y: 43.0),CGPoint(x: 3, y: 42.0),
            CGPoint(x: 4, y: 41.0),CGPoint(x: 5, y: 39.0),CGPoint(x: 6, y: 34.0),CGPoint(x: 7, y: 39.0),
            CGPoint(x: 8, y: 42.0),CGPoint(x: 9, y: 43.0),CGPoint(x: 10, y: 44.0),CGPoint(x: 11, y: 45.0),
            CGPoint(x: 12, y: 46.0),CGPoint(x: 13, y: 39.0),CGPoint(x: 14, y: 38.0),CGPoint(x: 15, y: 44.0),
            CGPoint(x: 16, y: 43.0),CGPoint(x: 17, y: 42.0),CGPoint(x: 18, y: 41.0),CGPoint(x: 19, y: 39.0),
            CGPoint(x: 20, y: 38.0),CGPoint(x: 21, y: 40.0),CGPoint(x: 22, y: 43.0),CGPoint(x: 23, y: 45.0),
            CGPoint(x: 24, y: 39.0),CGPoint(x: 25, y: 34.0),CGPoint(x: 26, y: 34.0),CGPoint(x: 27, y: 23.0),
            CGPoint(x: 28, y: 22.0),CGPoint(x: 29, y: 20.0)
            
        ]
        
        deviationPoints = [
        
            CGPoint(x: 0, y: 1),CGPoint(x: 1, y: 2),CGPoint(x: 2, y: 0),CGPoint(x: 3, y: 4),CGPoint(x: 4, y: 5),
            CGPoint(x: 5, y: 6),CGPoint(x: 6, y: 2),CGPoint(x: 7, y: -1),CGPoint(x: 8, y: -3),CGPoint(x: 9, y: -4),
            CGPoint(x: 10, y: -2),CGPoint(x: 11, y: 3),CGPoint(x: 12, y: 4),CGPoint(x: 13, y: 2),CGPoint(x: 14, y: -1),
            CGPoint(x: 15, y: 0),CGPoint(x: 16, y: 1),CGPoint(x: 17, y: 3),CGPoint(x: 18, y: 4),CGPoint(x: 19, y: 2),
            CGPoint(x: 20, y: -1),CGPoint(x: 21, y: -2),CGPoint(x: 22, y: -4),CGPoint(x: 23, y: -2),CGPoint(x: 24, y: -1),
            CGPoint(x: 25, y: -4),CGPoint(x: 26, y: 2),CGPoint(x: 27, y: 2),CGPoint(x: 28, y: 1),CGPoint(x: 29, y: 1)
            
        ]
        
        if let points = points, let deviationPoints = deviationPoints {
            lineChart.plot(points, deviationPoints: deviationPoints)
        }
    }
    
}

