import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:driev/app_services/customer_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../../../app_storages/secure_storage.dart';
import '../../../app_themes/app_colors.dart';
import '../../../app_utils/app_loading/alert_services.dart';

class DocumentUploadAlert extends StatelessWidget {
  final dynamic document;
  final Function(bool) onDataReceived;
  const DocumentUploadAlert({
    super.key,
    this.document,
    required this.onDataReceived,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      contentPadding: const EdgeInsets.all(25),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      size: 40,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      uploadAction(ImageSource.camera);
                    },
                  ),
                  const Text(
                    'Camera',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(width: 25),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.perm_media_outlined,
                      size: 40,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (document['id'] == "selfi") {
                        uploadAction(ImageSource.gallery);
                      } else {
                        _pickFile();
                      }
                    },
                  ),
                  const Text(
                    'Gallery',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  uploadAction(ImageSource src) async {
    final ImagePicker picker = ImagePicker();
    XFile? photo = await picker.pickImage(source: src);
    if (photo != null) {
      _cropImage(File(photo.path));
    }
  }

  _cropImage(pickedFile) async {
    late String path;
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      androidUiSettings: const AndroidUiSettings(
        toolbarTitle: 'Crop your Photo',
        toolbarColor: AppColors.primary,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
      iosUiSettings: const IOSUiSettings(
        title: 'Crop your Photo',
      ),
    );
    if (croppedFile != null) {
      path = croppedFile.path;
      compress(File(path));
    }
  }

  compress(File file) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      '${file.path}.jpg',
      quality: 50,
    );
    if (result != null) {
      var newPath = result.path;
      final file1 = File(newPath);
      fileUpload(file1);
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      String? filePath = result.files.single.path;
      final String fileExtension = extension(filePath!);
      if (fileExtension.toString() != ".pdf") {
        /// IMAGES
        _cropImage(File(filePath));
      } else {
        /// PDF
        fileUpload(File(filePath));
      }
    } else {}
  }

  fileUpload(File file) async {
    SecureStorage secureStorage = SecureStorage();
    CustomerService customerService = CustomerService();
    AlertServices alertServices = AlertServices();
    String mobile = secureStorage.get("mobile");

    alertServices.showLoading();
    var request = {
      "contact": mobile.toString(),
      "fileName": document['id'].toString()
    };
    print("request $request");
    final String fileExtension = extension(file.path);
    int lastIndex = file.path.lastIndexOf('/');
    String result1 = file.path.substring(0, lastIndex + 1);
    file.rename("$result1${document['id'].toString()}$fileExtension").then((_) {
      print('File renamed successfully.');
    }).catchError((error) {
      print('Error renaming file: $error');
    });
    final uploadFile =
        File("$result1${document['id'].toString()}$fileExtension");
    print("uploadFile $uploadFile");
    customerService.uploadImage(uploadFile, request).then((response) async {
      alertServices.hideLoading();
      var res = jsonDecode(response);
      print("res $res");
      if (res != null) {
        onDataReceived(true);
      } else {
        onDataReceived(false);
      }
    });
  }
}
