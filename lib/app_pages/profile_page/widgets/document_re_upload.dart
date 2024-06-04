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
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/img/error_alert_logo.png",
            height: 40,
            width: 40,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 150,
            child: Wrap(
              children: [
                Text(
                  "${document['name']} - ${document['comment']}",
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                  // style: CustomTheme.termStyle1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // const Spacer(),
          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: () async {
                showDialog(
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
              child: const Text(
                "Re-upload",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
