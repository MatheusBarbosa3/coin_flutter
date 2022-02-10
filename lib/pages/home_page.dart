// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:coin_flutter/pages/coins_page.dart';
import 'package:coin_flutter/pages/settings_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController pageController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentPage);
  }

  setCurrentPage(page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        children: [CoinsPage(), SettingsPage()],
        onPageChanged: setCurrentPage,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.view_list_outlined), label: 'Criptos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: 'Configurações')
        ],
        onTap: (page) {
          pageController.animateToPage(page,
              duration: Duration(milliseconds: 400), curve: Curves.easeInCirc);
        },
        backgroundColor: Colors.purple[50],
      ),
    );
  }
}
