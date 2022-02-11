// ignore_for_file: prefer_const_constructors

import 'package:coin_flutter/repositories/account_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountRepository>();
    NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Conta', textAlign: TextAlign.center)),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              title: Text('Saldo'),
              subtitle: Text(
                real.format(account.balance),
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.indigo,
                ),
              ),
              trailing:
                  IconButton(onPressed: updateBalance, icon: Icon(Icons.edit)),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  updateBalance() async {
    final form = GlobalKey<FormState>();
    final value = TextEditingController();
    final account = context.read<AccountRepository>();

    value.text = account.balance.toString();

    AlertDialog dialog = AlertDialog(
      title: Text('Atualizar o Saldo'),
      content: Form(
        key: form,
        child: TextFormField(
          controller: value,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
          ],
          validator: (value) {
            if (value!.isEmpty) return 'Informe o valor do saldo';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text('CANCELAR')),
        TextButton(
          onPressed: () {
            if (form.currentState!.validate()) {
              account.setBalance(double.parse(value.text));
              Navigator.pop(context);
            }
          },
          child: Text('SALVAR'),
        ),
      ],
    );

    showDialog(context: context, builder: (context) => dialog);
  }
}
