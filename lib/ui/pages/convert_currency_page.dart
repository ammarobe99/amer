import 'package:flutter/material.dart';
import 'package:tamwelkom/data/rate.dart';
import 'package:tamwelkom/ui/widgets/currency_converter.dart';

import '../../services/fetchrates.dart';

class ConvertCurrency extends StatefulWidget {
  const ConvertCurrency({super.key});

  @override
  ConvertCurrencyState createState() => ConvertCurrencyState();
}

class ConvertCurrencyState extends State<ConvertCurrency> {
  //Initial Variables

  late Future<RatesModel> result;
  late Future<Map> allcurrencies;
  final formkey = GlobalKey<FormState>();

  //Getting RatesModel and All Currencies
  @override
  void initState() {
    super.initState();
    setState(() {
      result = fetchrates();
      allcurrencies = fetchcurrencies();
    });
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: h,
        width: w,
        padding: const EdgeInsets.all(13),
        margin: const EdgeInsets.only(top: 60),
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: FutureBuilder<RatesModel>(
              future: result,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Center(
                  child: FutureBuilder<Map>(
                      future: allcurrencies,
                      builder: (context, currSnapshot) {
                        if (currSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CurrencyConverter(
                              currencies: currSnapshot.data!,
                              rates: snapshot.data!.rates,
                            ),
                          ],
                        );
                      }),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
