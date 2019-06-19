import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=be064a50";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.green, primaryColor: Colors.white),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dolarController = TextEditingController();
  final realController = TextEditingController();
  final pesoController = TextEditingController();

  double ars;
  double usd;

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    pesoController.text = "";
  }

  void _realChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / usd).toStringAsFixed(2);
    pesoController.text = (real / ars).toStringAsFixed(2);
  }

  void _pesoChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double ars = double.parse(text);
    realController.text = (ars * this.ars).toStringAsFixed(2);
    dolarController.text = (ars * this.ars / usd).toStringAsFixed(2);

  }

  void _dolarChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double usd = double.parse(text);
    realController.text = (usd * this.usd).toStringAsFixed(2);
    pesoController.text = (usd * this.usd / ars).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Convertidor de la plata"),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text("Carregando dados...",
                        style: TextStyle(color: Colors.green, fontSize: 25.0),
                        textAlign: TextAlign.center),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Erro ao carregar",
                          style: TextStyle(color: Colors.green, fontSize: 25.0),
                          textAlign: TextAlign.center),
                    );
                  } else {
                    ars = snapshot.data["results"]["currencies"]["ARS"]["buy"];
                    usd = snapshot.data["results"]["currencies"]["USD"]["buy"];
                    return SingleChildScrollView(
                        padding: EdgeInsets.all(30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Icon(Icons.departure_board,
                                size: 150.0, color: Colors.green),
                            Divider(),
                            Divider(),
                            Divider(),
                            buildTextField(
                                "Real", "R\$ ", realController, _realChanged),
                            Divider(),
                            buildTextField(
                                "Peso", "ARS\$ ", pesoController, _pesoChanged),
                            Divider(),
                            buildTextField("Dolar", "US\$ ", dolarController,
                                _dolarChanged),
                          ],
                        ));
                  }
              }
            }));
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.green, fontSize: 25.0
    ),
    onChanged: f,
    keyboardType: TextInputType.number,
  );

}

