// ignore_for_file: prefer_final_fields

import 'package:coin_flutter/database/db.dart';
import 'package:coin_flutter/models/position.dart';
import 'package:coin_flutter/repositories/coin_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

class AccountRepository extends ChangeNotifier {
  late Database db;
  List<Position> _wallet = [];
  double _balance = 0;
  CoinRepository coins;

  get balance => _balance;
  List<Position> get wallet => _wallet;

  AccountRepository({required this.coins}) {
    _initRepository();
  }

  _initRepository() async {
    await _getBalance();
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
}
