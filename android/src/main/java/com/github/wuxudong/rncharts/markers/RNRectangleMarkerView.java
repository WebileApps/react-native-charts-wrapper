package com.github.wuxudong.rncharts.markers;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.drawable.Drawable;
import android.support.v4.content.res.ResourcesCompat;
import android.text.TextUtils;
import android.widget.TextView;

import com.facebook.react.uimanager.PixelUtil;
import com.github.mikephil.charting.charts.Chart;
import com.github.mikephil.charting.components.MarkerView;
import com.github.mikephil.charting.data.CandleEntry;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.highlight.Highlight;
import com.github.mikephil.charting.utils.MPPointF;
import com.github.mikephil.charting.utils.Utils;
import com.github.wuxudong.rncharts.R;

import java.util.List;
import java.util.Map;

public class RNRectangleMarkerView extends MarkerView {

    private TextView tvContent;

    private Drawable backgroundLeft = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker_left, null);
    private Drawable background = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker, null);
    private Drawable backgroundRight = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker_right, null);

    private Drawable backgroundTopLeft = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker_top_left, null);
    private Drawable backgroundTop = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker_top, null);
    private Drawable backgroundTopRight = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker_top_right, null);

    private Paint mPaint;
    private Paint mInnerPaint;
    private int digits = 0;
    private static final float MarkerCircleWidth = PixelUtil.toPixelFromDIP(6);

    public RNRectangleMarkerView(Context context) {
        super(context, R.layout.rectangle_marker);

        tvContent = (TextView) findViewById(R.id.rectangle_tvContent);
        mPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mPaint.setColor(Color.WHITE);
        mInnerPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    }

    public void setDigits(int digits) {
        this.digits = digits;
    }

    @Override
    public void refreshContent(Entry e, Highlight highlight) {
        String text;

        if (highlight.getDataSetIndex() == 0) {
            mInnerPaint.setColor(Color.rgb(12, 97, 114));
        } else if (highlight.getDataSetIndex() == 1) {
            mInnerPaint.setColor(Color.rgb(57, 109, 58));
        } else if (highlight.getDataSetIndex() == 2) {
            mInnerPaint.setColor(Color.rgb(120, 40, 44));
        } else {
            mInnerPaint.setColor(Color.rgb(255, 96, 0));
        }
        if (e instanceof CandleEntry) {
            CandleEntry ce = (CandleEntry) e;
            text = Utils.formatNumber(ce.getClose(), digits, false);
        } else {
            text = Utils.formatNumber(e.getY(), digits, false);
        }

        if (e.getData() instanceof Map) {
            if (((Map) e.getData()).containsKey("marker")) {

                Object marker = ((Map) e.getData()).get("marker");
                text = marker.toString();

                if (highlight.getStackIndex() != -1 && marker instanceof List) {
                    text = ((List) marker).get(highlight.getStackIndex()).toString();
                }

            }
        }

        if (TextUtils.isEmpty(text)) {
            tvContent.setVisibility(INVISIBLE);
        } else {
            tvContent.setText(text);
            tvContent.setVisibility(VISIBLE);
        }

        super.refreshContent(e, highlight);
    }

    @Override
    public MPPointF getOffset() {
        return new MPPointF(0, 0);
    }

    @Override
    public MPPointF getOffsetForDrawingAtPoint(float posX, float posY) {

        MPPointF offset = getOffset();

        MPPointF offset2 = new MPPointF();
        float height = getHeight();
        offset2.x = offset.x;
        offset2.y = offset.y - height/ 2;

        Chart chart = getChartView();

        float width = getWidth();

        if (posX + offset2.x < 0) {
            offset2.x = 0;
        } else if (chart != null && posX + width + offset2.x > chart.getWidth()) {
            offset2.x = -width;
        }

        return offset2;
    }

    @Override
    public void draw(Canvas canvas, float posX, float posY) {
        super.draw(canvas, posX, posY);
        canvas.drawCircle(posX, posY, MarkerCircleWidth, mPaint);
        canvas.drawCircle(posX, posY, MarkerCircleWidth / 2, mInnerPaint);
    }

    public TextView getTvContent() {
        return tvContent;
    }

}

