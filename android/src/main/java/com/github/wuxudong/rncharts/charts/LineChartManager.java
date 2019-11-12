package com.github.wuxudong.rncharts.charts;


import com.facebook.react.uimanager.ThemedReactContext;
import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.highlight.Highlight;
import com.github.mikephil.charting.utils.ViewPortHandler;
import com.github.wuxudong.rncharts.data.DataExtract;
import com.github.wuxudong.rncharts.data.LineDataExtract;
import com.github.wuxudong.rncharts.listener.RNOnChartValueSelectedListener;
import com.github.wuxudong.rncharts.listener.RNOnChartGestureListener;

public class LineChartManager extends BarLineChartBaseManager<LineChart, Entry> {

    @Override
    public String getName() {
        return "RNLineChart";
    }

    @Override
    protected LineChart createViewInstance(ThemedReactContext reactContext) {
        final LineChart lineChart =  new LineChart(reactContext) {
            @Override
            protected void init() {

                this.mViewPortHandler = new ViewPortHandler() {
                    @Override
                    public boolean isFullyZoomedOut() {
                        return true;
                    }

                    @Override
                    public boolean hasNoDragOffset() {
                        return true;
                    }
                };

                super.init();
            }
        };
        lineChart.setOnChartValueSelectedListener(new RNOnChartValueSelectedListener(lineChart) {
            @Override
            public void onValueSelected(Entry entry, Highlight h) {
                super.onValueSelected(entry, h);
                LineData data = lineChart.getData();
                Highlight[] highs = new Highlight[data.getDataSetCount()];
                for (int i= 0; i< data.getDataSetCount(); i++) {
                    highs[i] = new Highlight(entry.getX(), data.getDataSetByIndex(i).getEntryForXValue(entry.getX(), 0).getY(), i);
                }
                lineChart.highlightValues(highs);
            }

            @Override
            public void onNothingSelected() {
                super.onNothingSelected();
                lineChart.highlightValues(new Highlight[]{});
            }
        });
        lineChart.setOnChartGestureListener(new RNOnChartGestureListener(lineChart));
        return lineChart;
    }

    @Override
    DataExtract getDataExtract() {
        return new LineDataExtract();
    }
}
