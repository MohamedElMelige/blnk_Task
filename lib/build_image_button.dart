import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BuildImagePickerButton extends StatelessWidget {
  BuildImagePickerButton(
      {required this.buttonText,
      required this.source,
      required this.onImageSelected});
  String buttonText;
  ImageSource source;
  void Function(File?) onImageSelected;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context as BuildContext).size.width * 0.06),
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context as BuildContext).size.width * 0.05,
          vertical: MediaQuery.of(context as BuildContext).size.width * 0.0025),
      child: ElevatedButton(
        onPressed: () async {
          XFile? image = await ImagePicker().pickImage(source: source);
          onImageSelected(image as File?);
        },
        child: Text(buttonText,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
