// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace

import 'package:coin_flutter/models/position.dart';
import 'package:coin_flutter/repositories/account_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int index = 0;
  double totalWallet = 0;
  double balance = 0;
  NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');
  late AccountRepository account;
  String graphicLabel = '';
  double graphicValue = 0;
  List<Position> wallet = [];

  @override
  Widget build(BuildContext context) {
    account = context.watch<AccountRepository>();
    balance = account.balance;
    setTotalWallet();

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 35, bottom: 8),
              child: Text(
                'Valor da carteira',
                style: TextStyle(color: Colors.deepPurple, fontSize: 18),
              ),
            ),
            Text(
              real.format(totalWallet),
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 35,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
              ),
            ),
            loadGraphic(),
            Container(
              child: Text(
                'Histórico de compras',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.teal,
                ),
              ),
              padding: EdgeInsets.all(12),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.teal.withOpacity(0.06)),
            ),
            loadHistory(),
          ],
        ),
      ),
    );
  }

  setTotalWallet() {
    final walletList = account.wallet;
    setState(() {
      totalWallet = account.balance;
      for (var position in walletList) {
        totalWallet += position.coin.price * position.amount;
      }
    });
  }

  setGraphicData(int index) {
    if (index < 0) return;

    if (index == wallet.length) {
      graphicLabel = 'Saldo';
      graphicValue = account.balance;
    } else {
      graphicLabel = wallet[index].coin.name;
      graphicValue = wallet[index].coin.price * wallet[index].amount;
    }
  }

  loadWallet() {
    setGraphicData(index);
    wallet = account.wallet;
    final sizeList = wallet.length + 1;

    return List.generate(sizeList, (i) {
      final isTouched = i == index;
      final isBalance = i == sizeList - 1;
      final fontSize = isTouched ? 18.0 : 15.0;
      final radius = isTouched ? 60.0 : 50.0;
      final color = isTouched ? Colors.deepPurple : Colors.deepPurple[400];

      double percent = 0;
      if (!isBalance) {
        percent = wallet[i].coin.price * wallet[i].amount / totalWallet;
      } else {
        percent = (account.balance > 0) ? account.balance / totalWallet : 0;
      }
      percent *= 100;

      return PieChartSectionData(
        color: color,
        value: percent,
        title: '${percent.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  loadGraphic() {
    return (account.balance <= 0)
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 5,
                    centerSpaceRadius: 120,
                    sections: loadWallet(),
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) =>
                          setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          index = -1;
                          return;
                        }
                        index = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                        setGraphicData(index);
                      }),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    graphicLabel,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    real.format(graphicValue),
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  loadHistory() {
    final history = account.history;
    final date = DateFormat('dd/MM/yyyy - HH:mm');
    List<Widget> widgets = [];

    for (var operation in history) {
      widgets.add(ListTile(
        title: Text(operation.coin.name),
        subtitle: Text(date.format(operation.dateOperation)),
        trailing: Text(real.format(operation.coin.price * operation.amount)),
      ));
      widgets.add(Divider());
    }
    return Column(
      children: widgets.reversed.toList(),
    );
  }
}
