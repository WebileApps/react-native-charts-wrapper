//  Created by xudong wu on 24/02/2017.
//  Copyright wuxudong
//

import Charts
import SwiftyJSON

class RNLineChartView: RNBarLineChartViewBase {
    let _chart: LineChartView;
    let _dataExtract : LineDataExtract;
    
    override var chart: LineChartView {
        return _chart
    }
    
    override var dataExtract: DataExtract {
        return _dataExtract
    }
    
    override init(frame: CoreGraphics.CGRect) {
        
        self._chart = LineChartOnlyHighlightDrag(frame: frame)
        self._dataExtract = LineDataExtract()
        
        super.init(frame: frame);
        
        self._chart.delegate = self
        self._chart.xAxisRenderer = NotchXAxisRenderer(viewPortHandler: self._chart.viewPortHandler, xAxis: self._chart.xAxis, transformer: self._chart.getTransformer(forAxis: YAxis.AxisDependency.left));
        self.addSubview(_chart);
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        super.chartValueSelected(chartView, entry: entry, highlight: highlight);
        let count = chartView.data?.dataSetCount ?? 0;
        var highlights = [Highlight]()
        for i in stride(from: 0, to: count, by: 1) {
            let y = chartView.data?.getDataSetByIndex(i)?.entryForXValue(entry.x, closestToY: 0)?.y ?? 0;
            highlights.append(Highlight(x: entry.x, y: y, dataSetIndex: i))
        }
        chartView.highlightValues(highlights);
    }
    
    override func chartValueNothingSelected(_ chartView: ChartViewBase) {
        super.chartValueNothingSelected(chartView);
        chartView.highlightValues([]);
    }
}

class LineChartOnlyHighlightDrag: LineChartView
{
    open override var isFullyZoomedOut: Bool {
        return true;
    }
    
    open override var hasNoDragOffset: Bool {
        return true;
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect);
        let optionalContext = UIGraphicsGetCurrentContext()
        guard let context = optionalContext else { return }
        drawMarkers(context: context);
        drawHightedValueAtTop(context: context);
    }
    
    override var isDrawMarkersEnabled: Bool { return false; }
    
    internal func drawMarkers(context: CGContext)
    {
        // if there is no marker view or drawing marker is disabled
        guard
            let marker = marker
            ,valuesToHighlight()
            else { return }
        
        var offsetY = CGFloat(0.0);
        let sortedHighlights = highlighted.sorted { (h1, h2) -> Bool in
            getMarkerPosition(highlight: h1).y < getMarkerPosition(highlight: h2).y
        }
        for i in 0 ..< sortedHighlights.count
        {
            let highlight = sortedHighlights[i]
            
            guard let
                set = data?.getDataSetByIndex(highlight.dataSetIndex),
                let e = data?.entryForHighlight(highlight)
                else { continue }
            
            let entryIndex = set.entryIndex(entry: e)
            if entryIndex > Int(Double(set.entryCount) * chartAnimator.phaseX)
            {
                continue
            }

            var pos = getMarkerPosition(highlight: highlight)
            pos = CGPoint(x: pos.x, y: max(pos.y, CGFloat(offsetY + 10.0)));
            offsetY = CGFloat(pos.y);
            // check bounds
            if !viewPortHandler.isInBounds(x: pos.x, y: pos.y)
            {
                continue
            }

            // callbacks to update the content
            marker.refreshContent(entry: e, highlight: highlight)
            
            // draw the marker
            marker.draw(context: context, point: pos)
        }
    }
    
    internal func drawHightedValueAtTop(context : CGContext) {
        if (!valuesToHighlight()) {
            return;
        }
        let entry = data?.entryForHighlight(highlighted[0]);
        let pos = getMarkerPosition(highlight: highlighted[0]);
        if ((entry) == nil || !viewPortHandler.isInBounds(x: pos.x, y: pos.y)) { return }
        
        let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paraStyle.alignment = .center
        let labelAttrs: [NSAttributedString.Key : Any] = [
        .font: xAxis.labelFont,
        .foregroundColor: xAxis.labelTextColor,
        .paragraphStyle: paraStyle];
        
        let label = xAxis.valueFormatter?.stringForValue(entry?.x ?? 0, axis: xAxis) ?? "";
        
        let labelns = label as NSString
        context.saveGState();
        let labelSize = labelns.size(withAttributes: labelAttrs) ;
        let rect = CGRect(x: min(viewPortHandler.contentRight - labelSize.width - 5, pos.x - labelSize.width / 2), y: viewPortHandler.contentTop, width: labelSize.width , height: labelSize.height );
        context.addRect(rect.insetBy(dx: -6, dy: -2));
        context.setLineWidth(0.5);
        context.setStrokeColor(UIColor.white.cgColor);
        context.setFillColor(UIColor.black.cgColor);
        context.drawPath(using: CGPathDrawingMode.fillStroke);
        labelns.draw(in: rect, withAttributes: labelAttrs);
        context.restoreGState();
    }
}

class NotchXAxisRenderer : XAxisRenderer {
    override func drawLabel(context: CGContext, formattedLabel: String, x: CGFloat, y: CGFloat, attributes: [NSAttributedString.Key : Any], constrainedToSize: CGSize, anchor: CGPoint, angleRadians: CGFloat) {
        
        guard
            let xAxis = self.axis as? XAxis
            else { return }
        
        let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paraStyle.alignment = .center
        
        let labelAttrs: [NSAttributedString.Key : Any] = [
            .font: xAxis.labelFont,
            .foregroundColor: xAxis.labelTextColor,
            .paragraphStyle: paraStyle
        ]
        let labelNS = formattedLabel as NSString;
        let width = labelNS.size(withAttributes: labelAttrs).width;
        let offsetX = min(x, viewPortHandler.contentRight + 10 - width/2);
        
        super.drawLabel(context: context, formattedLabel: formattedLabel, x: offsetX, y: y, attributes: attributes, constrainedToSize: constrainedToSize, anchor: anchor, angleRadians: angleRadians);
        
        context.saveGState();
        context.move(to: CGPoint(x: x, y: y - 8));
        context.addLine(to: CGPoint(x: x, y: y));
        context.setStrokeColor(self.axis?.axisLineColor.cgColor ?? UIColor.gray.cgColor);
        context.setLineWidth(2 * (self.axis?.axisLineWidth ?? 0.5));
        context.drawPath(using: CGPathDrawingMode.stroke);
        context.restoreGState();
    }
}

