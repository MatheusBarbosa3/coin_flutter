// ignore_for_file: prefer_final_fields, avoid_function_literals_in_foreach_calls

import 'package:coin_flutter/database/db.dart';
import 'package:coin_flutter/models/coin.dart';
import 'package:coin_flutter/models/history.dart';
import 'package:coin_flutter/models/position.dart';
import 'package:coin_flutter/repositories/coin_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

class AccountRepository extends ChangeNotifier {
  late Database db;
  List<Position> _wallet = [];
  List<History> _history = [];
  double _balance = 0;
  CoinRepository coins;

  get balance => _balance;
  List<Position> get wallet => _wallet;
  List<History> get history => _history;

  AccountRepository({required this.coins}) {
    _initRepository();
  }

  _initRepository() async {
    await _getBalance();
    await _getWallet();
    await _getHistory();
  }

  _getBalance() async {
    db = await DB.instance.database;
    List account = await db.query('account', limit: 1);
    _balance = account.first['balance'];
    notifyListeners();
  }

  setBalance(double value) async {
    db = await DB.instance.database;
    db.update('account', {'balance': value});
    _balance = value;
    notifyListeners();
  }

  buy(Coin coin, double value) async {
    db = await DB.instance.database;
    await db.transaction((txn) async {
      // verifica se a moeda já foi comprada
      final positionCoin = await txn.query(
        'wallet',
        where: 'initials = ?',
        whereArgs: [coin.initials],
      );

      // verifica se tem a moeda na carteira
      if (positionCoin.isEmpty) {
        await txn.insert('wallet', {
          'initials': coin.initials,
          'coin': coin.name,
          'amount': (value / coin.price).toString()
        });
      } else {
        final current = double.parse(positionCoin.first['amount'].toString());
        await txn.update(
          'wallet',
          {
            'amount': (current + (value / coin.price)).toString(),
          },
          where: 'initials = ?',
          whereArgs: [coin.initials],
        );
      }

      // insere a compra no historico
      await txn.insert('history', {
        'initials': coin.initials,
        'coin': coin.name,
        'amount': (value / coin.price).toString(),
        'value': value,
        'type_operation': 'purchase',
        'date_operation': DateTime.now().millisecondsSinceEpoch,
      });

      //atualiza o saldo
      await txn.update('account', {'balance': balance - value});
    });
    await _initRepository();
    notifyListeners();
  }

  _getWallet() async {
    _wallet = [];
    List positions = await db.query('wallet');
    positions.forEach((position) {
      Coin coin = coins.table.firstWhere(
        (m) => m.initials == position['initials'],
      );
      _wallet.add(Position(
        coin: coin,
        amount: double.parse(position['amount']),
      ));
    });
    notifyListeners();
  }

  _getHistory() async {
    _history = [];
    List operations = await db.query('history');
    operations.forEach((operation) {
      Coin coin = coins.table.firstWhere(
        (m) => m.initials == operation['initials'],
      );
      _history.add(History(
        dateOperation:
            DateTime.fromMillisecondsSinceEpoch(operation['date_operation']),
        typeOperation: operation['type_operation'],
        coin: coin,
        value: operation['value'],
        amount: double.parse(operation['amount']),
      ));
    });
    notifyListeners();
  }
}
