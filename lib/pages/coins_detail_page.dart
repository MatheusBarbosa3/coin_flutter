// ignore_for_file: prefer_const_constructors, unused_local_variable, avoid_unnecessary_containers

import 'package:coin_flutter/models/coin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class CoinsDetailPage extends StatefulWidget {
  Coin coin;

  CoinsDetailPage({Key? key, required this.coin}) : super(key: key);

  @override
  _CoinsDetailPageState createState() => _CoinsDetailPageState();
}

class _CoinsDetailPageState extends State<CoinsDetailPage> {
  NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');
  final _form = GlobalKey<FormState>();
  final _value = TextEditingController();
  double amount = 0;

  buy() {
    if (_form.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Parabéns! Você comprou $amount de ${widget.coin.name}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coin.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    child: Image.asset(widget.coin.icon),
                    width: 50,
                  ),
                  Container(
                    width: 10,
                  ),
                  Text(
                    real.format(widget.coin.price),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1,
                      color: Colors.deepPurple,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Container(
                child: Text(
                  '$amount ${widget.coin.initials}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.teal,
                  ),
                ),
                margin: EdgeInsets.only(bottom: 24),
                padding: EdgeInsets.all(12),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.teal.withOpacity(0.06)),
              ),
            ),
            Form(
              key: _form,
              child: TextFormField(
                controller: _value,
                style: TextStyle(
                  fontSize: 22,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Valor',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                  suffix: Text(
                    'reais',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Informe o valor';
                  }
                },
                onChanged: (value) {
                  setState(() {
                    amount = (value.isEmpty)
                        ? 0
                        : double.parse(value) / widget.coin.price;
                  });
                },
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(top: 24),
              child: ElevatedButton(
                onPressed: () {
                  buy();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Comprar',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
