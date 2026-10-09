import 'dart:io';
import 'package:flutter/material.dart';
import '../models/caminhada.dart';
import '../services/storage_service.dart';
import '../widgets/caminhada_card.dart';
import 'detalhes_screen.dart';
import 'nova_caminhada_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  List<Caminhada> _caminhadas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final lista = await _storage.listar();
    if (!mounted) return;
    setState(() {
      _caminhadas = lista;
      _carregando = false;
    });
  }

  Future<void> _abrirNova() async {
    final resultado = await Navigator.push<Caminhada>(
      context,
      MaterialPageRoute(builder: (_) => const NovaCaminhadaScreen()),
    );

    if (resultado != null) {
      await _storage.salvar(resultado);
      await _carregar();
    }
  }

  Future<void> _abrirDetalhes(Caminhada caminhada) async {
    final resultado = await Navigator.push<Caminhada>(
      context,
      MaterialPageRoute(
        builder: (_) => DetalhesScreen(caminhada: caminhada),
      ),
    );

    if (resultado != null) {
      await _storage.atualizar(resultado);
      await _carregar();
    }
  }

  void _abrirMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Início'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(
                  Theme.of(context).brightness == Brightness.light
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                ),
                title: Text(
                  Theme.of(context).brightness == Brightness.light
                      ? 'Tema escuro'
                      : 'Tema claro',
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onToggleTheme();
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Sobre o aplicativo'),
                onTap: () {
                  Navigator.pop(context);
                  showAboutDialog(
                    context: context,
                    applicationName: 'Caminhadas',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.directions_walk),
                    children: const [
                      Text(
                        'Aplicativo para registrar caminhadas usando localização, mapas, rotas, fotos e armazenamento local.',
                      ),
                    ],
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _abrirMenu,
          icon: const Icon(Icons.menu),
        ),
        title: const Text(
          'Caminhadas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: _carregando
            ? const Center(child: CircularProgressIndicator())
            : _caminhadas.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.25,
                      ),
                      const Icon(
                        Icons.directions_walk_outlined,
                        size: 90,
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Nenhuma caminhada cadastrada',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Toque no botão + para registrar sua primeira caminhada.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
                    itemCount: _caminhadas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final caminhada = _caminhadas[index];
                      return CaminhadaCard(
                        caminhada: caminhada,
                        onTap: () => _abrirDetalhes(caminhada),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirNova,
        child: const Icon(Icons.add),
      ),
    );
  }
}
