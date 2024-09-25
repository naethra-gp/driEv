import 'dart:convert';
import 'dart:io';

import 'package:driev/app_storages/secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../../../app_services/index.dart';
import '../../../app_themes/app_colors.dart';
import '../../../app_themes/custom_theme.dart';
import '../../../app_utils/app_loading/alert_services.dart';

class FileUploadForm extends StatefulWidget {
  final String title;
  final String documentId;
  final bool required;
  final bool? gallery;
  final bool? camera;
  final String? helperText;
  final FormFieldValidator? validator;
  final IconData? prefixIcon;
  final Function(String) onDataReceived;
  final TextEditingController controller;
  const FileUploadForm({
    super.key,
    required this.title,
    required this.documentId,
    required this.required,
    this.gallery,
    this.camera,
    this.helperText,
    this.validator,
    this.prefixIcon,
    required this.onDataReceived,
    required this.controller,
  });

  @override
  State<FileUploadForm> createState() => _FileUploadFormState();
}

class _FileUploadFormState extends State<FileUploadForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          enableInteractiveSelection: false,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.validator,
          readOnly: true,
          style: CustomTheme.formFieldStyle,
          decoration: InputDecoration(
            hintText: widget.title,
            helperText: widget.helperText,
            errorStyle: const TextStyle(
              color: Colors.redAccent,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
            hintStyle: CustomTheme.formHintStyle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Color(0xffD2D2D2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xffD2D2D2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xffD2D2D2)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.only(left: 15),
            isDense: true,
            suffixIcon: widget.controller.text.isEmpty
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (widget.gallery ?? true)
                        IconButton(
                          icon: const Icon(
                            Icons.attachment_outlined,
                            size: 22,
                            color: Color(0xff7C7C7D),
                          ),
                          onPressed: () {
                            _pickFile();
                          },
                        ),
                      if (widget.camera ?? true)
                        IconButton(
                          icon: const Icon(
                            Icons.camera_alt_outlined,
                            size: 22,
                            color: Color(0xff7C7C7D),
                          ),
                          onPressed: () {
                            uploadAction(ImageSource.camera);
                          },
                        ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.change_circle_outlined,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            Text(
                              "Change",
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.primary),
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            widget.controller.text = "";
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
          ),
        )
      ],
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
      compressQuality: 90,
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
      quality: 80,
    );
    if (result != null) {
      var newPath = result.path;
      final file1 = File(newPath);
      fileUpload(file1);
    }
  }

  fileUpload(File file) async {
    SecureStorage secureStorage = SecureStorage();
    CampusServices campusServices = CampusServices();
    AlertServices alertServices = AlertServices();
    String mobile = await secureStorage.get("mobile");
    final String fileExtension = extension(file.path);
    int lastIndex = file.path.lastIndexOf('/');
    String result1 = file.path.substring(0, lastIndex + 1);
    String docId = widget.documentId.toString().toLowerCase();
    file.rename("$result1$docId$fileExtension").then((_) {
      print('File renamed successfully.');
    }).catchError((error) {
      print('Error renaming file: $error');
    });
    alertServices.showLoading();
    await Future.delayed(const Duration(seconds: 1), () {
      final uploadFile = File("$result1$docId$fileExtension");
      print("Upload File --> $uploadFile");
      campusServices
          .uploadImage(mobile.toString(), uploadFile)
          .then((response) async {
        alertServices.hideLoading();
        print("Page Response: $response");
        if (response.toString().toLowerCase() != "null") {
          var res = jsonDecode(response);
          List array = res['url'].toString().split("/");
          List name = array[array.length - 1].toString().split("_");
          widget.controller.text = name[name.length - 1].toString();
          widget.onDataReceived(res['url']);
        }
      });
    });

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
        _cropImage(File(filePath!));
      } else {
        /// PDF
        fileUpload(File(filePath!));
      }
    } else {}
  }
}
