import React from 'react';
import {
    View,
    Text,
    Image,
    ScrollView,
    TouchableOpacity,
    Dimensions,
    processColor,
    Platform,
    StatusBar
} from "react-native";
import { LineChart } from "react-native-charts-wrapper";

import { StyleSheet } from "react-native";

export const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: "#000000"
      },
      chart: {
        // flex: 1
        height: 230
        // backgroundColor: "red"
      },
      row: {
        display: "flex",
        flexDirection: "row"
      },
      alignCenter: {
        alignItems: "center"
      }
});

export const GET_DASHBOARD_DATA = "GET_DASHBOARD_DATA";
export const GET_DASHBOARD_DATA_SUCCESS = "GET_DASHBOARD_DATA_SUCCESS";
export const GET_DASHBOARD_DATA_FAILED = "GET_DASHBOARD_DATA_FAILED";
export const GROSS_PAY = "Gross Pay";
export const NET_PAY = "Net Pay";
export const DEDUCTIONS = "Deductions";
export const ONE_MONTH = "1m";
export const THREE_MONTHS = "3m";
export const SIX_MONTHS = "6m";
export const YTD = "YTD";
export const ALL = "ALL";
export const LANDSCAPE = "LANDSCAPE";
export const PORTRAIT = "PORTRAIT";

const initialState = {
    documentFieldDisplay: [],
    employeeDashboardData: [],
    series: [],
    dropDownData: [],
    payDateTicks: [],
    xAxis: [],
    payrollInformation: [],
    data: [],
    payrollTemplates: [],
    totalEarnings: 0,
    totalNetPay: 0,
    totalDeductions: 0
  };
  
export const addCommas = x => {
    var parts = x.toString().split(".");
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    parts[1] = parts[1] || "00";
    return parts.join(".");
  };
  
const getData = (data, key) => {
  return data
    .find(datum => datum.name === key)
    .data.reduce((prev, curr) => prev + curr[1], 0);
};
  
const config = {
    // mode: "CUBIC_BEZIER",
    drawValues: false,
    lineWidth: 1.5,
    drawCircles: false,
    drawCircleHole: false,
    drawHorizontalHighlightIndicator: false,
    drawFilled: true,
    fillGradient: {
      // positions: [0, 0.5],
      angle: 90,
      orientation: "TOP_BOTTOM"
    },
    fillAlpha: 1000,
    valueTextSize: 15
  };
  
  const ALPHA_VALUE = Platform.OS === "android" ? 0.5 : 0.8;
  
  const colors = {
    [GROSS_PAY]: {
      color: processColor("rgb(12, 97, 114)"),
      gradientColors: [
        processColor("transparent"),
        processColor(`rgba(12, 97, 114, ${ALPHA_VALUE})`)
      ]
    },
    [NET_PAY]: {
      color: processColor("rgb(57, 109, 58)"),
      gradientColors: [
        processColor("transparent"),
        processColor(`rgba(57, 109, 58, ${ALPHA_VALUE})`)
      ]
    },
    [DEDUCTIONS]: {
      color: processColor("rgb(120, 40, 44)"),
      gradientColors: [
        processColor("rgba(120, 40, 44, 0.2)"),
        processColor(`rgba(120, 40, 44, ${ALPHA_VALUE})`)
      ]
    }
  };

function dashboardDataReducer(body, state = initialState) {
    const { employeeDashboardData, documentFieldDisplay } = body;
      let dropDownData = [],
        series = [],
        payrollInformation = [],
        data = [],
        payDateTicks = [],
        payrollTemplates = [],
        totalEarnings = 0,
        totalDeductions = 0,
        totalNetPay = 0,
        xAxis = [];

      if (!!employeeDashboardData.length) {
        dropDownData = employeeDashboardData.map((item, index) => ({
          name: item.name,
          taxYears:
            item.name === "Payslip" ? item.data[index].taxYears : item.data,
          template:
            item.name === "Payslip"
              ? item.data[index].payrollTemplates[0].payslipTemplate
              : item.template
        }));
        payrollTemplates = employeeDashboardData.find(
          item => item.name === "Payslip"
        ).data[0].payrollTemplates;
        const seriesData = employeeDashboardData.find(
          item => item.name === "Payslip"
        ).data[0];
        series = seriesData.series;
        totalEarnings = getData(series, GROSS_PAY);
        totalDeductions = getData(series, DEDUCTIONS);
        totalNetPay = getData(series, NET_PAY);
        const currency = payrollTemplates.length
          ? "$"
          : "";
        payrollInformation = seriesData.payrollInformation;
        data = series.map(item => ({
          label: item.name,
          values: item.data.map(datum => ({
            y: datum[1],
            marker: `${currency}${addCommas(datum[1])}`
          })),
          config: {
            ...config,
            color: colors[item.name].color,
            fillGradient: {
              ...config.fillGradient,
              colors: colors[item.name].gradientColors
            }
          }
        }));
        payDateTicks = series[0].data.map(item => item[0]);
        xAxis = series[0].data.map(item =>
          new Date(item[0]).toLocaleDateString('en-US',{"month": "short", "year" : "2-digit"})
          // "Apr 19"
        );
      }
      return {
        ...state,
        employeeDashboardData,
        documentFieldDisplay,
        series,
        dropDownData,
        data,
        xAxis,
        payDateTicks,
        payrollInformation,
        payrollTemplates,
        totalDeductions,
        totalEarnings,
        totalNetPay
      };
}

export default class DashboardScreen extends React.Component {
    render() {
        return (<>
            <GraphComponent {...dashboardDataReducer(require("./response.json"))}></GraphComponent>
        </>)
    }
}

const debounce = (cb, wait) => {
    let timeout = null;
    return (event) => {
        clearTimeout(timeout);
        const x = event.nativeEvent.x;
        timeout = setTimeout(cb.bind(null, { nativeEvent: {x}}), wait);
    }
}

export class GraphComponent extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedDocument: "",
            selectedYear: "",
            selectedPeriod: "",
            documents: [],
            years: [],
            periods: [],
            showHeader: true,
            // orientation: PORTRAIT,
            filters: [
              { label: ONE_MONTH, value: 1 },
              { label: THREE_MONTHS, value: 3 },
              { label: SIX_MONTHS, value: 6 },
              { label: YTD, value: 12 },
              { label: ALL, value: "ALL" }
            ],
            selected: ALL,
            selectedItem: 0,
            zoom: {
              scaleX: 1,
              scaleY: 1,
              xValue: 0,
              yValue: 0
            },
            sliderLow: 1,
            sliderHigh: this.props.xAxis.length,
            scrollEnabled: true
          };
          this.handleSelect = this.handleSelect.bind(this);
          this.handleSelectDelayed = debounce(this.handleSelect, 20);
    }

    changeFilter = item => () => {
        const { xAxis, payDateTicks } = this.props;
        const length = xAxis.reduce((prev, curr) => {
          const findIndex = prev.find(item => item === curr);
          if (findIndex !== -1) {
            return [...prev, curr];
          }
          return prev;
        }, []).length;
        const { sliderLow, sliderHigh } = this.state;
        let start = sliderLow;
        let end = sliderHigh;
        if (item.value === "ALL") {
          start = 0;
          end = xAxis.length;
        } else if (end - item.value < 0) {
          start = 0;
          end = item.value;
        } else {
          start = end - item.value;
        }
        // this._rangeSlider.setLowValue(start);
        // this._rangeSlider.setHighValue(end);
        this.setPoints(start, end);
        this.setState({ selected: item.label });
      };
    
      setPoints = (start, end) => {
        const length = end - start;
        this.setState({
          sliderLow: start,
          sliderHigh: end,
          zoom: {
            ...this.state.zoom,
            scaleX: this.props.xAxis.length / length,
            xValue: (start + end) / 2
          }
        });
      };

    handleSelect(event) {
      let entry = event.nativeEvent;
        if (!!entry && !!entry.x) {
          this.setState({
            selectedItem: entry.x
          });
        } else {
          this.setState({
            selectedItem: Math.max(this.props.payDateTicks.length - 1, 0)
          });
        }
      }

    render() {
        return <View style={styles.container}>
            {!!this.props.data.length && (<LineChart
                  style={styles.chart}
                  data={{
                    dataSets: this.props.data
                  }}
                  ref={chart => (this.chartRef = chart)}
                  chartDescription={{ text: "" }}
                  legend={{
                    enabled: false
                  }}
                  marker={{
                    enabled: true,
                    markerColor: processColor("orange"),
                    // markerColor: processColor("#FF6000"),
                    textColor: processColor("white")
                  }}
                  xAxis={{
                    enabled: true,
                    granularity: 1,
                    avoidFirstLastClipping : false,
                    drawLabels: true,
                    position: "BOTTOM",
                    drawAxisLine: true,
                    // Customized
                    drawGridLines: false,
                    // fontFamily: "HelveticaNeue-Medium",
                    // fontWeight: "bold",
                    textSize: 10,
                    textColor: processColor("white"),
                    valueFormatter: this.props.xAxis
                  }}
                  yAxis={{
                    left: {
                      enabled: true,
                      textColor: processColor("white"),
                      valueFormatter: "largeValue",
                      // Customized Added grid line options
                      drawGridLines : true,
                      gridColor: processColor("rgba(192, 192, 192, 0.4)"),
                      gridDashedLine: {
                        lineLength : Platform.select({ios: 10, android: 30}),
                        spaceLength : Platform.select({ios: 7, android: 21}),
                        phase: 0
                      }
                    },
                    right: {
                      enabled: false
                    },
                  }}
                  autoScaleMinMaxEnabled={true}
                  animation={{
                    durationX: 0,
                    durationY: 1500,
                    easingY: "EaseInOutQuart"
                  }}
                  drawGridBackground={false}
                  drawBorders={false}
                  touchEnabled={true}
                  dragEnabled={true}
                  // scaleEnabled={true}
                  scaleXEnabled={true}
                  scaleYEnabled={false}
                  pinchZoom={true}
                  doubleTapToZoomEnabled={false}
                  dragDecelerationEnabled={false}
                  // dragDecelerationFrictionCoef={0.99}
                  keepPositionOnRotation={false}
                  onSelect={this.handleSelect}
                  zoom={this.state.zoom}
                //   onChange={({ nativeEvent }) =>
                //     this.onChangeGraphDelayed(nativeEvent)
                //   }
            />)}
            <View
                style={{
                  //marginLeft: 20,
                  //marginRight: 20,
                  paddingHorizontal: 20,
                  marginVertical: 20
                }}
              >
                <View
                  style={[styles.row, styles.alignCenter]}
                >
                  {this.state.filters.map((item, index) => (
                    <FilterItem
                      key={index}
                      item={item}
                      onPress={this.changeFilter}
                      selected={this.state.selected}
                      orientation={this.state.orientation}
                    />
                  ))}
                </View>
              </View>
        </View>
    }
}

export function FilterItem(props) {
    return (
      <TouchableOpacity
        onPress={props.onPress(props.item)}
        style={[
          props.orientation !== LANDSCAPE
            ? {
                flexGrow: 1,
                paddingVertical: props.selected === props.item.label ? 12 : 8
              }
            : {
                width: 40,
                paddingVertical: 15
              },
          {
            backgroundColor:
              props.selected === props.item.label
                ? "#FF6000"
                : "rgba(255,255,255,0.15)",
            alignItems: "center",
            borderRadius: props.selected === props.item.label ? 5 : 0
          }
        ]}
      >
        <Text style={{ color: "#FFF", fontSize: 10 }}>{props.item.label}</Text>
      </TouchableOpacity>
    );
  }