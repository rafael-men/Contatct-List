import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contato.dart';
import 'contatos_files.dart';

class PreferenciasApp extends ChangeNotifier {
  static const _temaKey = 'tema_escuro';
  static const _backupKey = 'backup_automatico';
  static const _intervaloKey = 'intervalo_backup';
  static const _compactaKey = 'lista_compacta';
  static const _avataresKey = 'mostrar_avatares';

  bool escuro = false;
  bool backupAutomatico = false;
  int intervaloBackup = 1;
  bool listaCompacta = false;
  bool mostrarAvatares = true;
  Timer? _timer;

  ThemeMode get themeMode => escuro ? ThemeMode.dark : ThemeMode.light;

  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    escuro = prefs.getBool(_temaKey) ?? false;
    backupAutomatico = prefs.getBool(_backupKey) ?? false;
    intervaloBackup = prefs.getInt(_intervaloKey) ?? 1;
    listaCompacta = prefs.getBool(_compactaKey) ?? false;
    mostrarAvatares = prefs.getBool(_avataresKey) ?? true;
    _agendarBackup();
    notifyListeners();
  }

  Future<void> _salvar(String chave, Object valor) async {
    final prefs = await SharedPreferences.getInstance();
    if (valor is bool) await prefs.setBool(chave, valor);
    if (valor is int) await prefs.setInt(chave, valor);
    notifyListeners();
  }

  Future<void> definirTema(bool valor) async {
    escuro = valor;
    await _salvar(_temaKey, valor);
  }

  Future<void> definirBackup(bool valor) async {
    backupAutomatico = valor;
    await _salvar(_backupKey, valor);
    _agendarBackup();
  }

  Future<void> definirIntervalo(int valor) async {
    intervaloBackup = valor;
    await _salvar(_intervaloKey, valor);
    _agendarBackup();
  }

  Future<void> definirListaCompacta(bool valor) async {
    listaCompacta = valor;
    await _salvar(_compactaKey, valor);
  }

  Future<void> definirAvatares(bool valor) async {
    mostrarAvatares = valor;
    await _salvar(_avataresKey, valor);
  }

  void _agendarBackup() {
    _timer?.cancel();
    if (!backupAutomatico) return;
    _timer = Timer.periodic(
      Duration(days: intervaloBackup),
      (_) => backupAgora(_contatos),
    );
  }

  List<Contato> _contatos = [];

  void atualizarContatos(List<Contato> contatos) {
    _contatos = List.of(contatos);
  }

  Future<void> backupAgora([List<Contato>? contatos]) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}backup_contatos.csv',
    );
    await file.writeAsBytes(ContatosArquivo.exportarCsv(contatos ?? _contatos));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
