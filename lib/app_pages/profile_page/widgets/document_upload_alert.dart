import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:driev/app_services/customer_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../../../app_storages/secure_storage.dart';
import '../../../app_utils/app_loading/alert_services.dart';

class DocumentUploadAlert extends StatelessWidget {
  final Map<String, String?> document;
  final Function(bool) onDataReceived;

  static const double _iconSize = 40.0;
  static const double _spacing = 25.0;
  static const double _fontSize = 16.0;
  static const int _compressionQuality = 70;
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];

  const DocumentUploadAlert({
    super.key,
    required this.document,
    required this.onDataReceived,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      contentPadding: const EdgeInsets.all(_spacing),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildUploadOption(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onPressed: () => _handleCameraUpload(context),
              ),
              const SizedBox(width: _spacing),
              _buildUploadOption(
                icon: Icons.perm_media_outlined,
                label: 'Gallery',
                onPressed: () => _handleGalleryUpload(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: _iconSize),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: _fontSize,
            fontFamily: "Roboto",
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _handleCameraUpload(BuildContext context) {
    Navigator.of(context).pop();
    _uploadFromSource(ImageSource.camera);
  }

  void _handleGalleryUpload(BuildContext context) {
    Navigator.of(context).pop();
    if (document['id'] == "selfi") {
      _uploadFromSource(ImageSource.gallery);
    } else {
      _pickFile();
    }
  }

  Future<void> _uploadFromSource(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: source);
      if (photo != null) {
        await _compressAndUpload(File(photo.path));
      }
    } catch (e) {
      _handleError('Failed to capture image: $e');
    }
  }

  Future<void> _compressAndUpload(File file) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${file.path}.jpg',
        quality: _compressionQuality,
      );

      if (result != null) {
        await _uploadFile(File(result.path));
      }
    } catch (e) {
      _handleError('Failed to compress image: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileExtension = extension(filePath);

        if (fileExtension.toLowerCase() != '.pdf') {
          await _compressAndUpload(File(filePath));
        } else {
          await _uploadFile(File(filePath));
        }
      }
    } catch (e) {
      _handleError('Failed to pick file: $e');
    }
  }

  Future<void> _uploadFile(File file) async {
    try {
      final secureStorage = SecureStorage();
      final customerService = CustomerService();
      final alertServices = AlertServices();

      final mobile = secureStorage.get("mobile");
      if (mobile == null) {
        throw Exception('Mobile number not found');
      }

      alertServices.showLoading();

      final request = {
        "contact": mobile,
        "fileName": document['id'],
      };

      final ext = extension(file.path);
      final lastIndex = file.path.lastIndexOf('/');
      final directory = file.path.substring(0, lastIndex + 1);
      final docId = document['id'];
      final newPath = '$directory$docId$ext';

      await file.rename(newPath);
      final uploadFile = File(newPath);

      final response = await customerService.uploadImage(uploadFile, request);
      alertServices.hideLoading();

      final res = jsonDecode(response);
      onDataReceived(res != null);
    } catch (e) {
      _handleError('Failed to upload file: $e');
    }
  }

  void _handleError(String message) {
    AlertServices().hideLoading();
    onDataReceived(false);
  }
}
