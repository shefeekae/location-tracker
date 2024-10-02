import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BatteryInfo extends StatelessWidget {
  BatteryInfo({super.key});

  final Battery battery = Battery();

  int? batteryLevel;

  getBatteryLevel() async {
    try {
      batteryLevel = await battery.batteryLevel;
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    getBatteryLevel();
    return StreamBuilder(
      stream: battery.onBatteryStateChanged,
      builder: (context, snapshot) {
        // return Text("${batteryLevel ?? "Unknown"}");

        BatteryState? stat = snapshot.data;
        

        return Text(snapshot.data.toString());
      },
    );
  }
}
