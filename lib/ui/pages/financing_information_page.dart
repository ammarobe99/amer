import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app/configs/colors.dart';

class FinancingInformationPage extends StatefulWidget {
  const FinancingInformationPage({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  State<FinancingInformationPage> createState() =>
      _FinancingInformationPageState();
}

class _FinancingInformationPageState extends State<FinancingInformationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: const Text('Financing Information'),
        backgroundColor: const Color.fromARGB(255, 243, 240, 249),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('financing')
            .where('postId', isEqualTo: widget.postId)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text('No Data'),
            );
          }
          List financier = [];
          final List<QueryDocumentSnapshot> data = snapshot.data!.docs;
          for (var f in data) {
            financier.add(
              {
                'id': f.get('financierId'),
                'amount': f.get('price'),
              },
            );
            // for (var e in financier) {
            //   if (e['id'] != f.get('financierId')) {
            //     financier.add(
            //       {
            //         'id': f.get('financierId'),
            //         'amount': f.get('price'),
            //       },
            //     );
            //   } else {
            //     e['amount'] = e['amount'] + f.get('price');
            //   }
            // }
          }
          return ListView.builder(
            itemCount: financier.length,
            itemBuilder: (BuildContext context, int index) {
              final Map financierId = financier.elementAt(index);
              return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance
                      .collection('userInfo')
                      .where(
                        'userId',
                        isEqualTo: financierId['id'],
                      )
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        !snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final list = snapshot.data!.docs;
                    if (list.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final data = snapshot.data!.docs.first.data();
                    return Card(
                      child: ListTile(
                        title: Text(data['username']),
                        trailing: Text('${financierId['amount']}'),
                      ),
                    );
                  });
            },
          );
        },
      ),
    );
  }
}
