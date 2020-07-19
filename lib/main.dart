import 'package:flutter/material.dart';
import 'package:myapp/pages/HomePage.dart';

void main() => runApp(TicTacToe());

class TicTacToe extends StatelessWidget {
  @override
  Widget build(BuildContext contex) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}
