import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:orc/custom_form_fild.dart';

import 'build_image_button.dart';

class BasicInformationPage extends StatefulWidget {
  @override
  _BasicInformationPageState createState() => _BasicInformationPageState();
}

class _BasicInformationPageState extends State<BasicInformationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _landlineController = TextEditingController();
  String? _selectedArea;
  File? _frontImage;
  File? _backImage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _mobileController.dispose();
    _landlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Basic Information'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextFormFild(
                  hint: 'Enter Your First Name',
                  label: 'First Name',
                  value: 'First Name',
                  controller: _firstNameController,
                  keyboardType: TextInputType.name,
                  prefixIcon: Icon(Icons.person),
                ),
                CustomTextFormFild(
                  hint: 'Enter Your Last Name',
                  label: 'Last Name',
                  value: 'Last Name',
                  controller: _lastNameController,
                  keyboardType: TextInputType.name,
                  prefixIcon: Icon(Icons.person),
                ),
                CustomTextFormFild(
                  hint: 'Enter Your Address',
                  label: 'Address',
                  value: 'Address',
                  controller: _addressController,
                  keyboardType: TextInputType.streetAddress,
                  prefixIcon: Icon(Icons.location_on),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.06,
                      MediaQuery.of(context).size.width * 0.025,
                      MediaQuery.of(context).size.width * 0.06,
                      MediaQuery.of(context).size.width * 0.05),
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: MediaQuery.of(context).size.width * 0.0025),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedArea,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedArea = newValue;
                      });
                    },
                    items: ['Area 1', 'Area 2', 'Area 3']
                        .map((area) => DropdownMenuItem(
                              value: area,
                              child: Text(area),
                            ))
                        .toList(),
                    decoration: InputDecoration(labelText: 'Area'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your area';
                      }
                      return null;
                    },
                  ),
                ),
                CustomTextFormFild(
                    hint: 'Enter Ypur LandLine',
                    label: 'LandLine',
                    value: 'LandLine',
                    controller: _landlineController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icon(Icons.home)),
                CustomTextFormFild(
                  hint: 'Enter Your Mobile Number',
                  label: 'Mobile Number',
                  value: 'Mobile Number',
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(Icons.phone),
                ),
                SizedBox(height: 16.0),
                BuildImagePickerButton(
                  buttonText: 'Scan Front ID',
                  source: ImageSource.camera,
                  onImageSelected: _onFrontImageSelected,
                ),
                SizedBox(height: 8.0),
                BuildImagePickerButton(
                    buttonText: 'Scan Back ID',
                    source: ImageSource.camera,
                    onImageSelected: _onFrontImageSelected),
                SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05,
                        vertical: MediaQuery.of(context).size.width * 0.025),
                  ),
                  onPressed: _submit,
                  child: Text('Submit',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onFrontImageSelected(File? image) {
    setState(() {
      _frontImage = image;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Submit basic information and images to Google Drive and Sheets
    await submitToGoogleDrive();

    // Clear form and reset selected images
    _formKey.currentState!.reset();
    setState(() {
      _selectedArea = null;
      _frontImage = null;
      _backImage = null;
    });
  }

  Future<void> submitToGoogleDrive() async {
    // Authenticate with Google Drive and Sheets
    var client = await auth.clientViaUserConsent(
      auth.ClientId('YOUR_CLIENT_ID', 'YOUR_CLIENT_SECRET'),
      [
        'https://www.googleapis.com/auth/drive',
        'https://www.googleapis.com/auth/spreadsheets'
      ],
      (url) async {
        // Open url in browser and wait for user to grant access
      },
    );

    // Upload front image to Google Drive
    var driveApi = drive.DriveApi(client);
    var frontImageFile = await driveApi.files.create(
      drive.File()..name = 'front_image.jpg',
      uploadMedia:
          drive.Media(_frontImage!.openRead(), _frontImage!.lengthSync()),
    );

    // Upload back image to Google Drive
    var backImageFile = await driveApi.files.create(
      drive.File()..name = 'back_image.jpg',
      uploadMedia:
          drive.Media(_backImage!.openRead(), _backImage!.lengthSync()),
    );

    // Store basic information in Google Sheets
    var sheetsApi = sheets.SheetsApi(client);
    var userRecord = [
      DateTime.now().toString(),
      _firstNameController.text,
      _lastNameController.text,
      _addressController.text,
      _selectedArea!,
      _mobileController.text,
      frontImageFile.name!,
      backImageFile.name!,
    ];
    await sheetsApi.spreadsheets.values.append(
      sheets.ValueRange(values: [userRecord]),
      'YOUR_SPREADSHEET_ID',
      'Sheet1',
      valueInputOption: 'USER_ENTERED',
    );
  }
}
