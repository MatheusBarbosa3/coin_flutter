import 'package:coin_flutter/models/coin.dart';

class CoinRepository {
  static List<Coin> table = [
    Coin(
      icon: 'images/bitcoin.png',
      name: 'Bitcoin',
      initials: 'BTC',
      price: 123400.00,
    ),
    Coin(
      icon: 'images/cardano.png',
      name: 'Cardano',
      initials: 'ADA',
      price: 400.00,
    ),
    Coin(
      icon: 'images/ethereum.png',
      name: 'Ethereum',
      initials: 'ETH',
      price: 3400.00,
    ),
    Coin(
      icon: 'images/litecoin.png',
      name: 'Litecoin',
      initials: 'LTC',
      price: 4.00,
    ),
    Coin(
      icon: 'images/usdcoin.png',
      name: 'Usd coin',
      initials: 'USDC',
      price: 3.00,
    ),
    Coin(
      icon: 'images/xrp.png',
      name: 'XRP',
      initials: 'XRP',
      price: 10.00,
    ),
  ];
}
