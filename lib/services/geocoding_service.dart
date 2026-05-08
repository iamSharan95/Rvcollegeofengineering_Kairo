import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';

class GeocodingService {
  Future<Location?> getCoordinates(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return locations.first;
      }
    } catch (e) {
      debugPrint("Geocoding Error: $e");
    }
    return null;
  }
}
