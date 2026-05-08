import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:flutter/foundation.dart';

class RoutingService {
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url = 'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
        return coordinates.map((c) => LatLng(c[1], c[0])).toList();
      }
    } catch (e) {
      debugPrint("Routing Error: $e");
    }
    return [];
  }
}
