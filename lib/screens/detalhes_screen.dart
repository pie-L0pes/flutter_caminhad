import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:latlong2/latlong.dart';
import '../models/caminhada.dart';
import '../widgets/map_widget.dart';

class DetalhesScreen extends StatefulWidget {
  final Caminhada caminhada;

  const DetalhesScreen({
    super.key,
    required this.caminhada,
  });

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  late Caminhada _caminhada;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _caminhada = widget.caminhada;
  }

  Future<void> _tirarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (foto == null) return;

      final diretorio = await getApplicationDocumentsDirectory();
      final pastaFotos = Directory('${diretorio.path}/fotos');
      await pastaFotos.create(recursive: true);

      final caminho = '${pastaFotos.path}/caminhada_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fotoSalva = await File(foto.path).copy(caminho);

      if (!mounted) return;

      setState(() {
        _caminhada = _caminhada.copyWith(fotoPath: fotoSalva.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto salva com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir a câmera: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rota = _caminhada.rota
        .map((point) => LatLng(point[0], point[1]))
        .toList();

    final inicio = LatLng(
      _caminhada.inicioLat,
      _caminhada.inicioLng,
    );

    final destino = LatLng(
      _caminhada.destinoLat,
      _caminhada.destinoLng,
    );

    final temFoto = _caminhada.fotoPath != null &&
        File(_caminhada.fotoPath!).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da caminhada'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context, _caminhada),
            icon: const Icon(Icons.check),
            tooltip: 'Salvar alterações',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          SizedBox(
            height: 330,
            child: MapWidget(
              center: inicio,
              inicio: inicio,
              destino: destino,
              rota: rota,
              zoom: 14,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
            child: Text(
              _caminhada.titulo,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                _Stat(
                  icon: Icons.straighten,
                  value: '${_caminhada.distanciaKm.toStringAsFixed(2)} km',
                  label: 'Distância',
                ),
                _Stat(
                  icon: Icons.timer_outlined,
                  value: '${_caminhada.tempoMinutos} min',
                  label: 'Tempo',
                ),
                _Stat(
                  icon: Icons.local_fire_department_outlined,
                  value: '${_caminhada.calorias} kcal',
                  label: 'Calorias',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'Foto da caminhada',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 1.45,
                child: temFoto
                    ? Image.file(
                        File(_caminhada.fotoPath!),
                        fit: BoxFit.cover,
                      )
                    : Material(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: InkWell(
                          onTap: _tirarFoto,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 64),
                              SizedBox(height: 12),
                              Text(
                                'Adicionar foto',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text('Toque para abrir a câmera'),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
          if (temFoto)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: OutlinedButton.icon(
                onPressed: _tirarFoto,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Tirar outra foto'),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
