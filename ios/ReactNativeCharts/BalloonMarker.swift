//
//  BalloonMarker.swift
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 19/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//  https://github.com/danielgindi/Charts/blob/1788e53f22eb3de79eb4f08574d8ea4b54b5e417/ChartsDemo/Classes/Components/BalloonMarker.swift
//  Edit: Added textColor

import Foundation;

import Charts;

import SwiftyJSON;

open class BalloonMarker: MarkerView {
    open var color: UIColor?
    open var arrowSize = CGSize(width: 15, height: 11)
    open var font: UIFont?
    open var textColor: UIColor?
    open var minimumSize = CGSize()

    
    fileprivate var insets = UIEdgeInsets(top: 8.0,left: 8.0,bottom: 20.0,right: 8.0)
    fileprivate var topInsets = UIEdgeInsets(top: 20.0,left: 8.0,bottom: 8.0,right: 8.0)
    
    fileprivate var labelns: NSString?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _size: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [NSAttributedString.Key: Any]()
    fileprivate var _highlightColor : UIColor = UIColor.init(red: 1, green: 96/255, blue: 0, alpha: 1)

    public init(color: UIColor, font: UIFont, textColor: UIColor) {
        super.init(frame: CGRect.zero);
        self.color = color
        self.font = font
        self.textColor = textColor

        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }


    func drawRect(context: CGContext, point: CGPoint) -> CGRect{

        let chart = super.chartView

        let width = _size.width


        var rect = CGRect(origin: point, size: _size)
        
        if point.y - _size.height < 0 {
          
            if point.x - _size.width / 2.0 < 0 {
                drawTopLeftRect(context: context, rect: rect)
            } else if (chart != nil && point.x + width - _size.width / 2.0 > (chart?.bounds.width)!) {
                rect.origin.x -= _size.width
                drawTopRightRect(context: context, rect: rect)
            } else {
                rect.origin.x -= _size.width / 2.0
                drawTopCenterRect(context: context, rect: rect)
            }
            
            rect.origin.y += self.topInsets.top
            rect.size.height -= self.topInsets.top + self.topInsets.bottom

        } else {
            
            rect.origin.y -= _size.height / 2;
            
            if point.x < 0 {
                drawLeftRect(context: context, rect: rect)
            } else if (chart != nil && point.x + width > (chart?.bounds.width)!) {
                rect.origin.x -= _size.width
                drawRightRect(context: context, rect: rect)
            } else {
                drawCenterRect(context: context, rect: rect)
            }
            
            rect.origin.y += self.insets.top
            rect.size.height -= self.insets.top + self.insets.bottom

        }
        
        return rect
    }

    func drawCenterRect(context: CGContext, rect: CGRect) {

        context.setFillColor((color?.cgColor)!)
        context.beginPath()
        context.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0, y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width / 2.0, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0, y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context.fillPath()

    }

    func drawLeftRect(context: CGContext, rect: CGRect) {
        context.setFillColor((color?.cgColor)!)
        context.beginPath()
        context.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + arrowSize.width / 2.0, y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context.fillPath()

    }

    func drawRightRect(context: CGContext, rect: CGRect) {
        context.setFillColor((color?.cgColor)!)
        context.beginPath()
        context.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x  + rect.size.width - arrowSize.width / 2.0, y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context.fillPath()

    }
    
    func drawTopCenterRect(context: CGContext, rect: CGRect) {
        
        context.setFillColor((color?.cgColor)!)
        context.beginPath()
        context.move(to: CGPoint(x: rect.origin.x + rect.size.width / 2.0, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0, y: rect.origin.y + arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0, y: rect.origin.y + arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width / 2.0, y: rect.origin.y))
        context.fillPath()
        
    }

    func drawTopLeftRect(context: CGContext, rect: CGRect) {
        context.setFillColor((color?.cgColor)!)
        context.beginPath()
        context.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + arrowSize.width / 2.0, y: rect.origin.y + arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context.fillPath()

    }

    func drawTopRightRect(context: CGContext, rect: CGRect) {
        context.setFillColor((color?.cgColor)!)
        context.beginPath()
        context.move(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width - arrowSize.height / 2.0, y: rect.origin.y + arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
        context.fillPath()

    }



    open override func draw(context: CGContext, point: CGPoint) {
        if (labelns == nil || labelns?.length == 0) {
            return
        }

        context.saveGState()

        let rect = drawRect(context: context, point: point)

        UIGraphicsPushContext(context)

        labelns?.draw(in: rect, withAttributes: _drawAttributes)

        UIGraphicsPopContext()

        drawCircle(context: context, center: point, radius: 10, color: UIColor.white)
        drawCircle(context: context, center: point, radius: 5, color: _highlightColor)
        context.restoreGState()
    }
    
    private func drawCircle(context: CGContext, center: CGPoint, radius: CGFloat, color: UIColor) {
        UIGraphicsPushContext(context)
        context.setFillColor(color.cgColor)
        context.addEllipse(in: CGRect.init(origin: center, size: CGSize.init(width: radius, height: radius)).offsetBy(dx: -radius/2, dy: -radius/2))
        context.fillPath()
        UIGraphicsPopContext()
    }

    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {

        var label : String;

        if let candleEntry = entry as? CandleChartDataEntry {

            label = candleEntry.close.description
        } else {
            label = entry.y.description
        }
        
        if (highlight.dataSetIndex == 0) {
            _highlightColor = UIColor.init(red: 12/255, green: 97/255, blue: 114/255, alpha: 1.0);
        } else if (highlight.dataSetIndex == 1) {
            _highlightColor = UIColor.init(red: 57/255, green: 109/255, blue: 58/255, alpha: 1.0);
        } else if (highlight.dataSetIndex == 2) {
            _highlightColor = UIColor.init(red: 120/255, green: 40/255, blue: 44/255, alpha: 1.0);
        } else {
            _highlightColor = UIColor.init(red: 1, green: 96/255, blue: 0, alpha: 1.0);
        }

        if let object = entry.data as? JSON {
            if object["marker"].exists() {
                label = object["marker"].stringValue;
              
                if highlight.stackIndex != -1 && object["marker"].array != nil {
                    label = object["marker"].arrayValue[highlight.stackIndex].stringValue
                }
            }
        }

        labelns = label as NSString

        _drawAttributes.removeAll()
        _drawAttributes[NSAttributedString.Key.font] = self.font
        _drawAttributes[NSAttributedString.Key.paragraphStyle] = _paragraphStyle
        _drawAttributes[NSAttributedString.Key.foregroundColor] = self.textColor

        _labelSize = labelns?.size(withAttributes: _drawAttributes) ?? CGSize.zero
        _size.width = _labelSize.width + self.insets.left + self.insets.right
        _size.height = _labelSize.height + self.insets.top + self.insets.bottom
        _size.width = max(minimumSize.width, _size.width)
        _size.height = max(minimumSize.height, _size.height)

    }
}

