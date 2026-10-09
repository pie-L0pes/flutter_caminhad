import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatelessWidget {
  final LatLng? center;
  final LatLng? inicio;
  final LatLng? destino;
  final List<LatLng> rota;
  final ValueChanged<LatLng>? onTap;
  final double zoom;

  const MapWidget({
    super.key,
    this.center,
    this.inicio,
    this.destino,
    this.rota = const [],
    this.onTap,
    this.zoom = 15,
  });

  @override
  Widget build(BuildContext context) {
    final mapCenter = center ?? inicio ?? destino ?? const LatLng(-22.7086, -46.7654);

    return FlutterMap(
      options: MapOptions(
        initialCenter: mapCenter,
        initialZoom: zoom,
        onTap: onTap == null
            ? null
            : (_, point) => onTap!(point),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'br.com.pietra.caminhadas',
        ),
        if (rota.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: rota,
                strokeWidth: 5,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (inicio != null)
              Marker(
                point: inicio!,
                width: 46,
                height: 46,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.green,
                  size: 34,
                ),
              ),
            if (destino != null)
              Marker(
                point: destino!,
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 42,
                ),
              ),
          ],
        ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }
}
