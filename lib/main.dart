// ignore_for_file: prefer_const_constructors

import 'package:coin_flutter/repositories/account_repository.dart';
import 'package:coin_flutter/repositories/coin_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CoinRepository()),
        ChangeNotifierProvider(
            create: (context) => AccountRepository(
                  coins: context.read<CoinRepository>(),
                )),
      ],
      child: MyApp(),
    ),
  );
}
