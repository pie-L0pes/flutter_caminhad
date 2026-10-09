class Caminhada {
  final String id;
  final String titulo;
  final DateTime data;
  final double distanciaKm;
  final int tempoMinutos;
  final int calorias;
  final double inicioLat;
  final double inicioLng;
  final double destinoLat;
  final double destinoLng;
  final List<List<double>> rota;
  final String? fotoPath;

  const Caminhada({
    required this.id,
    required this.titulo,
    required this.data,
    required this.distanciaKm,
    required this.tempoMinutos,
    required this.calorias,
    required this.inicioLat,
    required this.inicioLng,
    required this.destinoLat,
    required this.destinoLng,
    required this.rota,
    this.fotoPath,
  });

  Caminhada copyWith({String? fotoPath}) {
    return Caminhada(
      id: id,
      titulo: titulo,
      data: data,
      distanciaKm: distanciaKm,
      tempoMinutos: tempoMinutos,
      calorias: calorias,
      inicioLat: inicioLat,
      inicioLng: inicioLng,
      destinoLat: destinoLat,
      destinoLng: destinoLng,
      rota: rota,
      fotoPath: fotoPath ?? this.fotoPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'data': data.toIso8601String(),
      'distanciaKm': distanciaKm,
      'tempoMinutos': tempoMinutos,
      'calorias': calorias,
      'inicioLat': inicioLat,
      'inicioLng': inicioLng,
      'destinoLat': destinoLat,
      'destinoLng': destinoLng,
      'rota': rota,
      'fotoPath': fotoPath,
    };
  }

  factory Caminhada.fromJson(Map<String, dynamic> json) {
    return Caminhada(
      id: json['id'],
      titulo: json['titulo'],
      data: DateTime.parse(json['data']),
      distanciaKm: (json['distanciaKm'] as num).toDouble(),
      tempoMinutos: json['tempoMinutos'],
      calorias: json['calorias'],
      inicioLat: (json['inicioLat'] as num).toDouble(),
      inicioLng: (json['inicioLng'] as num).toDouble(),
      destinoLat: (json['destinoLat'] as num).toDouble(),
      destinoLng: (json['destinoLng'] as num).toDouble(),
      rota: (json['rota'] as List)
          .map((item) => (item as List)
              .map((value) => (value as num).toDouble())
              .toList())
          .toList(),
      fotoPath: json['fotoPath'],
    );
  }
}
