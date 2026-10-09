import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/caminhada.dart';

class StorageService {
  static const _key = 'caminhadas';

  Future<List<Caminhada>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data
        .map((item) => Caminhada.fromJson(jsonDecode(item)))
        .toList();
  }

  Future<void> salvar(Caminhada caminhada) async {
    final lista = await listar();
    lista.insert(0, caminhada);
    await _salvarLista(lista);
  }

  Future<void> atualizar(Caminhada caminhada) async {
    final lista = await listar();
    final index = lista.indexWhere((item) => item.id == caminhada.id);
    if (index >= 0) {
      lista[index] = caminhada;
      await _salvarLista(lista);
    }
  }

  Future<void> excluir(String id) async {
    final lista = await listar();
    lista.removeWhere((item) => item.id == id);
    await _salvarLista(lista);
  }

  Future<void> _salvarLista(List<Caminhada> lista) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      lista.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }
}
