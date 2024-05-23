import 'package:flutter/material.dart';
import 'package:social_media_app/data/rate.dart';
import 'package:social_media_app/searvis/fetchrates.dart';
import 'package:social_media_app/ui/pages/currrrrr.dart';

class convertCurrency extends StatefulWidget {
  const convertCurrency({Key? key}) : super(key: key);

  @override
  _convertCurrencyState createState() => _convertCurrencyState();
}

class _convertCurrencyState extends State<convertCurrency> {
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
        padding: EdgeInsets.all(13),
        margin: EdgeInsets.only(top: 60),
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: FutureBuilder<RatesModel>(
              future: result,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return Center(
                  child: FutureBuilder<Map>(
                      future: allcurrencies,
                      builder: (context, currSnapshot) {
                        if (currSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnyToAny(
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
