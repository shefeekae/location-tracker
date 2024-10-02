import 'package:flutter/material.dart';

showPopUPDialog({
  required BuildContext context,
  required void Function()? onPressed,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Turn on your location settings"),
      content: const Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.navigation,
              color: Colors.blue,
            ),
            title: Text("1. Select Location"),
          ),
          ListTile(
            leading: Icon(
              Icons.done,
              color: Colors.blue,
            ),
            title: Text("2. Tap Always"),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('No'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: onPressed,
          child: const Text('Yes'),
        ),
      ],
    ),
  );
}
