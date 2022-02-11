// ignore_for_file: prefer_final_fields, prefer_const_declarations, avoid_function_literals_in_foreach_calls

import 'dart:convert';

import 'package:coin_flutter/database/db.dart';
import 'package:coin_flutter/models/coin.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class CoinRepository extends ChangeNotifier {
  List<Coin> _table = [];
  List<Coin> get table => _table;

  CoinRepository() {
    _setupCoinsTable();
    _setupDataTableCoins();
    _readCoinsTable();
  }

  _readCoinsTable() async {
    Database db = await DB.instance.database;
    List results = await db.query('coins');

    _table = results.map((row) {
      return Coin(
        baseId: row['baseId'],
        icon: row['icon'],
        initials: row['initials'],
        name: row['name'],
        price: double.parse(row['price']),
        timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp']),
        changeHour: double.parse(row['changeHour']),
        changeDay: double.parse(row['changeDay']),
        changeWeek: double.parse(row['changeWeek']),
        changeMonth: double.parse(row['changeMonth']),
        changeYear: double.parse(row['changeYear']),
        changeTotalPeriod: double.parse(row['changeTotalPeriod']),
      );
    }).toList();

    notifyListeners();
  }

  _coinsTableIsEmpty() async {
    Database db = await DB.instance.database;
    List resultados = await db.query('coins');
    return resultados.isEmpty;
  }

  _setupDataTableCoins() async {
    if (await _coinsTableIsEmpty()) {
      String uri = 'https://api.coinbase.com/v2/assets/search?base=BRL';

      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> coins = json['data'];
        Database db = await DB.instance.database;
        Batch batch = db.batch();

        coins.forEach((coin) {
          final price = coin['latest_price'];
          final timestamp = DateTime.parse(price['timestamp']);

          batch.insert('coins', {
            'baseId': coin['id'],
            'initials': coin['symbol'],
            'name': coin['name'],
            'icon': coin['image_url'],
            'price': coin['latest'],
            'timestamp': timestamp.millisecondsSinceEpoch,
            'changeHour': price['percent_change']['hour'].toString(),
            'changeDay': price['percent_change']['day'].toString(),
            'changeWeek': price['percent_change']['week'].toString(),
            'changeMonth': price['percent_change']['month'].toString(),
            'changeYear': price['percent_change']['year'].toString(),
            'changeTotalPeriod': price['percent_change']['all'].toString()
          });
        });
        await batch.commit(noResult: true);
      }
    }
  }

  _setupCoinsTable() async {
    final String table = '''
      CREATE TABLE IF NOT EXISTS coins (
        baseId TEXT PRIMARY KEY,
        initials TEXT,
        name TEXT,
        icon TEXT,
        price TEXT,
        timestamp INTEGER,
        changeHour TEXT,
        changeDay TEXT,
        changeWeek TEXT,
        changeMonth TEXT,
        changeYear TEXT,
        changeTotalPeriod TEXT
      );
    ''';
    Database db = await DB.instance.database;
    await db.execute(table);
  }
}
