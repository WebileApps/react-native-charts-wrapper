package com.github.wuxudong.rncharts.charts;


import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.view.MotionEvent;

import com.facebook.react.uimanager.ThemedReactContext;
import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.highlight.Highlight;
import com.github.mikephil.charting.interfaces.datasets.IDataSet;
import com.github.mikephil.charting.interfaces.datasets.ILineScatterCandleRadarDataSet;
import com.github.mikephil.charting.listener.BarLineChartTouchListener;
import com.github.mikephil.charting.renderer.LineChartRenderer;
import com.github.mikephil.charting.renderer.XAxisRenderer;
import com.github.mikephil.charting.utils.MPPointF;
import com.github.mikephil.charting.utils.Utils;
import com.github.mikephil.charting.utils.ViewPortHandler;
import com.github.wuxudong.rncharts.data.DataExtract;
import com.github.wuxudong.rncharts.data.LineDataExtract;
import com.github.wuxudong.rncharts.listener.RNOnChartValueSelectedListener;
import com.github.wuxudong.rncharts.listener.RNOnChartGestureListener;

import java.util.Arrays;
import java.util.Comparator;

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

                this.setOnTouchListener(new BarLineChartTouchListener(this, mViewPortHandler.getMatrixTouch(), 3f){
                    @Override
                    protected void performHighlight(Highlight h, MotionEvent e) {

                        if (mViewPortHandler.isInBounds(e.getX(), e.getY())) {
                            if (!h.equalTo(mLastHighlighted)) {
                                super.performHighlight(h, e);
                            }
                        }
                    }
                });

                this.setXAxisRenderer( new XAxisRenderer(this.mViewPortHandler, this.mXAxis, this.mLeftAxisTransformer) {
                    /**
                     * Customized to draw notch above the label.
                     * @param c
                     * @param formattedLabel
                     * @param x
                     * @param y
                     * @param anchor
                     * @param angleDegrees
                     */
                    @Override
                    protected void drawLabel(Canvas c, String formattedLabel, float x, float y, MPPointF anchor, float angleDegrees) {
                        int textWidth = Utils.calcTextWidth(this.getPaintAxisLabels(), formattedLabel);
                        float offsetX = Math.min(this.mViewPortHandler.contentRight() + Utils.convertDpToPixel(10) - textWidth / 2 , x );
                        super.drawLabel(c, formattedLabel, offsetX, y, anchor, angleDegrees);
                        c.save();
                        float width = mXAxisRenderer.getPaintAxisLine().getStrokeWidth();
                        mXAxisRenderer.getPaintAxisLine().setStrokeWidth(2 * width);
                        c.drawLine(x, y- Utils.convertDpToPixel(8), x, y, mXAxisRenderer.getPaintAxisLine());
                        mXAxisRenderer.getPaintAxisLine().setStrokeWidth(width);
                        c.restore();
                    }
                });

                mRenderer = new LineChartRenderer(this, mAnimator, mViewPortHandler) {

                    Paint mHightlightLabelPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
                    /**
                     * Customized to draw the current highlighted value at the top of graph.
                     * @param c
                     * @param x
                     * @param y
                     * @param set
                     */
                    @Override
                    protected void drawHighlightLines(Canvas c, float x, float y, ILineScatterCandleRadarDataSet set) {
                        super.drawHighlightLines(c, x, y, set);
                        if (mIndicesToHighlight.length == 0) {
                            return;
                        }

                        Entry e = mData.getEntryForHighlight(mIndicesToHighlight[0]);
                        float[] pos = getMarkerPosition(mIndicesToHighlight[0]);
                        if (!this.mViewPortHandler.isInBounds(pos[0], pos[1])) {
                            return;
                        }

                        mHightlightLabelPaint.setStrokeWidth(Utils.convertDpToPixel(0.5f));
                        String formattedLabel = mXAxis.getValueFormatter().getAxisLabel(e.getX(), mXAxis);
                        float width = Utils.calcTextWidth(mXAxisRenderer.getPaintAxisLabels(), formattedLabel) + Utils.convertDpToPixel(10);

                        c.save();
                        float originX = Math.min(mViewPortHandler.contentRight() - width, Math.max(x - width/2, mViewPortHandler.contentLeft()));

                        mHightlightLabelPaint.setColor(Color.BLACK);
                        mHightlightLabelPaint.setStyle(Paint.Style.FILL);
                        c.drawRect(new RectF(originX, mViewPortHandler.contentTop(), originX + width, mViewPortHandler.contentTop() + Utils.convertDpToPixel(15)),mHightlightLabelPaint);

                        mHightlightLabelPaint.setStyle(Paint.Style.STROKE);
                        mHightlightLabelPaint.setColor(Color.WHITE);
                        c.drawRect(new RectF(originX, mViewPortHandler.contentTop()+1, originX + width, mViewPortHandler.contentTop() + Utils.convertDpToPixel(15)),mHightlightLabelPaint);

                        Utils.drawXAxisValue(c, formattedLabel, originX + Utils.convertDpToPixel(5), mViewPortHandler.contentTop() + Utils.convertDpToPixel(2), mXAxisRenderer.getPaintAxisLabels(), MPPointF.getInstance(0,0), 0);
                        c.restore();
                    }
                };
            }

            /**
             * Customized so that the markers don't overlap on one another.
             * @param canvas
             */
            @Override
            protected void drawMarkers(Canvas canvas) {

                // if there is no marker view or drawing marker is disabled
                if (mMarker == null || !isDrawMarkersEnabled() || !valuesToHighlight())
                    return;

                Highlight[] sortedIndices = mIndicesToHighlight.clone();
                Arrays.sort(sortedIndices, new Comparator<Highlight>() {
                    @Override
                    public int compare(Highlight o1, Highlight o2) {
                        float[] pos1 = getMarkerPosition(o1);
                        float[] pos2 = getMarkerPosition(o2);
                        return (int)(pos1[1] - pos2[1]);
                    }
                });
                float offsetY = 0;
                for (int i = 0; i < sortedIndices.length; i++) {

                    Highlight highlight = sortedIndices[i];

                    IDataSet set = mData.getDataSetByIndex(highlight.getDataSetIndex());

                    Entry e = mData.getEntryForHighlight(sortedIndices[i]);
                    int entryIndex = set.getEntryIndex(e);

                    // make sure entry not null
                    if (e == null || entryIndex > set.getEntryCount() * mAnimator.getPhaseX())
                        continue;

                    float[] pos = getMarkerPosition(highlight);

                    // check bounds
                    if (!mViewPortHandler.isInBounds(pos[0], pos[1]))
                        continue;

                    // callbacks to update the content
                    mMarker.refreshContent(e, highlight);

                    pos[1] = Math.max(pos[1], offsetY + Utils.convertDpToPixel(10));

                    offsetY = pos[1];

                    // draw the marker
                    mMarker.draw(canvas, pos[0], pos[1]);
                }
            }
        };

        /**
         * Customized to natively highlight all the values in different datasets along the same X.
         */
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
