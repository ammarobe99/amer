import 'package:http/http.dart' as http;
import 'package:tamwelkom/app/configs/key.dart';
import 'package:tamwelkom/data/all_currencies.dart';
import 'package:tamwelkom/data/rate.dart';

Future<RatesModel> fetchrates() async {
  var response = await http.get(Uri.parse(
      'https://openexchangerates.org/api/latest.json?base=USD&app_id=$key'));
  final result = ratesModelFromJson(response.body);
  return result;
}

Future<Map> fetchcurrencies() async {
  var response = await http.get(Uri.parse(
      'https://openexchangerates.org/api/currencies.json?app_id=$key'));
  final allCurrencies = allCurrenciesFromJson(response.body);
  return allCurrencies;
}

String convertany(Map exchangeRates, String amount, String currencybase,
    String currencyfinal) {
  String output = (double.parse(amount) /
          exchangeRates[currencybase] *
          exchangeRates[currencyfinal])
      .toStringAsFixed(2)
      .toString();

  return output;
}
