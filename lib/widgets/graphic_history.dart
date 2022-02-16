// ignore_for_file: prefer_const_constructors, must_be_immutable, curly_braces_in_flow_control_structures, avoid_unnecessary_containers

import 'package:coin_flutter/models/coin.dart';
import 'package:coin_flutter/repositories/coin_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GraphicHistory extends StatefulWidget {
  Coin coin;
  GraphicHistory({Key? key, required this.coin}) : super(key: key);

  @override
  _GraphicHistoryState createState() => _GraphicHistoryState();
}

enum Period { hour, day, week, month, year, total }

class _GraphicHistoryState extends State<GraphicHistory> {
  List<Color> colors = [
    Colors.purple,
  ];
  Period period = Period.hour;
  List<Map<String, dynamic>> history = [];
  List completeData = [];
  List<FlSpot> graphicData = [];
  double maxX = 0;
  double maxY = 0;
  double minY = 0;
  ValueNotifier<bool> loaded = ValueNotifier(false);
  late CoinRepository repository;
  NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');

  setData() async {
    loaded.value = false;
    graphicData = [];

    if (history.isEmpty) {
      history = await repository.getCoinHistory(widget.coin);
    }

    completeData = history[period.index]['prices'];
    completeData = completeData.reversed.map((item) {
      double price = double.parse(item[0]);
      int time = int.parse(item[1].toString() + '000');
      return [price, DateTime.fromMillisecondsSinceEpoch(time)];
    }).toList();

    maxX = completeData.length.toDouble();
    maxY = 0;
    minY = double.infinity;

    for (var item in completeData) {
      maxY = item[0] > maxY ? item[0] : maxY;
      minY = item[0] < minY ? item[0] : minY;
    }

    for (int i = 0; i < completeData.length; i++) {
      graphicData.add(FlSpot(
        i.toDouble(),
        completeData[i][0],
      ));
    }
    loaded.value = true;
  }

  LineChartData getChartData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: graphicData,
          isCurved: true,
          colors: colors,
          barWidth: 2,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            colors: colors.map((color) => color.withOpacity(0.15)).toList(),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Color(0xFF343434),
          getTooltipItems: (data) {
            return data.map((item) {
              final date = getDate(item.spotIndex);
              return LineTooltipItem(
                real.format(item.y),
                TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: '\n $date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(.5),
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }

  getDate(int index) {
    DateTime date = completeData[index][1];
    if (period != Period.year && period != Period.total)
      return DateFormat('dd/MM - HH:mm').format(date);
    else
      return DateFormat('dd/MM/y').format(date);
  }

  chartButton(Period p, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(
        onPressed: () => setState(() => period = p),
        child: Text(label),
        style: (period != p)
            ? ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.grey),
              )
            : ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.indigo[50]),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    repository = context.read<CoinRepository>();
    setData();

    return Container(
      child: AspectRatio(
        aspectRatio: 2,
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  chartButton(Period.hour, '1H'),
                  chartButton(Period.day, '24H'),
                  chartButton(Period.week, '7D'),
                  chartButton(Period.month, 'Mês'),
                  chartButton(Period.year, 'Ano'),
                  chartButton(Period.total, 'Todos'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: ValueListenableBuilder(
                valueListenable: loaded,
                builder: (context, bool isLoaded, _) {
                  return (isLoaded)
                      ? LineChart(
                          getChartData(),
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
