import React from "react";
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  processColor,
  LayoutAnimation
} from "react-native";
import update from "immutability-helper";

import { LineChart } from "react-native-charts-wrapper";

const greenBlue = "rgb(26, 182, 151)";
const petrel = "rgb(59, 145, 153)";
const SIZE = 40;
const values = new Array(SIZE).fill(0).map((item, index) => 10 + index % 10);

class LineChartScreen extends React.Component {
  constructor() {
    super();

    this.state = {};
  }

  handleSelect(event) {
    let entry = event.nativeEvent;
    if (entry == null) {
      this.setState({ ...this.state, selectedEntry: null });
    } else {
      this.setState({ ...this.state, selectedEntry: JSON.stringify(entry) });
    }

    console.log(event.nativeEvent);
  }

  render() {
    return (
      <View style={{ flex: 1 }}>
        <View style={{ height: 80 }}>
          <Text> selected entry</Text>
          <Text> {this.state.selectedEntry}</Text>
        </View>

        <View style={styles.container}>
          <LineChart
            style={styles.chart}
            chartBackgroundColor={processColor("transparent")}
            data={{
              dataSets: [
                {
                  values: values.map((value, index) => ({x : index, y: value, marker : `${value} Kg`})),
                  label: "",
                  config: {
                    drawValues: false,
                    lineWidth: 2,
                    drawCircles: false,
                    circleColor: processColor(petrel),
                    drawCircleHole: true,
                    circleRadius: 5,
                    highlightColor: processColor("transparent"),
                    color: processColor("white"),
                    drawFilled: false,
                    fillGradient: {
                      colors: [processColor(petrel), processColor(greenBlue)],
                      positions: [0, 0.5],
                      angle: 90,
                      orientation: "TOP_BOTTOM"
                    },
                    fillAlpha: 1000,
                    valueTextSize: 15
                  }
                },
              ]
            }}
            chartDescription={{ text: "" }}
            legend={{
              enabled: false
            }}
            marker={{
              enabled: true,
              markerColor: processColor("transparent"),
              textColor: processColor("black")
            }}
            xAxis={{
              enabled: true,
              granularity: 1,
              drawLabels: true,
              position: "BOTTOM",
              drawAxisLine: true,
              drawGridLines: false,
              fontFamily: "HelveticaNeue-Medium",
              fontWeight: "bold",
              textSize: 12,
              textColor: processColor("gray"),
              valueFormatter: ["M", "T", "W", "T", "F", "S"]
            }}
            yAxis={{
              left: {
                enabled: false
              },
              right: {
                enabled: false
              }
            }}
            autoScaleMinMaxEnabled={true}
            animation={{
              durationX: 0,
              durationY: 1500,
              easingY: "EaseInOutQuart"
            }}
            drawGridBackground={true}
            drawBorders={false}
            touchEnabled={true}
            dragEnabled={true}
            scaleEnabled={false}
            scaleXEnabled={false}
            scaleYEnabled={false}
            pinchZoom={false}
            zoom={{
              scaleX: 2,
              scaleY: 1,
              xValue: SIZE,
              yValue: 0
            }}
            doubleTapToZoomEnabled={false}
            dragDecelerationEnabled={true}
            dragDecelerationFrictionCoef={0.99}
            keepPositionOnRotation={false}
            onSelect={this.handleSelect.bind(this)}
            onChange={event => console.log(event.nativeEvent)}
          />
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#F5FCFF",
    padding: 20
  },
  chart: {
    flex: 1,
  }
});

export default LineChartScreen;
