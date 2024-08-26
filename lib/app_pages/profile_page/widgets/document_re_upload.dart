import 'package:flutter/material.dart';
import 'document_upload_alert.dart';

class DocumentReUpload extends StatelessWidget {
  final dynamic document;
  final Function(bool) onDataReceived;

  const DocumentReUpload({
    super.key,
    required this.document,
    required this.onDataReceived,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xffFF0000).withOpacity(0.4),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.asset(
            "assets/img/error_alert_logo.png",
            height: 30,
            width: 30,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 150,
            child: Wrap(
              children: [
                Text(
                  "${document['name'] ?? ""} - ${document['comment'] ?? "N/A"}",
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 30,
            // width: double.minPositive,
            child: ElevatedButton(
              onPressed: () async {
                showDialog(
                  barrierColor: Colors.black.withOpacity(0.7),
                  context: context,
                  builder: (BuildContext context) {
                    return DocumentUploadAlert(
                      document: document,
                      onDataReceived: (bool status) {
                        if (status) {
                          onDataReceived(status);
                        }
                      },
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Re-upload",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
