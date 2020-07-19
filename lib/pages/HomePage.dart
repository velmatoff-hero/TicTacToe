import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';

import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SocketIO socketIO;
  bool myTurn;
  String symbol;
  String msg;
  List<String> disp;

  @override
  void initState() {
    symbol = '';
    msg = 'Waiting for an opponent...';
    myTurn = false;
    disp = ['', '', '', '', '', '', '', '', ''];

    socketIO =
        SocketIOManager().createSocketIO("<PUT HERE YOUR SERVER URI>", "/");

    socketIO.init();

    socketIO.subscribe('game.begin', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      this.setState(() {
        symbol = data['symbol'];
        if (symbol == 'X') {
          msg = 'You turn.';
          myTurn = true;
        } else {
          msg = "Yours opponent's turn.";
          myTurn = false;
        }
      });
    });

    socketIO.subscribe("move.made", (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      this.setState(() {
        int index = _decodeTurn(data['position']);
        disp[index] = data['symbol'];
        if (symbol == data['symbol']) {
          myTurn = false;
          msg = "Yours opponent's turn.";
        } else {
          myTurn = true;
          msg = "You turn.";
        }
      });
      if (_gameOver()) {
        this.setState(() {
          myTurn ? msg = 'You lost.' : msg = 'You won!';
        });
      }
    });

    socketIO.subscribe("opponent.left", () {
      this.setState(() {
        msg = "Opponent's left...";
      });
    });
    socketIO.connect();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(msg),
        ),
        backgroundColor: Colors.grey[800],
        body: GridView.builder(
          itemCount: 9,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                _tapped(index);
              },
              child: Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.grey[700])),
                child: Center(
                  child: Text(
                    disp[index],
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                ),
              ),
            );
          },
        ));
  }

  _encodeTurn(int turn) {
    switch (turn) {
      case 0:
        return 'r0c0';
      case 1:
        return 'r0c1';
      case 2:
        return 'r0c2';
      case 3:
        return 'r1c0';
      case 4:
        return 'r1c1';
      case 5:
        return 'r1c2';
      case 6:
        return 'r2c0';
      case 7:
        return 'r2c1';
      case 8:
        return 'r2c2';
    }
  }

  _decodeTurn(String turn) {
    switch (turn) {
      case 'r0c0':
        return 0;
      case 'r0c1':
        return 1;
      case 'r0c2':
        return 2;
      case 'r1c0':
        return 3;
      case 'r1c1':
        return 4;
      case 'r1c2':
        return 5;
      case 'r2c0':
        return 6;
      case 'r2c1':
        return 7;
      case 'r2c2':
        return 8;
    }
  }

  _gameOver() {
    var matches = ['XXX', 'OOO'];
    var rows = [
      disp[0] + disp[1] + disp[2],
      disp[3] + disp[4] + disp[5],
      disp[6] + disp[7] + disp[8],
      disp[0] + disp[3] + disp[6],
      disp[1] + disp[4] + disp[7],
      disp[2] + disp[5] + disp[8],
      disp[0] + disp[4] + disp[8],
      disp[2] + disp[4] + disp[6]
    ];

    for (int i = 0; i < rows.length; i++) {
      if (rows[i] == matches[0] || rows[i] == matches[1]) {
        return true;
      }
    }
    return false;
  }

  void _tapped(int index) {
    if (myTurn && disp[index].isEmpty && !_gameOver()) {
      var turn = _encodeTurn(index);
      socketIO.sendMessage(
          'make.move', json.encode({"symbol": "$symbol", "position": "$turn"}));
      setState(() {
        disp[index] = '$symbol';
      });
    }
  }
}
