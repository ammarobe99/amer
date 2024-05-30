import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loading_plus/loading_plus.dart';
import 'package:tamwelkom/app/configs/colors.dart';
import 'package:tamwelkom/data/post_model.dart';
import 'package:tamwelkom/ui/pages/add_post_page.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({
    super.key,
    required this.postModel,
  });

  final PostModel postModel;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late double budget;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('financing')
              .where('postId', isEqualTo: '${widget.postModel.id}')
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            budget =
                num.tryParse(widget.postModel.budget!)?.toDouble() ?? 1000.0;
            if (snapshot.hasData) {
              if (snapshot.data!.docs.isNotEmpty) {
                for (var e in snapshot.data!.docs) {
                  budget -= num.parse(e.data()['price']).toDouble();
                }
              }
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70.0),
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'Project Details',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name: ${widget.postModel.username}',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        SelectableText(
                          'Phone number: ${widget.postModel.phoneNumber}',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          'Title: ${widget.postModel.title}',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          'Content: ${widget.postModel.content}',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          'Location: ${widget.postModel.location}',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          'Date: ${DateFormat('dd/MM/yyyy').format(widget.postModel.dateTime!)}',
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          'Budget: $budget JOD',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        if (budget != 0.0)
                          Center(
                            child: FilledButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    final GlobalKey<FormState> formKey =
                                        GlobalKey<FormState>();
                                    final TextEditingController
                                        financingController =
                                        TextEditingController();
                                    double? profitRatio;
                                    final double bud = budget;
                                    return StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      return AlertDialog(
                                        title: const Text('Finance'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Form(
                                              key: formKey,
                                              child: CustomTextField(
                                                controller: financingController,
                                                textInputType:
                                                    TextInputType.number,
                                                label:
                                                    'Enter the financing amount',
                                                helperText: '1 - $budget',
                                                inputFormatters: [
                                                  NumericalRangeFormatter(
                                                    min: 1,
                                                    max: budget,
                                                  ),
                                                ],
                                                validator: (String? value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Field required';
                                                  }
                                                  return null;
                                                },
                                                onChanged: (String value) {
                                                  final String text =
                                                      value.isEmpty
                                                          ? '0.0'
                                                          : value;
                                                  final double num =
                                                      double.parse(text);
                                                  profitRatio =
                                                      100 / (bud / num);
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                            if (profitRatio != null) ...[
                                              const SizedBox(height: 16.0),
                                              Text(
                                                  'Profit ratio: ${profitRatio!.toStringAsFixed(2)}%'),
                                            ],
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          FilledButton(
                                            onPressed: () async {
                                              if (!formKey.currentState!
                                                  .validate()) return;
                                              LoadingPlusController().show();
                                              try {
                                                await FirebaseFirestore.instance
                                                    .collection('financing')
                                                    .add(
                                                  {
                                                    'postId':
                                                        widget.postModel.id,
                                                    'financierId': FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid,
                                                    'price': financingController
                                                        .text
                                                        .trim(),
                                                    'profitRatio': profitRatio,
                                                  },
                                                );
                                              } catch (_) {}
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                              }

                                              LoadingPlusController().dismiss();
                                            },
                                            child: const Text('Done'),
                                          ),
                                        ],
                                      );
                                    });
                                  },
                                );
                              },
                              child: const Text('Finance'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class NumericalRangeFormatter extends TextInputFormatter {
  final double min;
  final double max;

  NumericalRangeFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == '') {
      return newValue;
    } else if (int.parse(newValue.text) < min) {
      return const TextEditingValue().copyWith(text: min.toStringAsFixed(2));
    } else {
      return int.parse(newValue.text) > max ? oldValue : newValue;
    }
  }
}
