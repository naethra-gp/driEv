import 'package:flutter/material.dart';
import 'document_upload_alert.dart';

/// A widget that displays a document that needs to be re-uploaded
/// along with an error message and re-upload button.
class DocumentReUpload extends StatelessWidget {
  /// Document data containing name and comment
  final Map<String, String?> document;

  /// Callback function that is called when document upload is successful
  final Function(bool) onDataReceived;

  // Constants for styling
  static const double _containerPadding = 10.0;
  static const double _iconSize = 30.0;
  static const double _spacing = 10.0;
  static const double _textWidth = 150.0;
  static const double _borderRadius = 10.0;
  static const double _fontSize = 14.0;
  static const double _buttonFontSize = 12.0;

  const DocumentReUpload({
    super.key,
    required this.document,
    required this.onDataReceived,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_containerPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xffFF0000).withOpacity(0.4),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/img/error_alert_logo.png",
            height: _iconSize,
            width: _iconSize,
          ),
          const SizedBox(width: _spacing),
          SizedBox(
            width: _textWidth,
            child: Text(
              "${document['name'] ?? ""} - ${document['comment'] ?? "N/A"}",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.red,
                fontSize: _fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: _spacing),
          _buildUploadButton(context),
        ],
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    final bool isReupload = document['comment'] != null;

    return SizedBox(
      height: _iconSize,
      child: ElevatedButton(
        onPressed: () => _showUploadDialog(context),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
        child: Text(
          isReupload ? "Re-upload" : "Upload",
          style: const TextStyle(
            fontSize: _buttonFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      barrierColor: Colors.black.withOpacity(0.7),
      context: context,
      builder: (BuildContext context) => DocumentUploadAlert(
        document: document,
        onDataReceived: (bool status) {
          if (status) {
            onDataReceived(status);
          }
        },
      ),
    );
  }
}
