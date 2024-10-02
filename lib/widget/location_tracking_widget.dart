// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:track_location/track_location.dart';

// class LocationTrackingWidget extends StatelessWidget {
//   LocationTrackingWidget(
//       {super.key, required this.liveAccuracy, required this.distanceFilter});

//   final LiveLocationAccuracy liveAccuracy;
//   final int distanceFilter;

//   final TrackLocation trackLocation = TrackLocation();

//   turnOnLocation() {
//     trackLocation.openAppSettings();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: trackLocation.getLocationStreamWhenNotMoving(
//         liveAccuracy: liveAccuracy,
//       ),
//       builder: (context, snapshot) {
//         final position = snapshot.data;

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         if (snapshot.hasError) {
//           if (snapshot.error is PositionUpdateException) {
//             return Column(
//               children: [
//                 ElevatedButton(
//                   onPressed: () => turnOnLocation(),
//                   child: Text("Turn on location"),
//                 ),
//                 Text("1. Go to app settings"),
//                 Text("2. Tap location"),
//                 Text("3. Select always"),
//               ],
//             );
//           }

//           if (snapshot.error is PermissionDeniedException) {
//             return Column(
//               children: [
//                 ElevatedButton(
//                   onPressed: () => turnOnLocation(),
//                   child: Text("Turn on location"),
//                 ),
//                 Text("1. Go to app settings"),
//                 Text("2. Tap location"),
//                 Text("3. Select always"),
//               ],
//             );
//           }

//           return Center(
//             child: Text(snapshot.error.toString()),
//           );
//         }

//         return Column(
//           children: [
//             //Latitude
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text("Latitude : "),
//                 Text("${position?.latitude ?? "Unknown"}"),
//               ],
//             ),
//             //Longitude
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text("Longitude : "),
//                 Text("${position?.longitude ?? "Unknown"}"),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
