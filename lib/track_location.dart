// ignore_for_file: avoid_print

library track_location;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
export 'widget/location_tracking_widget.dart';
export 'widget/show_dialogue.dart';
export 'udid/udid.dart';
export 'widget/turn_on_location_service_dilaogue.dart';
export 'services/operator_services.dart';

class TrackLocation {
  //This is the instance of geolocator platform
  final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;

// =============================================================================
// Getting the bool value of Location Service Permission

  Future<bool> checkLocationServiceIsEnabled() async {
    var enabled = await Geolocator.isLocationServiceEnabled();

    return enabled;
  }

// =============================================================================

  Future<bool> checkLocationPermissionIsEnabled() async {
    var value = await Geolocator.checkPermission();
    return value == LocationPermission.always ||
        value == LocationPermission.whileInUse;
  }

//==============================================================================
// Get the current postion of the user
  Future<Position?> getCurrentPosition(BuildContext context) async {
    await checkPermissionForCurrentLocation(context);

    bool hasPermission = await checkLocationPermissionIsEnabled();

    if (hasPermission) {
      final position = await geolocatorPlatform.getCurrentPosition();

      return position;
    }

    return null;
  }

  Future<Map<String, dynamic>> getCurrentLocationAndLocationName(
      BuildContext context) async {
    Position? position = await getCurrentPosition(context);

    if (position != null) {
      double lat = position.latitude;
      double long = position.longitude;
      try {
        List<Placemark> placeMarkList =
            await placemarkFromCoordinates(lat, long);

        if (placeMarkList.isNotEmpty) {
          Placemark placemark = placeMarkList.first;

          return {
            "location": "POINT($long $lat)",
            "locationName":
                "${placemark.name}, ${placemark.thoroughfare}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.postalCode} ${placemark.country}",
          };
        }
      } catch (_) {
        return {
          "location": "POINT($long $lat)",
        };
      }
    }
    return {};
  }

//==============================================================================
//Get the location stream of the user when moving.
  Stream<Position> getLocationStream({
    required LiveLocationAccuracy liveAccuracy,
    required int distanceFilter,
    Duration? intervalDuration,
  }) {
    late LocationSettings locationSettings;
    late Stream<Position> postionStream;

    LocationAccuracy accuracy = getAccuracy(liveAccuracy);

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        intervalDuration: intervalDuration,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: "Running in background",
          notificationText:
              "Roster app will continue to receive your location even when you aren't using it",
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        pauseLocationUpdatesAutomatically: false,
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        // timeLimit: timeLimit,
        activityType: ActivityType.airborne,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,

        // timeLimit: timeLimit,
      );
    }

    postionStream = geolocatorPlatform.getPositionStream(
      locationSettings: locationSettings,
    );

    return postionStream;
  }

//==============================================================================
//Get the location stream of the user when not moving.
  Stream<Position> getLocationStreamWhenNotMoving({
    required LiveLocationAccuracy liveAccuracy,
    Duration? timeLimit,
  }) {
    late LocationSettings locationSettings;
    late Stream<Position> postionStream;

    LocationAccuracy accuracy = getAccuracy(liveAccuracy);

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
          accuracy: accuracy,
          distanceFilter: 0,
          intervalDuration: const Duration(seconds: 20),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: "Running in background",
            notificationText:
                "Example app will continue to receive your location even when you aren't using it",
            enableWakeLock: true,
          ));
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: accuracy,
        distanceFilter: 0,
        timeLimit: timeLimit,
        activityType: ActivityType.airborne,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: accuracy,
        timeLimit: timeLimit,
      );
    }

    postionStream = geolocatorPlatform.getPositionStream(
      locationSettings: locationSettings,
    );

    return postionStream;
  }

  //============================================================================
  //This method opens the app settings
  void openAppSettings() async {
    await geolocatorPlatform.openAppSettings();
  }

//==============================================================================
//This method opens the location settings
  void openLocationSettings() async {
    await geolocatorPlatform.openLocationSettings();
  }

//==============================================================================
//This method checks whether the permission is disabled or not
  Future<void> checkPermission(BuildContext context) async {
    // bool serviceEnabled;
    // LocationPermission permission;

    // if (Platform.isIOS) {

    // Permission.location.request();
    // Geolocator.checkPermission();
    // Permission.location.status;

    if (Platform.isIOS) {
      var status = await Geolocator.requestPermission();

      if (status != LocationPermission.always) {
        // ignore: use_build_context_synchronously
        displayShowDialogue(context, () {
          openAppSettings();
          Navigator.of(context).pop();
        });

        // ignore: use_build_context_synchronously
      }
      return;
    }

    var status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      var status = await Permission.locationAlways.status;

      if (!status.isGranted) {
        // ignore: use_build_context_synchronously
        displayShowDialogue(context, () {
          Permission.locationAlways.request();
          Navigator.of(context).pop();
        });
      }
    }

    // if (!serviceEnabled) {
    //   await geolocatorPlatform.openLocationSettings();
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: const Text("Location is disabled"),
    //     action: SnackBarAction(
    //         label: "Go to location settings", onPressed: openLocationSettings),
    //   ));
    // }

    // if (Platform.isIOS) {
    //   if (status.isDenied) {
    //     displayShowDialogue(context, () {
    //       openAppSettings();
    //     });
    //   }
    // } else if (Platform.isAndroid) {
    // if (!status.isGranted) {
    //   var status = await Permission.locationAlways.request();

    //   if (status.isGranted) {
    //     var status = await Permission.locationAlways.request();

    //     if (status.isGranted) {}
    //   } else {
    //     //user deny the permission
    //   }
    //   if (status.isPermanentlyDenied) {
    //     openAppSettings();
    //   }
    // } else if (status.isGranted) {
    //   //In use in available. Check the always in use.
    //   var status = await Permission.locationAlways.status;

    //   if (!status.isGranted) {
    //     var status = await Permission.locationAlways.request();

    //     if (status.isGranted) {
    //     } else {
    //       //
    //     }
    //   } else {
    //     //
    //   }
    // }
    // }

//==============================================================================
    // permission = await geolocatorPlatform.checkPermission();

    // // print("Permission Status : $permission");

    // if (permission == LocationPermission.denied) {
    //   final status = await geolocatorPlatform.requestPermission();

    //   print(" Second permission check : $status");

    //   if (status == LocationPermission.deniedForever) {
    //     displaySnackbar(context);
    //   }
    // } else if (permission == LocationPermission.deniedForever) {
    //   displaySnackbar(context);
    // }
//==============================================================================
    // else if (permission == LocationPermission.always ||
    //     permission == LocationPermission.whileInUse) {

    //     //Test if location services are enabled
    // serviceEnabled = await geolocatorPlatform.isLocationServiceEnabled();

    //   if (!serviceEnabled) {
    //     displayShowDialogue(context);
    //   }
    // }
  }

  displayShowDialogue(BuildContext context, Function()? onPressed) {
    bool isAndroid = Platform.isAndroid;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enable to location background service"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                leading: Icon(
                  Icons.navigation,
                  color: Colors.blue,
                ),
                title: Text("1. Select Location"),
              ),
              ListTile(
                leading: const Icon(
                  Icons.done,
                  color: Colors.blue,
                ),
                title: Text(
                    "2. ${isAndroid ? "Tap Allow all the time" : "Tap always"} "),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel")),
            TextButton(
              onPressed: onPressed,
              child: const Text("Open location settings"),
            )
          ],
        );
      },
    );
  }

  //==============================================================================
//This method checks whether the permission is disabled or not
  Future<void> checkPermissionForCurrentLocation(BuildContext context) async {
    if (Platform.isIOS) {
      var status = await Geolocator.requestPermission();

      if (status != LocationPermission.whileInUse) {
        if (context.mounted) {
          displayShowDialogueForCurrentLocation(context, () {
            openAppSettings();
            Navigator.of(context).pop();
          });
        }
      }
      return;
    }

    var whenInUseStatus = await Permission.locationWhenInUse.request();

    if (!whenInUseStatus.isGranted) {
      // ignore: use_build_context_synchronously
      displayShowDialogueForCurrentLocation(context, () {
        Permission.locationWhenInUse.request();
        Navigator.of(context).pop();
      });
    }
  }

  displayShowDialogueForCurrentLocation(
      BuildContext context, Function()? onPressed) {
    bool isAndroid = Platform.isAndroid;

    showAdaptiveDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Text("Enable location background service"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [Text("1. Select Location")],
              ),
              Row(
                children: [
                  Text(
                      "2. ${isAndroid ? "While using the app" : "Select Allow while using the app"} ")
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel")),
            TextButton(
              onPressed: onPressed,
              child: const Text("Open location settings"),
            )
          ],
        );
      },
    );
  }

  // displaySnackbar(BuildContext context) {
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: const Text("Permission is denied"),
  //       action: SnackBarAction(
  //         label: "Go to app settings",
  //         onPressed: openAppSettings,
  //       )));
  // }

  LocationAccuracy getAccuracy(LiveLocationAccuracy value) {
    switch (value) {
      case LiveLocationAccuracy.lowest:
        return LocationAccuracy.lowest;

      case LiveLocationAccuracy.low:
        return LocationAccuracy.low;

      case LiveLocationAccuracy.medium:
        return LocationAccuracy.medium;

      case LiveLocationAccuracy.high:
        return LocationAccuracy.high;

      case LiveLocationAccuracy.best:
        return LocationAccuracy.best;

      case LiveLocationAccuracy.bestForNavigation:
        return LocationAccuracy.bestForNavigation;

      case LiveLocationAccuracy.reduced:
        return LocationAccuracy.reduced;

      default:
        return LocationAccuracy.best;
    }
  }
}

/// Represent the possible location accuracy values.
enum LiveLocationAccuracy {
  /// Location is accurate within a distance of 3000m on iOS and 500m on Android
  lowest,

  /// Location is accurate within a distance of 1000m on iOS and 500m on Android
  low,

  /// Location is accurate within a distance of 100m on iOS and between 100m and
  /// 500m on Android
  medium,

  /// Location is accurate within a distance of 10m on iOS and between 0m and
  /// 100m on Android
  high,

  /// Location is accurate within a distance of ~0m on iOS and between 0m and
  /// 100m on Android
  best,

  /// Location accuracy is optimized for navigation on iOS and matches the
  /// [LocationAccuracy.best] on Android
  bestForNavigation,

  /// Location accuracy is reduced for iOS 14+ devices, matches the
  /// [LocationAccuracy.lowest] on iOS 13 and below and all other platforms.
  reduced,
}
