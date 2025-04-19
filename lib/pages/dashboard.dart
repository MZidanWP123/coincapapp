import 'dart:convert';

import 'package:coincapapp/pages/home_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:coincapapp/services/http_service.dart';
import 'package:get_it/get_it.dart';

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard> {
  late double _deviceHeight, _deviceWidth;

  _DashboardState();
  HttpService? _http;

  @override
  void initState() {
    super.initState();
    _http = GetIt.instance.get<HttpService>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Crypto Coins",
          style: TextStyle(fontSize: 25),
          textAlign: TextAlign.end,
        ),
        backgroundColor: Colors.blueGrey,
        toolbarHeight: _deviceHeight * 0.10,
      ),
      body: _coinList(),
    );
  }

  Widget _coinList() {
    return FutureBuilder(
      future: _http!
          .get(
              "coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false")
          .then((response) {
        if (response != null) {
          return response.data;
        } else {
          return null;
        }
      }).catchError((error) {
        print("error saat fetch data : $error");
        return null;
      }),
      builder: (BuildContext _context, AsyncSnapshot _snapshot) {
        if (_snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (_snapshot.hasData) {
          List<dynamic> _data = _snapshot.data;
          return ListView.builder(
            itemCount: _data.length,
            itemBuilder: (context, index) {
              var coin = _data[index];
              return GestureDetector(
                onDoubleTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext _context) {
                    return HomePage(coinId: coin['id']);
                  }));
                },
                child: ListTile(
                  title: Text(coin['name'] ?? 'Unknown'),
                  subtitle: Text('\$${coin['current_price'] ?? 0}'),
                  leading: Image.network(coin['image'] ?? ''),
                ),
              );
            },
          );
        } else if (_snapshot.hasError) {
          return Center(child: Text("Terjadi kesalahan: ${_snapshot.error}"));
        } else {
          return const Center(child: Text("Tidak ada data."));
        }
      },
    );
  }
}
