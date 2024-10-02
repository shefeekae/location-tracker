import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';

class Udid {
  Future<String> getUdid() async {
    String udid;

    try {
      udid = await FlutterUdid.udid;
    } on PlatformException {
      udid = '';
    }

    return udid;
  }

  Future<String> getConstantUdid() async {
    String constantUdid;

    try {
      constantUdid = await FlutterUdid.udid;
    } on PlatformException {
      constantUdid = '';
    }

    return constantUdid;
  }
}
