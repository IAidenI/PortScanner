import 'package:scanner/export.dart';

class InputChecker {
  static bool checkIP(String ipAddress) {
    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}'
      r'(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$',
    );

    return ipRegex.hasMatch(ipAddress);
  }

  static bool checkPort(String port) {
    try {
      int portInt = int.parse(port);
      if (portInt >= 0 && portInt <= 65535) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static bool checkSegment(String segment) {
    try {
      int portInt = int.parse(segment);
      if (portInt >= 0 && portInt <= 100) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static bool checkURL(String url) {
    final urlPattern = RegExp(
      r'^(https?:\/\/)?'
      r'([a-zA-Z0-9-_]+\.)+[a-zA-Z]{2,6}'
      r'(\/.*)?$',
    );

    return urlPattern.hasMatch(url);
  }

  static bool checkIpMask(String ipMask) {
    final maskPattern = RegExp(
        r'^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\/([0-9]|[12][0-9]|3[0-2])$');
    final match = maskPattern.firstMatch(ipMask);

    if (match != null) {
      if (checkIP(match.group(1)!)) {
        return cidrToMask.containsKey(int.parse(match.group(2)!));
      }
      return false;
    }
    return false;
  }
}
