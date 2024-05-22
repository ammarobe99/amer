import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_plus/loading_plus.dart';
import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/data/post_model.dart';
import '../../app/configs/theme.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _HomeState();
}

class _HomeState extends State<AddPostPage> {
  // late final RecorderController recorderController;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  // final TextEditingController _naming = TextEditingController();

  // late String? path;
  // late String? path2;
  // String? musicFile;
  // bool isRecording = false;
  // bool isRecordingCompleted = false;
  // bool isLoading = true;
  // late Directory appDirectory;
  final FirebaseAuth auth = FirebaseAuth.instance;
  // final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  // final _isHours = true;
  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController locationController;
  late TextEditingController budgetController;
  late TextEditingController expiryDateController;
  late TextEditingController phoneNumberController;
  DateTime? expiryDate;
  @override
  void initState() {
    titleController = TextEditingController();
    contentController = TextEditingController();
    locationController = TextEditingController();
    budgetController = TextEditingController();
    expiryDateController = TextEditingController();
    phoneNumberController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    locationController.dispose();
    budgetController.dispose();
    expiryDateController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 24,
            color: AppColors.blackColor,
          ),
        ),
        title: Text(
          'Sumbit Post',
          style: AppTheme.blackTextStyle.copyWith(
            fontSize: 18,
            fontWeight: AppTheme.bold,
          ),
        ),
      ),
      backgroundColor: AppColors.whiteColor,
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            physics: const ClampingScrollPhysics(),
            children: [
              CustomTextField(
                controller: titleController,
                label: 'Title',
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Title required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                controller: contentController,
                label: 'Content',
                textInputAction: TextInputAction.next,
                maxLines: 5,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Content required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                controller: locationController,
                label: 'Location',
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Location required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                controller: budgetController,
                label: 'Budget',
                textInputAction: TextInputAction.next,
                textInputType: TextInputType.number,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Budget required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                controller: phoneNumberController,
                label: 'Phone number',
                textInputAction: TextInputAction.done,
                textInputType: TextInputType.phone,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              InkWell(
                onTap: () async {
                  final DateTime? dateTime = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (dateTime == null) return;
                  expiryDateController.text =
                      DateFormat('dd/MM/yyyy').format(dateTime);
                  expiryDate = dateTime;
                },
                child: CustomTextField(
                  controller: expiryDateController,
                  label: 'Expiry Date',
                  readOnly: true,
                  ignorePointers: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Expiry Date required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 32.0),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  submitPost();
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submitPost() async {
    final ScaffoldMessengerState scaffoldMessengerState =
        ScaffoldMessenger.of(context);
    final NavigatorState navigatorState = Navigator.of(context);
    try {
      final PostModel postModel = PostModel(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        location: locationController.text.trim(),
        budget: budgetController.text.trim(),
        dateTime: expiryDate,
        userId: FirebaseAuth.instance.currentUser!.uid,
        phoneNumber: phoneNumberController.text.trim(),
      );

      LoadingPlusController().show();
      await FirebaseFirestore.instance.collection('posts').add(
            postModel.toJson(),
          );
      navigatorState.pop();
      scaffoldMessengerState.showSnackBar(
        const SnackBar(
          content: Text('Post added'),
        ),
      );

      LoadingPlusController().dismiss();
    } catch (_) {
      LoadingPlusController().dismiss();
      scaffoldMessengerState.showSnackBar(
        const SnackBar(
          content: Text('Something went wrong, try again!'),
        ),
      );
    }
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.textInputAction,
    this.textInputType,
    this.enabled = true,
    this.readOnly = false,
    this.ignorePointers,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final bool enabled;
  final bool readOnly;
  final bool? ignorePointers;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      keyboardType: textInputType,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      ignorePointers: ignorePointers,
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: const OutlineInputBorder(),
        disabledBorder: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primaryColor,
          ),
        ),
      ),
      onTapOutside: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      validator: validator,
    );
  }
}
