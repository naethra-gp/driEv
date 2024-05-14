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
        // required
        //     ? RichText(
        //         text: TextSpan(
        //           text: title,
        //           style: CustomTheme.formLabelStyle,
        //           children: const [
        //             TextSpan(
        //               text: ' *',
        //               style: TextStyle(
        //                 color: Colors.redAccent,
        //               ),
        //             )
        //           ],
        //         ),
        //       )
        //     : RichText(
        //         text: TextSpan(
        //           text: title,
        //           style: CustomTheme.formLabelStyle,
        //         ),
        //       ),
        // const SizedBox(height: 5),
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
            // fillColor: Colors.grey,
            // filled: true,
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
            contentPadding: const EdgeInsets.only(left: 15),
            isDense: true,
            // prefixIcon: prefixIcon != null
            //     ? Icon(
            //         prefixIcon,
            //         color: themeColor,
            //         size: 26,
            //       )
            //     : Icon(
            //         AntDesign.idcard_outline,
            //         color: themeColor,
            //         size: 26,
            //       ),
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
                      // uploadAction(ImageSource.gallery);
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
                  onTap: (){
                    setState(() {
                      widget.controller.text = "";
                    });
                  },
                ),

                // const Column(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //     Icon(
                //       Icons.check_circle_outline,
                //       size: 20,
                //       color: AppColors.primary,
                //     ),
                //     Text(
                //       "Uploaded",
                //       style: TextStyle(
                //           fontSize: 10, color: AppColors.primary),
                //     ),
                //   ],
                // ),
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

  fileUpload(File file) async {
    SecureStorage secureStorage = SecureStorage();
    CampusServices campusServices = CampusServices();
    AlertServices alertServices = AlertServices();
    String mobile = await secureStorage.get("mobile");
    final String fileExtension = extension(file.path);
    int lastIndex = file.path.lastIndexOf('/');
    String result1 = file.path.substring(0, lastIndex + 1);
    file.rename("$result1${widget.documentId}$fileExtension").then((_) {
      // print('File renamed successfully.');
    }).catchError((error) {
      // print('Error renaming file: $error');
    });

    alertServices.showLoading();
    final uploadFile = File("$result1${widget.documentId}$fileExtension");
    campusServices
        .uploadImage(mobile.toString(), uploadFile)
        .then((response) async {
      alertServices.hideLoading();
      var res = jsonDecode(response);
      List array = res['url'].toString().split("/");
      widget.controller.text = array[array.length - 1].toString();
      widget.onDataReceived(res['url']);
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
        _cropImage(File(filePath));
      } else {
        /// PDF
        fileUpload(File(filePath));
      }
    } else {
      // print('File picking canceled.');
    }
  }
}

// class FileUploadForm extends StatelessWidget {
//   final String title;
//   final String documentId;
//   final bool required;
//   final bool? gallery;
//   final bool? camera;
//   final String? helperText;
//   final FormFieldValidator? validator;
//   final IconData? prefixIcon;
//   final Function(String) onDataReceived;
//   final TextEditingController controller;
//
//   const FileUploadForm({
//     super.key,
//     required this.title,
//     required this.required,
//     this.helperText,
//     this.validator,
//     this.prefixIcon,
//     this.gallery,
//     this.camera,
//     required this.onDataReceived,
//     required this.controller,
//     required this.documentId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // required
//         //     ? RichText(
//         //         text: TextSpan(
//         //           text: title,
//         //           style: CustomTheme.formLabelStyle,
//         //           children: const [
//         //             TextSpan(
//         //               text: ' *',
//         //               style: TextStyle(
//         //                 color: Colors.redAccent,
//         //               ),
//         //             )
//         //           ],
//         //         ),
//         //       )
//         //     : RichText(
//         //         text: TextSpan(
//         //           text: title,
//         //           style: CustomTheme.formLabelStyle,
//         //         ),
//         //       ),
//         // const SizedBox(height: 5),
//         TextFormField(
//           controller: controller,
//           enableInteractiveSelection: false,
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           validator: validator,
//           readOnly: true,
//           style: CustomTheme.formFieldStyle,
//           decoration: InputDecoration(
//             hintText: title,
//             helperText: helperText,
//             errorStyle: const TextStyle(
//               color: Colors.redAccent,
//               fontSize: 12,
//               fontWeight: FontWeight.normal,
//             ),
//             // fillColor: Colors.grey,
//             // filled: true,
//             hintStyle: CustomTheme.formHintStyle,
//             disabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(5.0),
//               borderSide: const BorderSide(
//                 color: Color(0xffD2D2D2),
//               ),
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(
//                 color: Color(0xffD2D2D2),
//               ),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: Colors.redAccent, width: 1),
//             ),
//             focusedBorder: const OutlineInputBorder(
//               borderRadius: BorderRadius.all(
//                 Radius.circular(10),
//               ),
//               borderSide: BorderSide(
//                 color: Color(0xffD2D2D2),
//               ),
//             ),
//             contentPadding: const EdgeInsets.only(left: 15),
//             isDense: true,
//             // prefixIcon: prefixIcon != null
//             //     ? Icon(
//             //         prefixIcon,
//             //         color: themeColor,
//             //         size: 26,
//             //       )
//             //     : Icon(
//             //         AntDesign.idcard_outline,
//             //         color: themeColor,
//             //         size: 26,
//             //       ),
//             suffixIcon: controller.text.isEmpty
//                 ? Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       if (gallery ?? true)
//                         IconButton(
//                           icon: const Icon(
//                             Icons.attachment_outlined,
//                             size: 22,
//                             color: Color(0xff7C7C7D),
//                           ),
//                           onPressed: () {
//                             _pickFile();
//                             // uploadAction(ImageSource.gallery);
//                           },
//                         ),
//                       if (camera ?? true)
//                         IconButton(
//                           icon: const Icon(
//                             Icons.camera_alt_outlined,
//                             size: 22,
//                             color: Color(0xff7C7C7D),
//                           ),
//                           onPressed: () {
//                             uploadAction(ImageSource.camera);
//                           },
//                         ),
//                     ],
//                   )
//                 : Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       // IconButton(
//                       //   icon: const Icon(
//                       //     LineAwesome.retweet_solid,
//                       //     size: 22,
//                       //     color: AppColors.primary,
//                       //     // color: Color(0xff7C7C7D),
//                       //   ),
//                       //   onPressed: () {
//                       //     controller.text = "";
//                       //     // uploadAction(ImageSource.camera);
//                       //   },
//                       // ),
//                       const Icon(
//                         Icons.check_circle_outline,
//                         size: 20,
//                         color: AppColors.primary,
//                       ),
//                       const SizedBox(width: 10),
//                       GestureDetector(
//                         child: const Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.change_circle_outlined,
//                               size: 20,
//                               color: AppColors.primary,
//                             ),
//                             Text(
//                               "Change",
//                               style: TextStyle(
//                                   fontSize: 10, color: AppColors.primary),
//                             ),
//                           ],
//                         ),
//                         onTap: (){
//                           controller.text = "";
//                         },
//                       ),
//
//                       // const Column(
//                       //   mainAxisAlignment: MainAxisAlignment.center,
//                       //   crossAxisAlignment: CrossAxisAlignment.center,
//                       //   children: [
//                       //     Icon(
//                       //       Icons.check_circle_outline,
//                       //       size: 20,
//                       //       color: AppColors.primary,
//                       //     ),
//                       //     Text(
//                       //       "Uploaded",
//                       //       style: TextStyle(
//                       //           fontSize: 10, color: AppColors.primary),
//                       //     ),
//                       //   ],
//                       // ),
//                       const SizedBox(width: 10),
//                     ],
//                   ),
//           ),
//         )
//       ],
//     );
//   }
//
//   uploadAction(ImageSource src) async {
//     final ImagePicker picker = ImagePicker();
//     XFile? photo = await picker.pickImage(source: src);
//     if (photo != null) {
//       _cropImage(File(photo.path));
//     }
//   }
//
//   _cropImage(pickedFile) async {
//     late String path;
//     final croppedFile = await ImageCropper().cropImage(
//       sourcePath: pickedFile.path,
//       compressFormat: ImageCompressFormat.jpg,
//       compressQuality: 100,
//       androidUiSettings: const AndroidUiSettings(
//         toolbarTitle: 'Crop your Photo',
//         toolbarColor: AppColors.primary,
//         toolbarWidgetColor: Colors.white,
//         initAspectRatio: CropAspectRatioPreset.original,
//         lockAspectRatio: false,
//       ),
//       iosUiSettings: const IOSUiSettings(
//         title: 'Crop your Photo',
//       ),
//     );
//     if (croppedFile != null) {
//       path = croppedFile.path;
//       compress(File(path));
//     }
//   }
//
//   compress(File file) async {
//     var result = await FlutterImageCompress.compressAndGetFile(
//       file.absolute.path,
//       '${file.path}.jpg',
//       quality: 50,
//     );
//     if (result != null) {
//       var newPath = result.path;
//       final file1 = File(newPath);
//       fileUpload(file1);
//     }
//   }
//
//   fileUpload(File file) async {
//     SecureStorage secureStorage = SecureStorage();
//     CampusServices campusServices = CampusServices();
//     AlertServices alertServices = AlertServices();
//     String mobile = await secureStorage.get("mobile");
//     final String fileExtension = extension(file.path);
//     int lastIndex = file.path.lastIndexOf('/');
//     String result1 = file.path.substring(0, lastIndex + 1);
//     file.rename("$result1$documentId$fileExtension").then((_) {
//       print('File renamed successfully.');
//     }).catchError((error) {
//       print('Error renaming file: $error');
//     });
//
//     alertServices.showLoading();
//     final uploadFile = File("$result1$documentId$fileExtension");
//     campusServices
//         .uploadImage(mobile.toString(), uploadFile)
//         .then((response) async {
//       alertServices.hideLoading();
//       var res = jsonDecode(response);
//       List array = res['url'].toString().split("/");
//       controller.text = array[array.length - 1].toString();
//       onDataReceived(res['url']);
//     });
//   }
//
//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
//     );
//
//     if (result != null) {
//       String? filePath = result.files.single.path;
//       final String fileExtension = extension(filePath!);
//       if (fileExtension.toString() != ".pdf") {
//         /// IMAGES
//         _cropImage(File(filePath));
//       } else {
//         /// PDF
//         fileUpload(File(filePath));
//       }
//     } else {
//       print('File picking canceled.');
//     }
//   }
// }
