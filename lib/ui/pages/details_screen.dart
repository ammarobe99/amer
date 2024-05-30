import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loading_plus/loading_plus.dart';
import 'package:tamwelkom/app/configs/colors.dart';
import 'package:tamwelkom/data/post_model.dart';

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
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('financing')
            .where('postId', isEqualTo: widget.postModel.id)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          budget = num.tryParse(widget.postModel.budget!)?.toDouble() ?? 1000.0;
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            for (var e in snapshot.data!.docs) {
              budget -= num.parse(e.data()['price']).toDouble();
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16.0),
                const Text(
                  'Project Details',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                DetailCard(
                    title: 'Name', value: '${widget.postModel.username}'),
                DetailCard(
                    title: 'Phone number',
                    value: '${widget.postModel.phoneNumber}'),
                DetailCard(title: 'Title', value: '${widget.postModel.title}'),
                DetailCard(
                    title: 'Content', value: '${widget.postModel.content}'),
                DetailCard(
                    title: 'Location', value: '${widget.postModel.location}'),
                DetailCard(
                  title: 'Date',
                  value: DateFormat('dd/MM/yyyy')
                      .format(widget.postModel.dateTime!),
                ),
                DetailCard(title: 'Budget', value: '$budget JOD'),
                const SizedBox(height: 16.0),
                if (budget > 0)
                  Center(
                    child: FilledButton(
                      // style: ElevatedButton.styleFrom(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 24.0, vertical: 12.0),
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(10.0),
                      //   ),
                      //   backgroundColor: AppColors.primaryColor,
                      // ),
                      onPressed: () => _showFinanceDialog(context),
                      child: const Text('Finance'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFinanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final GlobalKey<FormState> formKey = GlobalKey<FormState>();
        final TextEditingController financingController =
            TextEditingController();
        double? profitRatio;
        final double bud = budget;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: const Text('Finance'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: formKey,
                    child: CustomTextField(
                      controller: financingController,
                      textInputType: TextInputType.number,
                      label: 'Enter the financing amount',
                      helperText: '1 - $budget',
                      inputFormatters: [
                        NumericalRangeFormatter(min: 1, max: budget),
                      ],
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Field required';
                        }
                        return null;
                      },
                      onChanged: (String value) {
                        final String text = value.isEmpty ? '0.0' : value;
                        final double num = double.parse(text);
                        profitRatio = 100 / (bud / num);
                        setState(() {});
                      },
                    ),
                  ),
                  if (profitRatio != null) ...[
                    const SizedBox(height: 16.0),
                    Text('Profit ratio: ${profitRatio!.toStringAsFixed(2)}%'),
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
                  // style: ElevatedButton.styleFrom(
                  //   // backgroundColor: AppColors.primaryColor,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(10.0),
                  //   ),
                  // ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    LoadingPlusController().show();
                    try {
                      await FirebaseFirestore.instance
                          .collection('financing')
                          .add({
                        'postId': widget.postModel.id,
                        'financierId': FirebaseAuth.instance.currentUser!.uid,
                        'price': financingController.text.trim(),
                        'profitRatio': profitRatio,
                      });
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
          },
        );
      },
    );
  }
}

class DetailCard extends StatelessWidget {
  final String title;
  final String value;

  const DetailCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType textInputType;
  final String label;
  final String helperText;
  final List<TextInputFormatter> inputFormatters;
  final String? Function(String?) validator;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.textInputType,
    required this.label,
    required this.helperText,
    required this.inputFormatters,
    required this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: textInputType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}

class NumericalRangeFormatter extends TextInputFormatter {
  final double min;
  final double max;

  NumericalRangeFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    } else if (double.parse(newValue.text) < min) {
      return const TextEditingValue().copyWith(text: min.toStringAsFixed(2));
    } else {
      return double.parse(newValue.text) > max ? oldValue : newValue;
    }
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:loading_plus/loading_plus.dart';
// import 'package:tamwelkom/app/configs/colors.dart';
// import 'package:tamwelkom/data/post_model.dart';
// import 'package:tamwelkom/ui/pages/add_post_page.dart';
//
// class DetailsScreen extends StatefulWidget {
//   const DetailsScreen({
//     super.key,
//     required this.postModel,
//   });
//
//   final PostModel postModel;
//
//   @override
//   State<DetailsScreen> createState() => _DetailsScreenState();
// }
//
// class _DetailsScreenState extends State<DetailsScreen> {
//   late double budget;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.whiteColor,
//       appBar: AppBar(
//         title: const Text('Details'),
//         backgroundColor: Colors.transparent,
//       ),
//       body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream: FirebaseFirestore.instance
//             .collection('financing')
//             .where('postId', isEqualTo: '${widget.postModel.id}')
//             .snapshots(),
//         builder: (BuildContext context,
//             AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//           budget = num.tryParse(widget.postModel.budget!)?.toDouble() ?? 1000.0;
//           if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
//             for (var e in snapshot.data!.docs) {
//               budget -= num.parse(e.data()['price']).toDouble();
//             }
//           }
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 16.0),
//                 const Text(
//                   'Project Details',
//                   style: TextStyle(
//                     fontSize: 16.0,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 Card(
//                   elevation: 2.0,
//                   margin: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         DetailItem(
//                             title: 'Name',
//                             value: '${widget.postModel.username}'),
//                         DetailItem(
//                             title: 'Phone number',
//                             value: '${widget.postModel.phoneNumber}'),
//                         DetailItem(
//                             title: 'Title', value: '${widget.postModel.title}'),
//                         DetailItem(
//                             title: 'Content',
//                             value: '${widget.postModel.content}'),
//                         DetailItem(
//                             title: 'Location',
//                             value: '${widget.postModel.location}'),
//                         DetailItem(
//                           title: 'Date',
//                           value: DateFormat('dd/MM/yyyy')
//                               .format(widget.postModel.dateTime!),
//                         ),
//                         DetailItem(title: 'Budget', value: '$budget JOD'),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 if (budget > 0)
//                   Center(
//                     child: FilledButton(
//                       onPressed: () => _showFinanceDialog(context),
//                       child: const Text('Finance'),
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   void _showFinanceDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) {
//         final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//         final TextEditingController financingController =
//             TextEditingController();
//         double? profitRatio;
//         final double bud = budget;
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return AlertDialog(
//               title: const Text('Finance'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Form(
//                     key: formKey,
//                     child: CustomTextField(
//                       controller: financingController,
//                       textInputType: TextInputType.number,
//                       label: 'Enter the financing amount',
//                       helperText: '1 - $budget',
//                       inputFormatters: [
//                         NumericalRangeFormatter(min: 1, max: budget),
//                       ],
//                       validator: (String? value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Field required';
//                         }
//                         return null;
//                       },
//                       onChanged: (String value) {
//                         final String text = value.isEmpty ? '0.0' : value;
//                         final double num = double.parse(text);
//                         profitRatio = 100 / (bud / num);
//                         setState(() {});
//                       },
//                     ),
//                   ),
//                   if (profitRatio != null) ...[
//                     const SizedBox(height: 16.0),
//                     Text('Profit ratio: ${profitRatio!.toStringAsFixed(2)}%'),
//                   ],
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Cancel'),
//                 ),
//                 FilledButton(
//                   onPressed: () async {
//                     if (!formKey.currentState!.validate()) return;
//                     LoadingPlusController().show();
//                     try {
//                       await FirebaseFirestore.instance
//                           .collection('financing')
//                           .add({
//                         'postId': widget.postModel.id,
//                         'financierId': FirebaseAuth.instance.currentUser!.uid,
//                         'price': financingController.text.trim(),
//                         'profitRatio': profitRatio,
//                       });
//                     } catch (_) {}
//                     if (context.mounted) {
//                       Navigator.pop(context);
//                     }
//                     LoadingPlusController().dismiss();
//                   },
//                   child: const Text('Done'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }
//
// class DetailItem extends StatelessWidget {
//   final String title;
//   final String value;
//
//   const DetailItem({super.key, required this.title, required this.value});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$title: ',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 16.0),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class NumericalRangeFormatter extends TextInputFormatter {
//   final double min;
//   final double max;
//
//   NumericalRangeFormatter({required this.min, required this.max});
//
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     if (newValue.text.isEmpty) {
//       return newValue;
//     } else if (double.parse(newValue.text) < min) {
//       return const TextEditingValue().copyWith(text: min.toStringAsFixed(2));
//     } else {
//       return double.parse(newValue.text) > max ? oldValue : newValue;
//     }
//   }
// }

/// *************
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:loading_plus/loading_plus.dart';
// import 'package:tamwelkom/app/configs/colors.dart';
// import 'package:tamwelkom/data/post_model.dart';
// import 'package:tamwelkom/ui/pages/add_post_page.dart';
//
// class DetailsScreen extends StatefulWidget {
//   const DetailsScreen({
//     super.key,
//     required this.postModel,
//   });
//
//   final PostModel postModel;
//
//   @override
//   State<DetailsScreen> createState() => _DetailsScreenState();
// }
//
// class _DetailsScreenState extends State<DetailsScreen> {
//   late double budget;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.whiteColor,
//       body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//           stream: FirebaseFirestore.instance
//               .collection('financing')
//               .where('postId', isEqualTo: '${widget.postModel.id}')
//               .snapshots(),
//           builder: (BuildContext context,
//               AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//             budget =
//                 num.tryParse(widget.postModel.budget!)?.toDouble() ?? 1000.0;
//             if (snapshot.hasData) {
//               if (snapshot.data!.docs.isNotEmpty) {
//                 for (var e in snapshot.data!.docs) {
//                   budget -= num.parse(e.data()['price']).toDouble();
//                 }
//               }
//             }
//
//             return SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 70.0),
//                   const Padding(
//                     padding: EdgeInsets.only(left: 20),
//                     child: Text(
//                       'Project Details',
//                       style:
//                           TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Name: ${widget.postModel.username}',
//                           style: const TextStyle(
//                             fontSize: 16.0,
//                           ),
//                         ),
//                         SelectableText(
//                           'Phone number: ${widget.postModel.phoneNumber}',
//                           style: const TextStyle(
//                             fontSize: 16.0,
//                           ),
//                         ),
//                         Text(
//                           'Title: ${widget.postModel.title}',
//                           style: const TextStyle(
//                             fontSize: 16.0,
//                           ),
//                         ),
//                         Text(
//                           'Content: ${widget.postModel.content}',
//                           style: const TextStyle(
//                             fontSize: 16.0,
//                           ),
//                         ),
//                         Text(
//                           'Location: ${widget.postModel.location}',
//                           style: const TextStyle(
//                             fontSize: 16.0,
//                           ),
//                         ),
//                         Text(
//                           'Date: ${DateFormat('dd/MM/yyyy').format(widget.postModel.dateTime!)}',
//                           softWrap: true,
//                           style: const TextStyle(
//                             fontSize: 16.0,
//                           ),
//                         ),
//                         Text(
//                           'Budget: $budget JOD',
//                           style: const TextStyle(
//                             fontSize: 16.0,
//                           ),
//                         ),
//                         const SizedBox(height: 16.0),
//                         if (budget != 0.0)
//                           Center(
//                             child: FilledButton(
//                               onPressed: () {
//                                 showDialog(
//                                   context: context,
//                                   builder: (ctx) {
//                                     final GlobalKey<FormState> formKey =
//                                         GlobalKey<FormState>();
//                                     final TextEditingController
//                                         financingController =
//                                         TextEditingController();
//                                     double? profitRatio;
//                                     final double bud = budget;
//                                     return StatefulBuilder(builder:
//                                         (BuildContext context,
//                                             StateSetter setState) {
//                                       return AlertDialog(
//                                         title: const Text('Finance'),
//                                         content: Column(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Form(
//                                               key: formKey,
//                                               child: CustomTextField(
//                                                 controller: financingController,
//                                                 textInputType:
//                                                     TextInputType.number,
//                                                 label:
//                                                     'Enter the financing amount',
//                                                 helperText: '1 - $budget',
//                                                 inputFormatters: [
//                                                   NumericalRangeFormatter(
//                                                     min: 1,
//                                                     max: budget,
//                                                   ),
//                                                 ],
//                                                 validator: (String? value) {
//                                                   if (value == null ||
//                                                       value.isEmpty) {
//                                                     return 'Field required';
//                                                   }
//                                                   return null;
//                                                 },
//                                                 onChanged: (String value) {
//                                                   final String text =
//                                                       value.isEmpty
//                                                           ? '0.0'
//                                                           : value;
//                                                   final double num =
//                                                       double.parse(text);
//                                                   profitRatio =
//                                                       100 / (bud / num);
//                                                   setState(() {});
//                                                 },
//                                               ),
//                                             ),
//                                             if (profitRatio != null) ...[
//                                               const SizedBox(height: 16.0),
//                                               Text(
//                                                   'Profit ratio: ${profitRatio!.toStringAsFixed(2)}%'),
//                                             ],
//                                           ],
//                                         ),
//                                         actions: [
//                                           TextButton(
//                                             onPressed: () {
//                                               Navigator.pop(context);
//                                             },
//                                             child: const Text('Cancel'),
//                                           ),
//                                           FilledButton(
//                                             onPressed: () async {
//                                               if (!formKey.currentState!
//                                                   .validate()) return;
//                                               LoadingPlusController().show();
//                                               try {
//                                                 await FirebaseFirestore.instance
//                                                     .collection('financing')
//                                                     .add(
//                                                   {
//                                                     'postId':
//                                                         widget.postModel.id,
//                                                     'financierId': FirebaseAuth
//                                                         .instance
//                                                         .currentUser!
//                                                         .uid,
//                                                     'price': financingController
//                                                         .text
//                                                         .trim(),
//                                                     'profitRatio': profitRatio,
//                                                   },
//                                                 );
//                                               } catch (_) {}
//                                               if (context.mounted) {
//                                                 Navigator.pop(context);
//                                               }
//
//                                               LoadingPlusController().dismiss();
//                                             },
//                                             child: const Text('Done'),
//                                           ),
//                                         ],
//                                       );
//                                     });
//                                   },
//                                 );
//                               },
//                               child: const Text('Finance'),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),
//     );
//   }
// }
//
// class NumericalRangeFormatter extends TextInputFormatter {
//   final double min;
//   final double max;
//
//   NumericalRangeFormatter({required this.min, required this.max});
//
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     if (newValue.text == '') {
//       return newValue;
//     } else if (int.parse(newValue.text) < min) {
//       return const TextEditingValue().copyWith(text: min.toStringAsFixed(2));
//     } else {
//       return int.parse(newValue.text) > max ? oldValue : newValue;
//     }
//   }
// }
