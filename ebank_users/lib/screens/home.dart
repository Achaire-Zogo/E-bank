import 'package:ebank_users/urls/Urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _userName;
  double? _soldeTotal;
  List<dynamic> _listBanque = [];

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  _getUserInfo() async {
    var response = await http.get(Uri.parse(Urls.userProfile));
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _userName = data['username'];
        _soldeTotal = data['solde_total'];
        _listBanque = data['banque'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compte bancaire'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              _userName ?? '',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Solde total : ${_soldeTotal?.toStringAsFixed(2) ?? ''} FCFA',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 40),
            Text(
              'Mes banques',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _listBanque.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_listBanque[index]['nom']),
                    subtitle: Text(_listBanque[index]['numero']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
