import 'package:flutter/material.dart';

class CustomTextFormFild extends StatelessWidget {
  CustomTextFormFild(
      {required this.hint,
      required this.label,
      this.controller,
      this.keyboardType,
      this.prefixIcon,
      required this.value});
  String hint;
  String label;
  TextInputType? keyboardType;
  TextEditingController? controller;
  Icon? prefixIcon;
  String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.005,
          MediaQuery.of(context).size.width * 0.025,
          MediaQuery.of(context).size.width * 0.005,
          MediaQuery.of(context).size.width * 0.05),
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.width * 0.0025),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return ' your ${this.value} is empty';
          }
          return null;
        },
        keyboardType: keyboardType,
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          hintText: hint,
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
