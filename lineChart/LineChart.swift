//
//  LineChart.swift
//  lineChart
//
//  Created by Robert Crowther on 10/11/2018.
//  Copyright © 2018 Robert Crowther. All rights reserved.
//

import UIKit

class LineChart: UIView {
    
    let lineLayer = CAShapeLayer()
    let deviationLineLayer = CAShapeLayer()
    let circlesLayer = CAShapeLayer()
    var widthOfLineChart: CGFloat?
    var heightOfLineChart: CGFloat?
    var chartTransform: CGAffineTransform?
    var unitWidthForGesture: CGFloat?
    
    var drawingContext: CGContext?
    
    @IBInspectable var lineWidth: CGFloat = 2.0
    
    @IBInspectable var lineColor: UIColor = UIColor.green {
        didSet {
            lineLayer.strokeColor = lineColor.cgColor
        }
    }
    
    @IBInspectable var deviationLineColor: UIColor = UIColor.blue {
        didSet {
            deviationLineLayer.strokeColor = deviationLineColor.cgColor
        }
    }
    
    @IBInspectable var showPoints: Bool = true {
        didSet {
            circlesLayer.isHidden = !showPoints
        }
    }
    
    @IBInspectable var circleColor: UIColor = UIColor.green {
        didSet {
            circlesLayer.fillColor = circleColor.cgColor
        }
    }
    
    @IBInspectable var circleSizeMultiplier: CGFloat = 3
    @IBInspectable var axisColor: UIColor = UIColor.white
    @IBInspectable var showInnerLines: Bool = true
    @IBInspectable var labelFontSize: CGFloat = 12
    
    var axisLineWidth: CGFloat = 1
    var deltaX: CGFloat = 1
    var deltaY: CGFloat = 10
    var xMax: CGFloat = 100
    var yMax: CGFloat = 100
    var xMin: CGFloat = 0
    var yMin: CGFloat = 0
    
    var data: [CGPoint]?
    var deviationData: [CGPoint]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        layer.addSublayer(lineLayer)
        layer.addSublayer(deviationLineLayer)
        
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = lineColor.cgColor
        
        deviationLineLayer.fillColor = UIColor.clear.cgColor
        deviationLineLayer.strokeColor = deviationLineColor.cgColor
        
        layer.addSublayer(circlesLayer)
        circlesLayer.fillColor = circleColor.cgColor
        
        layer.borderWidth = 1
        layer.borderColor = axisColor.cgColor
        
        setUpGestureRecognizer()
        setUpSubViews()
    }
    
    let deviationLabel: UILabel = {
        let label = UILabel()
        label.text = "Dev."
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let yLabel: UILabel = {
        let label = UILabel()
        label.text = "Y"
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let deviationOutput: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textAlignment = .center
        label.textColor = .blue
        label.layer.cornerRadius = 4.0
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.blue.cgColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let yOutput: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textAlignment = .center
        label.textColor = .orange
        label.layer.cornerRadius = 4.0
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.orange.cgColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let chartOutputView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 4.0
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setUpSubViews() {
        
        // add parent container and constraints
        addSubview(chartOutputView)
        chartOutputView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        chartOutputView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        let widthConstraint = NSLayoutConstraint(item: chartOutputView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 250)
        let heightConstraint = NSLayoutConstraint(item: chartOutputView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50)
        chartOutputView.addConstraints([widthConstraint, heightConstraint])
        
        // add deviation label to parent and add constraints
        chartOutputView.addSubview(deviationOutput)
        
        let deviationLabelWidthConstraint = NSLayoutConstraint(item: deviationOutput, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50)
        
        deviationOutput.addConstraints([deviationLabelWidthConstraint])
        
        let leftDeviationConstraint:NSLayoutConstraint = NSLayoutConstraint(item: deviationOutput, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: chartOutputView, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 20)
        deviationOutput.centerYAnchor.constraint(equalTo: chartOutputView.centerYAnchor, constant: 10).isActive = true
        
        chartOutputView.addConstraints([leftDeviationConstraint])
        
        // add Y label to parent and add constraints
        chartOutputView.addSubview(yOutput)
        
        let yLabelWidthConstraint = NSLayoutConstraint(item: yOutput, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 70)
        
        yOutput.addConstraints([yLabelWidthConstraint])
        
        let rightYConstraint:NSLayoutConstraint = NSLayoutConstraint(item: yOutput, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: chartOutputView, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: -20)
        yOutput.centerYAnchor.constraint(equalTo: chartOutputView.centerYAnchor, constant: 10).isActive = true
        
        chartOutputView.addConstraints([rightYConstraint])
        
        // add deviationa and Y labels and add constraints
        chartOutputView.addSubview(deviationLabel)
        
        let leftDeviationLabelConstraint:NSLayoutConstraint = NSLayoutConstraint(item: deviationLabel, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: chartOutputView, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 28)
        
        chartOutputView.addConstraints([leftDeviationLabelConstraint])
        
        chartOutputView.addSubview(yLabel)
        
        let rightDeviationLabelConstraint:NSLayoutConstraint = NSLayoutConstraint(item: yLabel, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: chartOutputView, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: -50)
        
        chartOutputView.addConstraints([rightDeviationLabelConstraint])
        
        layoutIfNeeded()
    }
    
    func setUpGestureRecognizer() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(LineChart.handlePan))
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        widthOfLineChart = self.frame.width + 20.0
        
        if let data = data, let widthOfLineChart = widthOfLineChart {
            
            let numberOfTimeIntervals: CGFloat = CGFloat(data.count)
            
            unitWidthForGesture = widthOfLineChart / numberOfTimeIntervals
            
        }
        
        lineLayer.frame = self.bounds
        
        deviationLineLayer.frame = self.bounds
        
        circlesLayer.frame = self.bounds
        
        // unwrap the data
        if let data = data, let deviationData = deviationData {
            setTransform(minX: xMin, maxX: xMax, minY: yMin, maxY: yMax)
            plot(data, deviationPoints: deviationData)
        }
    }
    
    func setAxisRange(forPoints points: [CGPoint]) {
        guard !points.isEmpty else { return }
        
        let xs = points.map() { $0.x }
        let ys = points.map() { $0.y }
        
        xMax = ceil(xs.max()! / deltaX) * deltaX
        yMax = ceil(ys.max()! / deltaY) * deltaY
        
        xMin = 0
        yMin = 0
        setTransform(minX: xMin, maxX: xMax, minY: yMin, maxY: yMax)
    }
    
    func setAxisRange(xMin: CGFloat, xMax: CGFloat, yMin: CGFloat, yMax: CGFloat) {
        self.xMin = xMin
        self.xMax = xMax
        self.yMin = yMin
        self.yMax = yMax
        
        setTransform(minX: xMin, maxX: xMax, minY: yMin, maxY: yMax)
    }
    
    func setTransform(minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) {
        
        let xLabelSize = "\(Int(maxX))".size(withSystemFontSize: labelFontSize)
        
        let yLabelSize = "\(Int(maxY))".size(withSystemFontSize: labelFontSize)
        
        let xOffset = xLabelSize.height + 100 // TODO: Make this a function of y min value
        let yOffset = yLabelSize.width + 5
        
        let xScale = (bounds.width - yOffset - xLabelSize.width/2 - 2)/(maxX - minX)
        let yScale = (bounds.height - xOffset - yLabelSize.height/2 - 2)/(maxY - minY)
        
        chartTransform = CGAffineTransform(a: xScale, b: 0, c: 0, d: -yScale, tx: yOffset, ty: bounds.height - xOffset)
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        drawingContext = UIGraphicsGetCurrentContext()
        guard let context = drawingContext, let chartTransform = chartTransform else { return }
        drawAxes(in: context, usingTransform: chartTransform)
    }
    
    func drawAxes(in context: CGContext, usingTransform transform: CGAffineTransform) {
        context.saveGState()
        
        // make two paths, one for thick lines, one for thin
        let thickerLines = CGMutablePath()
        let thinnerLines = CGMutablePath()
        
        // the two line chart axes
        let xAxisPoints = [CGPoint(x: xMin, y: 0), CGPoint(x: xMax, y: 0)]
        let yAxisPoints = [CGPoint(x: 0, y: -10), CGPoint(x: 0, y: yMax)]
        
        thickerLines.addLines(between: xAxisPoints, transform: transform)
        thickerLines.addLines(between: yAxisPoints, transform: transform)
        
        for x in stride(from: xMin, through: xMax, by: deltaX) {
            
            if x != xMin {
                let label = "\(Int(x))" as NSString
                let labelSize = "\(Int(x))".size(withSystemFontSize: labelFontSize)
                let labelDrawPoint = CGPoint(x: x, y: 0).applying(transform)
                    .adding(x: -labelSize.width/2)
                    .adding(y: 1)
                
                label.draw(at: labelDrawPoint,
                           withAttributes:
                    [NSAttributedString.Key.font: UIFont.systemFont(ofSize: labelFontSize),
                     NSAttributedString.Key.foregroundColor: axisColor])
            }
        }
        
        // TODO: make this -10 value a function of min Y from deviation data
        for y in stride(from: -10, through: yMax, by: deltaY) {
            
            let tickPoints = showInnerLines ?
                [CGPoint(x: xMin, y: y).applying(transform), CGPoint(x: xMax, y: y).applying(transform)] :
                [CGPoint(x: 0, y: y).applying(transform), CGPoint(x: 0, y: y).applying(transform).adding(x: 5)]
            
            
            thinnerLines.addLines(between: tickPoints)
            
            //if y != yMin {
            let label = "\(Int(y))" as NSString
            let labelSize = "\(Int(y))".size(withSystemFontSize: labelFontSize)
            let labelDrawPoint = CGPoint(x: 0, y: y).applying(transform)
                .adding(x: -labelSize.width - 1)
                .adding(y: -labelSize.height/2)
            
            label.draw(at: labelDrawPoint,
                       withAttributes:
                [NSAttributedString.Key.font: UIFont.systemFont(ofSize: labelFontSize),
                 NSAttributedString.Key.foregroundColor: axisColor])
            //}
        }
        // finally set stroke color & line width then stroke thick lines, repeat for thin
        context.setStrokeColor(axisColor.cgColor)
        context.setLineWidth(axisLineWidth)
        context.addPath(thickerLines)
        context.strokePath()
        
        context.setStrokeColor(axisColor.withAlphaComponent(0.5).cgColor)
        context.setLineWidth(axisLineWidth/2)
        context.addPath(thinnerLines)
        context.strokePath()
        
        context.restoreGState()
    }
    
    func plot(_ points: [CGPoint], deviationPoints: [CGPoint]) {
        lineLayer.path = nil
        circlesLayer.path = nil
        data = nil
        deviationData = nil
        
        guard !points.isEmpty else { return }
        guard !deviationPoints.isEmpty else { return }
        
        self.data = points
        self.deviationData = deviationPoints
        
        if self.chartTransform == nil {
            // TODO: get axis range as combination of both sets of data
            //setAxisRange(forPoints: points)
            setAxisRange(xMin: 0, xMax: 29 , yMin: 0, yMax: 60)
        }
        
        let linePath = CGMutablePath()
        linePath.addLines(between: points, transform: chartTransform!)
        
        lineLayer.path = linePath
        lineLayer.lineWidth = self.lineWidth
        
        let deviationLinePath = CGMutablePath()
        deviationLinePath.addLines(between: deviationPoints, transform: chartTransform!)
        
        deviationLineLayer.path = deviationLinePath
        deviationLineLayer.lineWidth = self.lineWidth
        
        if showPoints {
            circlesLayer.path = circles(atPoints: points, withTransform: chartTransform!)
        }
    }
    
    func circles(atPoints points: [CGPoint], withTransform t: CGAffineTransform) -> CGPath {
        
        let path = CGMutablePath()
        let radius = lineLayer.lineWidth * circleSizeMultiplier/2
        for i in points {
            let p = i.applying(t)
            let rect = CGRect(x: p.x - radius, y: p.y - radius, width: radius * 2, height: radius * 2)
            path.addEllipse(in: rect)
            
        }
        
        return path
    }
    
    @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began {
            // TODO
        }
        
        if gestureRecognizer.state == .changed {
            
            let pointer = gestureRecognizer.location(in: self)
            
            if pointer.x > 10.0 {
                
                if let unitWidthForGesture = unitWidthForGesture {
                    
                    let timeIncrement:CGFloat = round(pointer.x / unitWidthForGesture)
                    
                    if let points = self.data {
                        
                        if let i = points.firstIndex(where: { $0.x == timeIncrement }) {
                            yOutput.text = "\(points[i].y)"
                        }
                        
                    }
                    
                    if let deviationPoints = self.deviationData {
                        
                        if let i = deviationPoints.firstIndex(where: { $0.x == timeIncrement }) {
                            deviationOutput.text = "\(deviationPoints[i].y)"
                        }
                        
                    }
                    
                }
                
            }
            
        }
    }
    
}
