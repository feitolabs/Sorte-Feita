import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_colors.dart';
import '../core/random/crypto_random.dart';
import '../core/storage/local_storage_service.dart';
import '../models/history_entry.dart';

class NumberDrawScreen extends StatefulWidget {
  const NumberDrawScreen({super.key});

  @override
  State<NumberDrawScreen> createState() => _NumberDrawScreenState();
}

class _NumberDrawScreenState extends State<NumberDrawScreen> {
  final TextEditingController _minController = TextEditingController(text: '1');
  final TextEditingController _maxController = TextEditingController(text: '100');
  final TextEditingController _countController = TextEditingController(text: '1');
  final TextEditingController _excludedController = TextEditingController();

  bool _allowRepeat = false;
  bool _sortResult = true;

  bool _showResult = false;
  List<int> _numbers = [];

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _countController.dispose();
    _excludedController.dispose();
    super.dispose();
  }

  void _drawNumbers() {
    final minVal = int.tryParse(_minController.text) ?? 1;
    final maxVal = int.tryParse(_maxController.text) ?? 100;
    final count = int.tryParse(_countController.text) ?? 1;

    if (minVal > maxVal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valor mínimo não pode ser maior que o máximo')),
      );
      return;
    }

    final excludedList = _excludedController.text
        .split(RegExp(r'[,;\s]+'))
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toSet();

    final available = <int>[];
    for (int i = minVal; i <= maxVal; i++) {
      if (!excludedList.contains(i)) {
        available.add(i);
      }
    }

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum número disponível no intervalo após exclusões')),
      );
      return;
    }

    if (!_allowRepeat && count > available.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quantidade ($count) excede números disponíveis (${available.length})')),
      );
      return;
    }

    if (localStorageService.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }

    List<int> drawn = [];
    if (!_allowRepeat) {
      drawn = CryptoRandom.sampleWithoutReplacement(available, count);
    } else {
      for (int i = 0; i < count; i++) {
        final idx = CryptoRandom.randInt(0, available.length - 1);
        drawn.add(available[idx]);
      }
    }

    if (_sortResult) {
      drawn.sort();
    }

    setState(() {
      _numbers = drawn;
      _showResult = true;
    });

    localStorageService.addHistoryEntry(HistoryEntry(
      type: 'number_draw',
      title: 'Sorteio de Números ($minVal a $maxVal)',
      summary: '$count números sorteados',
      configSnapshot: {
        'min': minVal,
        'max': maxVal,
        'count': count,
        'allowRepeat': _allowRepeat,
      },
      result: drawn,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showResult ? 'Resultado' : 'Sorteio de números'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (_showResult) {
              setState(() => _showResult = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: _showResult ? _buildResultView() : _buildConfigView(),
        ),
      ),
    );
  }

  Widget _buildConfigView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DO NÚMERO',
                    style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.textPrimaryLight),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _minController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.bricolageGrotesque(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.petroleo),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ATÉ O NÚMERO',
                    style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.textPrimaryLight),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _maxController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.bricolageGrotesque(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.petroleo),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'QUANTIDADE DE NÚMEROS',
          style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.textPrimaryLight),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _countController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.bricolageGrotesque(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.petroleo),
        ),
        const SizedBox(height: 20),
        Text(
          'NÚMEROS EXCLUÍDOS (OPCIONAL)',
          style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.textPrimaryLight),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _excludedController,
          decoration: const InputDecoration(hintText: 'Ex: 13, 22, 50'),
        ),
        const SizedBox(height: 20),
        Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: AppColors.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: AppColors.petroleo,
                  title: Text('Permitir repetição', style: GoogleFonts.bricolageGrotesque(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.petroleo)),
                  value: _allowRepeat,
                  onChanged: (v) => setState(() => _allowRepeat = v),
                ),
                const Divider(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: AppColors.petroleo,
                  title: Text('Ordenar resultado', style: GoogleFonts.bricolageGrotesque(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.petroleo)),
                  value: _sortResult,
                  onChanged: (v) => setState(() => _sortResult = v),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brasa,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _drawNumbers,
            child: Text(
              'Sortear números',
              style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.petroleo,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(
                'NÚMEROS SORTEADOS',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: AppColors.nevoaClaro,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _numbers.map((n) {
                  return Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.azulRio,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.azulRioClaro, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$n',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.petroleo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _drawNumbers,
            icon: const Icon(Icons.sync_rounded, size: 22),
            label: Text(
              'Sortear de novo',
              style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.petroleo, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => setState(() => _showResult = false),
                  child: Text('Editar intervalo', style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w700, color: AppColors.petroleo)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.petroleo, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Share.share('Números sorteados no app Sorte Feita: ${_numbers.join(", ")}');
                  },
                  icon: const Icon(Icons.upload_rounded, size: 18, color: AppColors.petroleo),
                  label: Text('Compartilhar', style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w700, color: AppColors.petroleo)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
