import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class homescreen extends StatefulWidget {
  const homescreen({super.key});

  @override
  State<homescreen> createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {
  void initState() {
    _getCurrencies();
  }

  Future<void> _getCurrencies() async {
    final response = await http
        .get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));
    var data = json.decode(response.body);
    setState(() {
      /*
      1) data['rates] is the variabele holding the json response.
      2) "as Map<String, dynamic>" This Casts tells the dart that data['rates'] must be treated as Map where keys are String 
       dynamic values
      3)  .keys: Retrieves all the keys from the map, which are the currency codes (e.g., 'EUR', 'JPY').
      4) .toList(): Converts these keys from an iterable (a collection that can be iterated over) into a list. 
      5) This list is then assigned to the currencies variable.
      */
      currencies = (data['rates'] as Map<String, dynamic>).keys.toList();
      rate = data['rates'][toCurrency];
    });
  }

  Future<void> _getRates() async {
    final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/$fromCurrency'));
    var data = json.decode(response.body);
    setState(() {
      rate = data['rates'][toCurrency];
    });
  }

  void SwapCurrencies() {
    String temp = fromCurrency;
    fromCurrency = toCurrency;
    toCurrency = temp;
    _getRates();
  }

  @override
  String fromCurrency = 'Euro';
  String toCurrency = 'USD';
  double rate = 0.0;
  double Total = 0.0;
  List<String> currencies = [];
  TextEditingController _controller = TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1d2630),
      appBar: AppBar(
        backgroundColor: Color(0xFF1d2630),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Center(
            child: Text(
          'Currency Converter',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(top: 70),
          child: Column(
            children: [
              Center(
                  child: Image(
                image: const AssetImage(
                  'assets/Currency.png',
                ),
                height: MediaQuery.of(context).size.height * 0.3,
              )),
              const SizedBox(
                height: 100,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 280),
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white))),
                  onChanged: (value) {
                    if (value != '') {
                      setState(() {
                        double amount = double.parse(value);
                        Total = amount * rate;
                        _getRates();
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      child: DropdownButton<String>(
                        style: const TextStyle(color: Colors.white),
                        isExpanded: true,
                        value: fromCurrency,
                        items: currencies.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newvalue) {
                          setState(() {
                            fromCurrency = newvalue!;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.swap_horiz),
                      onPressed: SwapCurrencies,
                      iconSize: 40,
                      color: Colors.white,
                    ),
                    SizedBox(
                      child: DropdownButton<String>(
                        style: const TextStyle(color: Colors.white),
                        isExpanded: true,
                        value: toCurrency,
                        items: currencies.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newvalue) {
                          setState(() {
                            toCurrency = newvalue!;
                            _getRates();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Rate $rate',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                '${Total.toStringAsFixed(3)}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
            ],
          ),
        )),
      ),
    );
  }
}
