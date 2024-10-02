import 'package:example/home_page.dart';
import 'package:flutter/material.dart';
import 'package:nectar_mqtt/nectar_mqtt.dart';

void main() async {
  // MqttClient mqttClient = MqttClient();

  // try {
  //   mqttClient.connect(
  //       server: 'broker.hivemq.com',
  //       clientIdentifier: 'Nectar_mqtt',
  //       port: 1883);
  // } catch (e) {
  //   print("MQTT Connect method exception : ${e.toString()}");
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
