import 'dart:convert';
import 'package:battery_plus/battery_plus.dart';
import 'package:example/battery/battery_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nectar_mqtt/nectar_mqtt.dart';
import 'package:track_location/track_location.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TrackLocation trackLocation = TrackLocation();

  OperatorLocationServices operatorLocationServices =
      OperatorLocationServices();
  final Battery battery = Battery();

  final TextEditingController topicWhenMovingController =
      TextEditingController();
  final TextEditingController topicWhenNotMovingController =
      TextEditingController();

  MqttClient mqttClient = MqttClient();

  Udid udid = Udid();

  Future<String> getUdid() async {
    String uniqueId = await udid.getUdid();

    return uniqueId;
  }

  @override
  void initState() {
    // trackLocation.checkPermission(context);
    // trackLocation.checkPermissionForCurrentLocation(context);
    // getUdid();
    super.initState();
  }

//==============================================================================
//Track location when moving.
  listenToLocationStreamWhenMoving(String topic) {
    trackLocation
        .getLocationStream(
      liveAccuracy: LiveLocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    )
        .listen((position) async {
      String uniqueId = await getUdid();

      int? batteryLevel;
      try {
        batteryLevel = await battery.batteryLevel;
      } on PlatformException catch (e) {
        print(e.message);
      }

      try {
        mqttClient.publishMessage(
            topic: topic,
            message: jsonEncode({
              "time": DateTime.now().millisecondsSinceEpoch,
              "id": uniqueId,
              "location": "${position.latitude}, ${position.longitude}",
              "batteryLevel": batteryLevel,
            }));
      } catch (e) {
        print(e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Location"),
        ),
        body: Center(
          child: Column(
            children: [
              // LocationTrackingWidget(
              //   liveAccuracy: LiveLocationAccuracy.bestForNavigation,
              //   distanceFilter: 0,
              // ),
              BatteryInfo(),
              TextFormField(
                controller: topicWhenMovingController,
                decoration: const InputDecoration(hintText: "Enter topic"),
              ),
              ElevatedButton(
                onPressed: () {
                  trackLocation.getCurrentLocationAndLocationName(context);
                },
                child: const Text("Track location"),
              ),
            ],
          ),
        ));
  }
}
