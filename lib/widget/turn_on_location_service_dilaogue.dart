import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void turnOnLocationServiceInIphoneDialogue(BuildContext context) {
  Size size = MediaQuery.of(context).size;

  double scalableFontSize(BuildContext context, double fontSize) {
    // Retrieve the text scale factor from MediaQuery
    final double textScaleFactor =
        // ignore: deprecated_member_use
        MediaQuery.of(context).textScaleFactor;

    // Calculate the scaled font size using the text scale factor
    return fontSize * textScaleFactor;
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Turn on Location Services for your iPhone"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              CupertinoIcons.settings,
              color: Colors.grey,
              size: scalableFontSize(context, 35),
            ),
            title: const Text("1. Open Settings App"),
          ),
          ListTile(
            leading: Icon(
              CupertinoIcons.hand_raised_fill,
              color: Colors.grey,
              size: scalableFontSize(context, 35),
            ),
            title: const Text("2. Select Privacy"),
          ),
          ListTile(
            leading: Icon(
              CupertinoIcons.location_fill,
              color: Colors.blue,
              size: scalableFontSize(context, 35),
            ),
            title: const Text("3. Select Location Services"),
          ),
          ListTile(
            leading: SizedBox(
              width: size.aspectRatio * 10,
              height: size.aspectRatio * 10,
              child: Switch.adaptive(value: true, onChanged: (value) {}),
            ),
            title: const Text("4. Turn on Location Services"),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Ok"),
            ),
          )
        ],
      ),
    ),
  );
}
