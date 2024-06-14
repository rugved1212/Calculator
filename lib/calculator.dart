import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Calculator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Calculator();
}

class _Calculator extends State<Calculator> {
  String num = "";
  String res = "";
  double textsize = 50;
  Color textcolor = Colors.white;
  double resulttextsize = 35;
  Color resulttextcolor = Colors.white60;
  List<String> history_cal = [];
  List<String> history_res = [];
  bool resbool = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      history_cal = prefs.getStringList('history_cal') ?? [];
      history_res = prefs.getStringList('history_res') ?? [];
    });
  }

  Future<void> _saveHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history_cal', history_cal);
    await prefs.setStringList('history_res', history_res);
  }

  void _addHistory(String calculation, String result) {
    setState(() {
      history_cal.insert(0, calculation);
      history_res.insert(0, result);
      if (history_cal.length > 10) {
        history_cal.removeLast();
        history_res.removeLast();
      }
      _saveHistory();
    });
  }

  void numberbtn(String _no) {
    setState(() {
      if (resbool) {
        num = "";
        res = "";
        textsize = 50;
        textcolor = Colors.white;
        resulttextsize = 35;
        resulttextcolor = Colors.white60;
        resbool = false;
      }
      if (_no == ".") {
        List<String> parts = num.split(RegExp(r'[+\-×÷%]'));
        String lastPart = parts.isNotEmpty ? parts.last : '';
        if (lastPart.contains(".")) {
          return; // Prevent multiple decimal points in the last number
        }
      }
      num = num + _no;
      _calculate();
    });
  }

  void operatorbtn(String _op) {
    setState(() {
      if (num.isNotEmpty && "+-×÷".contains(num[num.length - 1])) {
        num = num.substring(0, num.length - 1) + _op;
      } else {
        num = num + _op;
      }
      resbool = false;
    });
  }


  void _clear() {
    setState(() {
      if (num.isNotEmpty) {
        num = "";
        res = "";
        textsize = 50;
        textcolor = Colors.white;
        resulttextsize = 35;
        resulttextcolor = Colors.white60;
      }
    });
  }

  void _delete() {
    setState(() {
      if (num.isNotEmpty) {
        num = num.substring(0, num.length - 1);
        _calculate();
      }
    });
  }

  void _calculate() {
    setState(() {
      if (num.isNotEmpty) {
        RegExp regExp = RegExp(r'\d+(\.\d+)?|[\+\-×÷%]');
        Iterable<RegExpMatch> matches = regExp.allMatches(num);
        List<String> component =
            matches.map((match) => match.group(0)!).toList();

        double result = double.parse(component[0]);
        String? operator;
        for (int i = 1; i < component.length; i += 2) {
          operator = component[i];
          double operand = double.parse(component[i + 1]);
          switch (operator) {
            case "+":
              result += operand;
              break;
            case "-":
              result -= operand;
              break;
            case "×":
              result *= operand;
              break;
            case "÷":
              result /= operand;
              break;
            case "%":
              result = operand / 100;
              break;
          }
        }
        setState(() {
          res = "=" + result.toString();
        });
      } else {
        setState(() {
          res = "";
        });
      }
    });
  }

  void _clearHistory() {
    setState(() {
      history_cal.clear();
      history_res.clear();
      _saveHistory();
      _loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenwidth = MediaQuery.of(context).size.width;
    var screenheight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Stack(children: [
      Container(color: Color.fromRGBO(36, 36, 35, 1)),
      Align(
        alignment: Alignment.topCenter,
        child: Container(
            width: screenwidth,
            height: screenheight / 4,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              reverse: true,
              itemCount: history_cal.length,
              itemBuilder: (context, index) {
                final cal = history_cal[index];
                final resu = history_res[index];
                return history_widg(question: cal, answer: resu);
              },
            )),
      ),
      Positioned(
        top: screenheight / 3.9,
        child: SizedBox(
          width: screenwidth,
          height: 1,
          child: Container(
            color: Colors.black12,
          ),
        ),
      ),
      Align(
          alignment: Alignment.centerRight,
          child: Container(
            child: Text(
              num.isEmpty ? "0" : num,
              style: TextStyle(
                  fontSize: textsize,
                  fontWeight: FontWeight.bold,
                  color: textcolor),
            ),
            margin: EdgeInsets.fromLTRB(0, 0, 20, 320),
          )),
      Align(
          alignment: Alignment.centerRight,
          child: Container(
            child: Text(
              res.isEmpty ? "=0" : res,
              style: TextStyle(
                  fontSize: resulttextsize,
                  fontWeight: FontWeight.bold,
                  color: resulttextcolor),
            ),
            margin: EdgeInsets.fromLTRB(0, 0, 20, 225),
          )),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: screenwidth,
          height: screenheight / 1.7,
          child: GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            padding: EdgeInsets.all(2),
            children: [
              btn(
                text: "AC",
                tip: "Clear",
                func: () => _clear(),
                fontsi: 20,
              ),
              btn(
                text: "DEL",
                tip: "Delete",
                func: () => _delete(),
                fontsi: 20,
              ),
              btn(
                text: "%",
                tip: "Percentage",
                func: () {
                  if (num.isNotEmpty) {
                    setState(() {
                      double temp = double.parse(num) / 100;
                      res = "=" + temp.toString();
                      _addHistory(num, res);
                      textsize = 35;
                      textcolor = Colors.white60;
                      resulttextsize = 50;
                      resulttextcolor = Colors.white;
                      resbool = true;
                    });
                  }
                },
                fontsi: 22,
              ),
              btn(
                text: "÷",
                tip: "Divide",
                func: () => operatorbtn("÷"),
                fontsi: 30,
              ),
              btn(
                text: "7",
                tip: "7",
                func: () => numberbtn("7"),
                fontsi: 20,
              ),
              btn(
                text: "8",
                tip: "8",
                func: () => numberbtn("8"),
                fontsi: 20,
              ),
              btn(
                text: "9",
                tip: "9",
                func: () => numberbtn("9"),
                fontsi: 20,
              ),
              btn(
                text: "×",
                tip: "Multiply",
                func: () => operatorbtn("×"),
                fontsi: 30,
              ),
              btn(
                text: "4",
                tip: "4",
                func: () => numberbtn("4"),
                fontsi: 20,
              ),
              btn(
                text: "5",
                tip: "5",
                func: () => numberbtn("5"),
                fontsi: 20,
              ),
              btn(
                text: "6",
                tip: "6",
                func: () => numberbtn("6"),
                fontsi: 20,
              ),
              btn(
                text: "-",
                tip: "Subtract",
                func: () => operatorbtn("-"),
                fontsi: 30,
              ),
              btn(
                text: "1",
                tip: "1",
                func: () => numberbtn("1"),
                fontsi: 20,
              ),
              btn(
                text: "2",
                tip: "2",
                func: () => numberbtn("2"),
                fontsi: 20,
              ),
              btn(
                text: "3",
                tip: "3",
                func: () => numberbtn("3"),
                fontsi: 20,
              ),
              btn(
                text: "+",
                tip: "Add",
                func: () => operatorbtn("+"),
                fontsi: 30,
              ),
              Tooltip(
                message: "History",
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => HistoryPage())),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 183, 3, 1),
                        borderRadius: BorderRadius.circular(7)),
                    child: Center(
                        child: Icon(
                      Icons.history,
                      size: 30,
                    )),
                  ),
                ),
              ),
              btn(
                text: "0",
                tip: "0",
                func: () => numberbtn("0"),
                fontsi: 20,
              ),
              btn(
                text: ".",
                tip: "Decimal",
                func: () => numberbtn("."),
                fontsi: 30,
              ),
              btn(
                text: "=",
                tip: "Result",
                func: () {
                  setState(() {
                    if (num.isNotEmpty) {
                      _addHistory(num, res);
                      _calculate();
                      textsize = 35;
                      textcolor = Colors.white60;
                      resulttextsize = 50;
                      resulttextcolor = Colors.white;
                      resbool = true;
                    }
                  });
                },
                fontsi: 30,
              ),
            ],
          ),
        ),
      ),
      Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 30, 0, 0),
          child: IconButton(
              onPressed: () {
                _clearHistory();
              },
              icon: Icon(Icons.delete_outline_rounded, color: Colors.white60)),
        ),
      ),
    ]));
  }
}

class btn extends StatelessWidget {
  final String text;
  final String tip;
  final double fontsi;
  final void Function() func;

  const btn({
    Key? key,
    required this.text,
    required this.tip,
    required this.fontsi,
    required this.func,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tip,
      child: InkWell(
        onTap: func,
        child: Container(
          decoration: BoxDecoration(
              color: Color.fromRGBO(255, 183, 3, 1),
              borderRadius: BorderRadius.circular(7)),
          child: Center(
              child: Text(text,
                  style: TextStyle(
                      fontSize: fontsi, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}

class history_widg extends StatelessWidget {
  final String question;
  final String answer;

  const history_widg({
    Key? key,
    required this.question,
    required this.answer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(
          question,
          style: TextStyle(color: Colors.white60),
          textAlign: TextAlign.right,
        ),
        subtitle: Text(
          answer,
          style: TextStyle(color: Colors.white60),
          textAlign: TextAlign.right,
        ));
  }
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final prefs = snapshot.data!;
              final history_cal = prefs.getStringList('history_cal') ?? [];
              final history_res = prefs.getStringList('history_res') ?? [];

              return Container(
                color: Color.fromRGBO(36, 36, 35, 1),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: history_cal.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(history_cal[index],
                            style:
                                TextStyle(color: Colors.white60, fontSize: 18),
                            textAlign: TextAlign.right),
                        subtitle: Text(history_res[index],
                            style:
                                TextStyle(color: Colors.white60, fontSize: 15),
                            textAlign: TextAlign.right),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
            child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 35,
                )),
          )
        ],
      ),
    );
  }
}
