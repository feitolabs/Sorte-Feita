import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/history_entry.dart';
import '../../models/wheel_model.dart';

class LocalStorageService extends ChangeNotifier {
  static const String _keyHistory = 'sorte_feita_history';
  static const String _keyWheels = 'sorte_feita_saved_wheels';
  static const String _keySound = 'sorte_feita_sound_enabled';
  static const String _keyHaptic = 'sorte_feita_haptic_enabled';
  static const String _keyTheme = 'sorte_feita_theme_mode';
  static const String _keyReduceMotion = 'sorte_feita_reduce_motion';
  static const String _keyAdsRemoved = 'sorte_feita_ads_removed';

  /// Gancho de atividade concluída (frequency cap de anúncios).
  VoidCallback? onActivityCompleted;

  SharedPreferences? _prefs;

  List<HistoryEntry> _history = [];
  List<WheelModel> _savedWheels = [];

  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  String _themeMode = 'light'; // 'light', 'dark', 'system'
  bool _reduceMotion = false;
  bool _adsRemoved = false;

  List<HistoryEntry> get history => List.unmodifiable(_history);
  List<WheelModel> get savedWheels => List.unmodifiable(_savedWheels);
  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;
  String get themeMode => _themeMode;
  bool get reduceMotion => _reduceMotion;
  bool get adsRemoved => _adsRemoved;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPreferences();
    _loadHistory();
    _loadWheels();
    notifyListeners();
  }

  void _loadPreferences() {
    if (_prefs == null) return;
    _soundEnabled = _prefs!.getBool(_keySound) ?? true;
    _hapticEnabled = _prefs!.getBool(_keyHaptic) ?? true;
    _themeMode = _prefs!.getString(_keyTheme) ?? 'light';
    _reduceMotion = _prefs!.getBool(_keyReduceMotion) ?? false;
    _adsRemoved = _prefs!.getBool(_keyAdsRemoved) ?? false;
  }

  void _loadHistory() {
    if (_prefs == null) return;
    final jsonStr = _prefs!.getString(_keyHistory);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        _history = list.map((e) => HistoryEntry.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Erro ao carregar histórico local: $e');
        _history = [];
      }
    } else {
      // Default seed history for first run
      _history = [
        HistoryEntry(
          type: 'wheel',
          title: 'O que comer hoje',
          summary: 'Roleta · 6 opções · ontem',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          configSnapshot: WheelModel.defaultFoodWheel().toJson(),
          result: 'Hambúrguer',
        ),
        HistoryEntry(
          type: 'name_draw',
          title: 'Turma 7B · apresentação',
          summary: 'Nomes · 28 participantes · seg.',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          configSnapshot: {
            'winners_count': 3,
            'alternates_count': 2,
            'participants': ['Ana', 'Bruno', 'Carla', 'Diego']
          },
          result: ['Gabriela', 'Diego', 'Ana Beatriz'],
        ),
      ];
      _saveHistory();
    }
  }

  void _loadWheels() {
    if (_prefs == null) return;
    final jsonStr = _prefs!.getString(_keyWheels);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        _savedWheels = list.map((e) => WheelModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Erro ao carregar roletas locais: $e');
        _savedWheels = [];
      }
    } else {
      _savedWheels = [WheelModel.defaultFoodWheel()];
      _saveWheels();
    }
  }

  Future<void> _saveHistory() async {
    if (_prefs == null) return;
    final jsonStr = jsonEncode(_history.map((e) => e.toJson()).toList());
    await _prefs!.setString(_keyHistory, jsonStr);
  }

  Future<void> _saveWheels() async {
    if (_prefs == null) return;
    final jsonStr = jsonEncode(_savedWheels.map((e) => e.toJson()).toList());
    await _prefs!.setString(_keyWheels, jsonStr);
  }

  // --- History actions ---
  Future<void> addHistoryEntry(HistoryEntry entry) async {
    _history.insert(0, entry);
    onActivityCompleted?.call();
    await _saveHistory();
    notifyListeners();
  }

  Future<void> deleteHistoryEntry(String id) async {
    _history.removeWhere((e) => e.id == id);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> toggleFavoriteHistory(String id) async {
    final idx = _history.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _history[idx].isFavorite = !_history[idx].isFavorite;
      await _saveHistory();
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _saveHistory();
    notifyListeners();
  }

  // --- Wheel actions ---
  Future<void> saveWheel(WheelModel wheel) async {
    final idx = _savedWheels.indexWhere((w) => w.id == wheel.id);
    if (idx != -1) {
      _savedWheels[idx] = wheel;
    } else {
      _savedWheels.insert(0, wheel);
    }
    await _saveWheels();
    notifyListeners();
  }

  Future<void> deleteWheel(String id) async {
    _savedWheels.removeWhere((w) => w.id == id);
    await _saveWheels();
    notifyListeners();
  }

  // --- Settings actions ---
  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _prefs?.setBool(_keySound, value);
    notifyListeners();
  }

  Future<void> setHapticEnabled(bool value) async {
    _hapticEnabled = value;
    await _prefs?.setBool(_keyHaptic, value);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await _prefs?.setString(_keyTheme, mode);
    notifyListeners();
  }

  Future<void> setReduceMotion(bool value) async {
    _reduceMotion = value;
    await _prefs?.setBool(_keyReduceMotion, value);
    notifyListeners();
  }

  Future<void> setAdsRemoved(bool value) async {
    _adsRemoved = value;
    await _prefs?.setBool(_keyAdsRemoved, value);
    notifyListeners();
  }
}

final LocalStorageService localStorageService = LocalStorageService();

