// ignore_for_file: prefer_const_constructors

import 'package:coin_flutter/models/coin.dart';
import 'package:coin_flutter/pages/coins_detail_page.dart';
import 'package:coin_flutter/repositories/coin_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CoinsPage extends StatefulWidget {
  const CoinsPage({Key? key}) : super(key: key);

  @override
  State<CoinsPage> createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> {
  final table = CoinRepository.table;
  NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');
  List<Coin> selected = [];

  showDetails(Coin coin) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CoinsDetailPage(coin: coin),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Center(child: Text("Criptomoedas", textAlign: TextAlign.center)),
        ),
        body: ListView.separated(
            itemBuilder: (BuildContext context, int coin) {
              return ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                leading: selected.contains(table[coin])
                    ? CircleAvatar(
                        child: Icon(Icons.check),
                      )
                    : SizedBox(
                        child: Image.asset(table[coin].icon),
                        width: 40,
                      ),
                title: Text(
                  table[coin].name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Text(real.format(table[coin].price)),
                selected: selected.contains(table[coin]),
                selectedTileColor: Colors.deepPurple[50],
                onLongPress: () {
                  setState(() {
                    (selected.contains(table[coin]))
                        ? selected.remove(table[coin])
                        : selected.add(table[coin]);
                  });
                },
                onTap: () => showDetails(table[coin]),
              );
            },
            padding: EdgeInsets.all(16),
            separatorBuilder: (_, __) => Divider(),
            itemCount: table.length));
  }
}
