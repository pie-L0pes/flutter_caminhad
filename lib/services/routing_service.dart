import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceKm;
  final int durationMinutes;

  const RouteResult({
    required this.points,
    required this.distanceKm,
    required this.durationMinutes,
  });
}

class RoutingService {
  Future<RouteResult> calcularRota({
    required LatLng inicio,
    required LatLng destino,
  }) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/foot/'
      '${inicio.longitude},${inicio.latitude};'
      '${destino.longitude},${destino.latitude}'
      '?overview=full&geometries=geojson',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'CaminhadasFlutter/1.0'},
    );

    if (response.statusCode != 200) {
      throw Exception('Não foi possível calcular a rota.');
    }

    final data = jsonDecode(response.body);

    if (data['code'] != 'Ok' || (data['routes'] as List).isEmpty) {
      throw Exception('Não existe uma rota de caminhada para este destino.');
    }

    final route = data['routes'][0];
    final coordinates = route['geometry']['coordinates'] as List;

    final points = coordinates
        .map<LatLng>(
          (point) => LatLng(
            (point[1] as num).toDouble(),
            (point[0] as num).toDouble(),
          ),
        )
        .toList();

    final distanceKm = (route['distance'] as num).toDouble() / 1000;
    final durationMinutes =
        ((route['duration'] as num).toDouble() / 60).round();

    return RouteResult(
      points: points,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
    );
  }
}
