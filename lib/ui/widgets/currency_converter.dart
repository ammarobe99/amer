import 'package:flutter/material.dart';
import 'package:tamwelkom/services/fetchrates.dart';

class CurrencyConverter extends StatefulWidget {
  final Map<String, double> rates;
  final Map currencies;
  const CurrencyConverter(
      {super.key, required this.rates, required this.currencies});

  @override
  CurrencyConverterState createState() => CurrencyConverterState();
}

class CurrencyConverterState extends State<CurrencyConverter> {
  TextEditingController amountController = TextEditingController();

  String dropdownValue1 = 'USD';
  String dropdownValue2 = 'JOD';
  String answer = 'Converted Currency will be shown here';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Convert Any Currency',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 20),

            //TextFields for Entering USD
            TextFormField(
              key: const ValueKey('amount'),
              controller: amountController,
              decoration: const InputDecoration(hintText: 'Enter Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: dropdownValue1,
                    icon: const Icon(Icons.arrow_drop_down_rounded),
                    iconSize: 24,
                    elevation: 16,
                    isExpanded: true,
                    underline: Container(
                      height: 2,
                      color: Colors.grey.shade400,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue1 = newValue!;
                      });
                    },
                    items: widget.currencies.keys
                        .toSet()
                        .toList()
                        .map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text('To')),
                Expanded(
                  child: DropdownButton<String>(
                    value: dropdownValue2,
                    icon: const Icon(Icons.arrow_drop_down_rounded),
                    iconSize: 24,
                    elevation: 16,
                    isExpanded: true,
                    underline: Container(
                      height: 2,
                      color: Colors.grey.shade400,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue2 = newValue!;
                      });
                    },
                    items: widget.currencies.keys
                        .toSet()
                        .toList()
                        .map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    answer =
                        '${amountController.text} $dropdownValue1 = ${convertany(widget.rates, amountController.text, dropdownValue1, dropdownValue2)} $dropdownValue2';
                  });
                },
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).primaryColor)),
                child: const Text('Convert'),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const SizedBox(height: 10),
            Text(answer)
          ],
        ),
      ),
    );
  }
}
