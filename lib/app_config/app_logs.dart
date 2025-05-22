import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// PRINT ONLY PAGE TITLES
printPageTitle(String title) {
  if (!kReleaseMode) {
    debugPrint("===> Page Title: $title <===");
  }
}

/// PRINT ONLY SERVICE CLASS
printServiceLogs(String method, String url,
    {dynamic request, dynamic response}) {
  if (!kReleaseMode) {
    debugPrint("-----------------------------------");
    debugPrint("METHOD NAME : [$method]");
    debugPrint("API URL     : ${Uri.parse(url)}");
    debugPrint("REQUEST     : ${jsonEncode(request)}");
    debugPrint("RESPONSE    : ${jsonEncode(response)}");
    debugPrint("-----------------------------------");
  }
}

/// PRINT RESPONSE
printResponse(String content) {
  if (!kReleaseMode) {
    debugPrint("-----------------------------------");
    debugPrint(content);
    debugPrint("-----------------------------------");
  }
}

/// FIREBASE GLOBAL ERROR CATCH
Future<void> firebaseCatchLogs(
  dynamic onError,
  StackTrace stack, {
  String reason = "",
  bool fatal = false,
}) async {
  // NO NEED PRINT IN RELEASE MODE
  if (!kReleaseMode) {
    debugPrint("-----------------------------------");
    debugPrint("Page Name     : $reason");
    debugPrint("Factal Error  : $fatal");
    debugPrint("Error Desc    : ${onError.toString()}");
    debugPrint("-----------------------------------");
  }

  /// FIREBASE CATCH RECORDS
  await FirebaseCrashlytics.instance.recordError(
    onError,
    stack,
    reason: reason,
    fatal: fatal,
  );
}
