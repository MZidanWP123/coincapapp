import 'dart:convert';

import 'package:coincapapp/pages/home_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:coincapapp/services/http_service.dart';
import 'package:get_it/get_it.dart';
import 'package:data_table_2/data_table_2.dart';

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
          .then((response) => response?.data)
          .catchError((error) {
        print("error saat fetch data : $error");
        return null;
      }),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        if (snapshot.hasData) {
          List<dynamic> data = snapshot.data;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.85,
              child: DataTable2(
                columnSpacing: 25,
                horizontalMargin: 10,
                minWidth: 800,
                columns: const [
                  DataColumn2(label: Text('Coin', style: TextStyle(color: Colors.white),), size: ColumnSize.L),
                  DataColumn(label: Text('Price', style: TextStyle(color: Colors.white),)),
                  DataColumn(label: Text('Market Cap', style: TextStyle(color: Colors.white),)),
                  DataColumn(label: Text('Change 24h', style: TextStyle(color: Colors.white),)),
                ],
                rows: data.map<DataRow>((coin) {
                  return DataRow(cells: [
                    DataCell(
                      GestureDetector(
                        onDoubleTap: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (BuildContext _context){
                              return HomePage(coinId: coin['id']);
                            }),
                          );
                        },
                      child: Row(
                        children: [
                          Image.network(coin['image'], width: 25),
                          const SizedBox(width: 15),
                          SizedBox(
                            width: 120,
                            child: Text(
                              coin['name'],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )),
                    DataCell(Text('\$${coin['current_price'] ?? 'N/A'}', style: TextStyle(color: Colors.white),)),
                    DataCell(Text('\$${coin['market_cap'] ?? 'N/A'}', style: TextStyle(color: Colors.white),)),
                    DataCell(Text(
                      '${(coin['price_change_percentage_24h'] ?? 0).toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: (coin['price_change_percentage_24h'] ?? 0) >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
        } else {
          return const Center(child: Text("Tidak ada data."));
        }
      },
    );
  }
}
