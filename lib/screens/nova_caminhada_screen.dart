import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/caminhada.dart';
import '../services/location_service.dart';
import '../services/routing_service.dart';
import '../widgets/map_widget.dart';

class NovaCaminhadaScreen extends StatefulWidget {
  const NovaCaminhadaScreen({super.key});

  @override
  State<NovaCaminhadaScreen> createState() => _NovaCaminhadaScreenState();
}

class _NovaCaminhadaScreenState extends State<NovaCaminhadaScreen> {
  final LocationService _locationService = LocationService();
  final RoutingService _routingService = RoutingService();

  LatLng? _inicio;
  LatLng? _destino;
  List<LatLng> _rota = [];
  double _distanciaKm = 0;
  int _tempoMinutos = 0;
  int _calorias = 0;
  bool _carregando = true;
  bool _calculandoRota = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarLocalizacao();
  }

  Future<void> _carregarLocalizacao() async {
    try {
      final Position position = await _locationService.obterLocalizacao();
      if (!mounted) return;

      setState(() {
        _inicio = LatLng(position.latitude, position.longitude);
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
        _carregando = false;
      });
    }
  }

  Future<void> _selecionarDestino(LatLng destino) async {
    if (_inicio == null) return;

    setState(() {
      _destino = destino;
      _calculandoRota = true;
      _erro = null;
    });

    try {
      final result = await _routingService.calcularRota(
        inicio: _inicio!,
        destino: destino,
      );

      if (!mounted) return;

      setState(() {
        _rota = result.points;
        _distanciaKm = result.distanceKm;
        _tempoMinutos = (result.distanceKm / 5 * 60).round();
        _calorias = (result.distanceKm * 60).round();
        _calculandoRota = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _calculandoRota = false;
        _rota = [];
        _erro = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _salvar() async {
    if (_inicio == null || _destino == null || _rota.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um destino e aguarde o cálculo da rota.'),
        ),
      );
      return;
    }

    final controller = TextEditingController();

    final titulo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Salvar caminhada'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 50,
            decoration: const InputDecoration(
              labelText: 'Título da caminhada',
              hintText: 'Ex.: Caminhada da manhã',
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final titulo = controller.text.trim();
                if (titulo.isEmpty) return;
                Navigator.pop(context, titulo);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (titulo == null || titulo.trim().isEmpty || !mounted) return;

    final caminhada = Caminhada(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      titulo: titulo.trim(),
      data: DateTime.now(),
      distanciaKm: _distanciaKm,
      tempoMinutos: _tempoMinutos,
      calorias: _calorias,
      inicioLat: _inicio!.latitude,
      inicioLng: _inicio!.longitude,
      destinoLat: _destino!.latitude,
      destinoLng: _destino!.longitude,
      rota: _rota.map((point) => [point.latitude, point.longitude]).toList(),
    );

    Navigator.pop(context, caminhada);
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nova caminhada')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_inicio == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nova caminhada')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off_outlined, size: 70),
                const SizedBox(height: 18),
                Text(
                  _erro ?? 'Não foi possível obter sua localização.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _carregando = true;
                      _erro = null;
                    });
                    _carregarLocalizacao();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova caminhada'),
        actions: [
          if (_destino != null && _rota.isNotEmpty)
            TextButton(
              onPressed: _calculandoRota ? null : _salvar,
              child: const Text('SALVAR'),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: const Text(
              'Toque no mapa para escolher o destino da caminhada.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                MapWidget(
                  center: _inicio,
                  inicio: _inicio,
                  destino: _destino,
                  rota: _rota,
                  onTap: _selecionarDestino,
                  zoom: 15,
                ),
                if (_calculandoRota)
                  const Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Calculando trajeto...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_erro != null && !_calculandoRota)
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 16,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(_erro!),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_destino != null && _rota.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      _Info(
                        icon: Icons.straighten,
                        label: 'Distância',
                        value: '${_distanciaKm.toStringAsFixed(2)} km',
                      ),
                      _Info(
                        icon: Icons.timer_outlined,
                        label: 'Tempo',
                        value: '$_tempoMinutos min',
                      ),
                      _Info(
                        icon: Icons.local_fire_department_outlined,
                        label: 'Calorias',
                        value: '$_calorias kcal',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _calculandoRota ? null : _salvar,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Salvar caminhada'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Info({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
