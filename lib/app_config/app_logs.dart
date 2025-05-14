import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// PRINT ONLY PAGE TITLES
printPageTitle(String title) {
  if (!kReleaseMode) {
    debugPrint("===> Page Title: $title <===");
  }
}

/// PRINT ONLY SERVICE CLASS
printServiceLogs(String method, String url) {
  if (!kReleaseMode) {
    debugPrint("-----------------------------------");
    debugPrint("METHOD NAME : [$method]");
    debugPrint("API URL     : $url");
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
      