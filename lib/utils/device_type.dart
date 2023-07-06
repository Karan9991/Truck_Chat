import 'dart:io';

String getDeviceType() {
  if (Platform.isAndroid) {
    return 'Android';
  } else if (Platform.isIOS) {
    return 'iOS';
  } else {
    return 'Unknown';
  }
}
