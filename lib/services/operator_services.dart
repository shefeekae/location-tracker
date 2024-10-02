import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:track_location/track_location.dart';

class OperatorLocationServices {
  TrackLocation trackLocation = TrackLocation();

  Future<Map<String, dynamic>> getCurrentLocation(BuildContext context) async {
    Position? position = await trackLocation.getCurrentPosition(context);

    if (position != null) {
      double lat = position.latitude;
      double long = position.longitude;

      List<Placemark> placeMarkList = await placemarkFromCoordinates(lat, long);

      if (placeMarkList.isNotEmpty) {
        return {
          "requestSourceLocation": "POINT($lat $long)",
          "requestSourceLocationName": placeMarkList.first
        };
      }
    }
    return {};
  }
}
