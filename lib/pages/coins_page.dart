// ignore_for_file: prefer_const_constructors

import 'package:coin_flutter/repositories/coin_repository.dart';
import 'package:flutter/material.dart';

class CoinsPage extends StatelessWidget {
  const CoinsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final table = CoinRepository.table;

    return Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.monetization_on_rounded),
          title: Text("Cryptocurrencies"),
        ),
        body: ListView.separated(
            itemBuilder: (BuildContext context, int coin) {
              return ListTile(
                leading: Image.asset(table[coin].icon),
                title: Text(table[coin].name),
                trailing: Text(table[coin].price.toString()),
              );
            },
            padding: EdgeInsets.all(16),
            separatorBuilder: (_, __) => Divider(),
            itemCount: table.length));
  }
}
