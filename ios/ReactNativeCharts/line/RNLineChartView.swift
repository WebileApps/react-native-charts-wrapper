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
}

