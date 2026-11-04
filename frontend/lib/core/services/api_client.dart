import 'dart:convert';
import 'package:http/http.dart' as http;
import '../random/crypto_random.dart';
import '../../models/wheel_model.dart';

class ApiClient {
  /// Backend opcional (apenas desenvolvimento). Vazio = 100% offline, nenhum nome sai do aparelho.
  static const String baseUrl = String.fromEnvironment('API_BASE_URL');

  /// Spin wheel with Python backend, fallback to local CSPRNG
  static Future<Map<String, dynamic>> spinWheel(WheelModel wheel) async {
    try {
      if (baseUrl.isEmpty) throw StateError('offline');
      final response = await http.post(
        Uri.parse('$baseUrl/wheel/spin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'wheel': {
            'name': wheel.name,
            'options': wheel.options.map((o) => {
              'id': o.id,
              'label': o.label,
              'weight': o.weight,
              'active': o.active,
            }).toList(),
            'different_weights': wheel.differentWeights,
            'remove_on_win': wheel.removeOnWin,
          }
        }),
      ).timeout(const Duration(milliseconds: 1500));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final id = data['winner_id'];
        if (wheel.options.any((o) => o.active && o.id == id)) return data;
      }
    } catch (_) {
      // Backend not running or timeout; fall through to local CSPRNG engine!
    }

    // Local CSPRNG fallback
    final active = wheel.options.where((o) => o.active).toList();
    if (active.length < 2) {
      throw Exception('A roleta precisa de pelo menos 2 opções ativas');
    }

    final weights = active.map((o) => wheel.differentWeights ? o.weight : 1.0).toList();
    final winnerIdx = CryptoRandom.weightedChoice(weights);
    final winner = active[winnerIdx];
    final totalWeight = weights.reduce((a, b) => a + b);
    final prob = (weights[winnerIdx] / totalWeight) * 100.0;

    return {
      'winner_id': winner.id,
      'winner_label': winner.label,
      'winner_index': winnerIdx,
      'probability_percentage': prob.toStringAsFixed(1),
      'total_active_options': active.length,
      'landing_angle_degrees': 0.0,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

