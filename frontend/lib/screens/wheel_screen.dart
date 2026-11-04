import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_colors.dart';
import '../core/random/crypto_random.dart';
import '../core/storage/local_storage_service.dart';
import '../core/services/api_client.dart';
import '../models/wheel_model.dart';
import '../models/history_entry.dart';
import '../widgets/wheel_painter.dart';

class WheelScreen extends StatefulWidget {
  final WheelModel? initialWheel;

  const WheelScreen({super.key, this.initialWheel});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> with SingleTickerProviderStateMixin {
  late WheelModel _wheel;
  late TextEditingController _titleController;

  // View state: 'edit' or 'spin'
  String _mode = 'spin';

  // Animation
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _currentAngle = 0.0;
  bool _isSpinning = false;

  // Result State
  WheelOption? _lastWinner;
  double _lastProbability = 0.0;
  DateTime? _lastResultTime;

  WheelOption? _pendingWinner;
  double _pendingProbability = 0.0;
  DateTime? _pendingResultTime;
  bool _showWinnerResult = false;

  @override
  void initState() {
    super.initState();
    _wheel = widget.initialWheel ?? WheelModel.defaultFoodWheel();
    _titleController = TextEditingController(text: _wheel.name);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _animation.addListener(() {
      setState(() {
        _currentAngle = _animation.value;
      });
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          _lastWinner = _pendingWinner;
          _lastProbability = _pendingProbability;
          _lastResultTime = _pendingResultTime;
          _showWinnerResult = true;
        });

        if (localStorageService.hapticEnabled) {
          HapticFeedback.heavyImpact();
        }

        // Save to local storage history only after wheel completely stops
        if (_lastWinner != null && _lastResultTime != null) {
          localStorageService.addHistoryEntry(HistoryEntry(
            type: 'wheel',
            title: _wheel.name,
            summary: 'Roleta · ${_activeOptions.length} opções · ${DateFormat('HH:mm').format(_lastResultTime!)}',
            configSnapshot: _wheel.toJson(),
            result: _lastWinner!.label,
          ));
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  List<WheelOption> get _activeOptions => _wheel.options.where((o) => o.active).toList();

  Future<void> _spin() async {
    if (_isSpinning) return;
    if (_activeOptions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ative pelo menos 2 opções para girar!')),
      );
      return;
    }

    if (localStorageService.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }

    setState(() {
      _isSpinning = true;
      _showWinnerResult = false;
      _mode = 'spin';
    });

    // 1. Pick winner using Python backend or offline CSPRNG
    final result = await ApiClient.spinWheel(_wheel);
    final winnerId = result['winner_id'] as String;
    final winner = _activeOptions.firstWhere((o) => o.id == winnerId);
    final prob = double.tryParse(result['probability_percentage'].toString()) ?? 0.0;

    // 2. Compute geometry
    final totalWeight = _activeOptions.fold<double>(
      0.0,
      (sum, opt) => sum + (_wheel.differentWeights ? opt.weight : 1.0),
    );

    double startAngle = 0.0;
    double sweepAngle = 0.0;

    for (final opt in _activeOptions) {
      final weight = _wheel.differentWeights ? opt.weight : 1.0;
      final arc = (weight / totalWeight) * 2 * pi;
      if (opt.id == winner.id) {
        sweepAngle = arc;
        break;
      }
      startAngle += arc;
    }

    // Top pointer is at -pi/2 (270 degrees)
    // We want the winner's center to align with -pi/2
    final midSlice = startAngle + (sweepAngle / 2);
    const topPointerAngle = 3 * pi / 2; // top of circle

    // Calculate final angle with 5-7 full spins
    final fullSpins = 5 + CryptoRandom.randInt(1, 3);
    final baseTarget = (fullSpins * 2 * pi) + (topPointerAngle - midSlice);

    // Add tiny randomized offset within safe slice margin
    final margin = sweepAngle * 0.15;
    final randomJitter = (CryptoRandom.randDouble() * (sweepAngle - 2 * margin)) - (sweepAngle / 2 - margin);
    final finalTargetAngle = baseTarget + randomJitter;

    _pendingWinner = winner;
    _pendingProbability = prob;
    _pendingResultTime = DateTime.now();

    // 4. Run smooth deceleration animation
    _animation = Tween<double>(
      begin: _currentAngle % (2 * pi),
      end: finalTargetAngle,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: localStorageService.reduceMotion ? Curves.linear : Curves.easeOutCubic,
    ));

    _animationController.reset();
    _animationController.duration = localStorageService.reduceMotion
        ? const Duration(milliseconds: 600)
        : const Duration(milliseconds: 3800);
    _animationController.forward();
  }

  void _removeWinnerAndSpin() {
    if (_lastWinner != null) {
      setState(() {
        _lastWinner!.active = false;
      });
      _spin();
    }
  }

  void _shareResult() {
    if (_lastWinner == null) return;
    Share.share(
      '🎯 Sorte Feita!\nResultado: "${_lastWinner!.label}" na roleta "${_wheel.name}".\nSorteios gratuitos e offline pelo app Sorte Feita!',
      subject: 'Resultado da Roleta Sorte Feita',
    );
  }

  void _showPasteListDialog() {
    final pasteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Colar lista de opções',
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.petroleo,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Digite ou cole uma opção por linha:',
              style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pasteController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Exemplo:\nPizza\nJaponês\nHambúrguer\nSalada',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondaryLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brasa,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final lines = pasteController.text
                  .split('\n')
                  .map((l) => l.trim())
                  .where((l) => l.isNotEmpty)
                  .toList();
              if (lines.isNotEmpty) {
                setState(() {
                  _wheel.options = lines.asMap().entries.map((entry) {
                    final color = AppColors.wheelPalette[entry.key % AppColors.wheelPalette.length];
                    return WheelOption(label: entry.value, color: color);
                  }).toList();
                });
              }
              Navigator.pop(ctx);
            },
            child: Text('Substituir Opções', style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _addNewOption() {
    final newColor = AppColors.wheelPalette[_wheel.options.length % AppColors.wheelPalette.length];
    setState(() {
      _wheel.options.add(WheelOption(
        label: 'Opção ${_wheel.options.length + 1}',
        color: newColor,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_wheel.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_mode == 'spin')
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, size: 26),
              tooltip: 'Editar Roleta',
              onPressed: () => setState(() => _mode = 'edit'),
            )
          else
            TextButton(
              onPressed: () {
                _wheel.name = _titleController.text.trim().isEmpty ? 'Roleta' : _titleController.text.trim();
                localStorageService.saveWheel(_wheel);
                setState(() => _mode = 'spin');
              },
              child: Text(
                'Salvar',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.petroleo,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 760;

            if (isWideScreen) {
              // Side-by-side Desktop/Tablet view as in PDF Page 12!
              return Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildConfigForm(),
                    ),
                  ),
                  const VerticalDivider(width: 1, color: AppColors.borderLight),
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildWheelView(),
                    ),
                  ),
                ],
              );
            }

            // Mobile single column view
            return _mode == 'edit'
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildConfigForm(),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildWheelView(),
                  );
          },
        ),
      ),
    );
  }

  Widget _buildConfigForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NOME DA ROLETA',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.petroleo,
          ),
          decoration: const InputDecoration(
            hintText: 'Ex: O que comer hoje',
          ),
        ),
        const SizedBox(height: 24),

        // Header: OPÇÕES · X and Colar lista
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'OPÇÕES · ${_wheel.options.length}',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.textPrimaryLight,
              ),
            ),
            GestureDetector(
              onTap: _showPasteListDialog,
              child: Text(
                'Colar lista',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.petroleo,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Options List
        ..._wheel.options.asMap().entries.map((entry) {
          final idx = entry.key;
          final opt = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                // Color chip / toggle active
                GestureDetector(
                  onTap: () {
                    setState(() => opt.active = !opt.active);
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: opt.active ? opt.color : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    opt.label,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: opt.active ? AppColors.petroleo : Colors.grey.shade400,
                      decoration: opt.active ? null : TextDecoration.lineThrough,
                    ),
                  ),
                ),
                if (_wheel.differentWeights && opt.active)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        opt.weight = opt.weight >= 3.0 ? 1.0 : opt.weight + 1.0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.areia,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'peso ${opt.weight.toInt()}',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.petroleo,
                        ),
                      ),
                    ),
                  )
                else if (!opt.active)
                  Text(
                    'inativa',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondaryLight),
                  onPressed: () {
                    if (_wheel.options.length <= 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('A roleta deve ter pelo menos 2 opções')),
                      );
                      return;
                    }
                    setState(() => _wheel.options.removeAt(idx));
                  },
                ),
              ],
            ),
          );
        }),

        // + Adicionar opção
        TextButton.icon(
          onPressed: _addNewOption,
          icon: const Icon(Icons.add_rounded, color: AppColors.petroleo),
          label: Text(
            'Adicionar opção',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.petroleo,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Switches
        Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: AppColors.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: AppColors.petroleo,
                  title: Text(
                    'Pesos diferentes',
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.petroleo,
                    ),
                  ),
                  subtitle: Text(
                    'Permite opções com maior probabilidade de sair',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 13,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  value: _wheel.differentWeights,
                  onChanged: (val) => setState(() => _wheel.differentWeights = val),
                ),
                const Divider(height: 20),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: AppColors.petroleo,
                  title: Text(
                    'Tirar quem sair',
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.petroleo,
                    ),
                  ),
                  subtitle: Text(
                    'Desativa a opção vencedora para a próxima rodada',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 13,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  value: _wheel.removeOnWin,
                  onChanged: (val) => setState(() => _wheel.removeOnWin = val),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Action Button: Girar (Brasa)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brasa,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () {
              setState(() => _mode = 'spin');
              _spin();
            },
            icon: const Icon(Icons.sync_rounded, size: 24),
            label: Text(
              'Girar',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWheelView() {
    return Column(
      children: [
        // Top Pointer (Downward pointing orange triangle per spec)
        CustomPaint(
          size: const Size(32, 24),
          painter: _PointerPainter(),
        ),
        const SizedBox(height: 6),

        // Animated Wheel
        Center(
          child: SizedBox(
            width: 290,
            height: 290,
            child: CustomPaint(
              painter: WheelPainter(
                options: _activeOptions,
                differentWeights: _wheel.differentWeights,
                rotationAngle: _currentAngle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Winner Card: ONLY display when wheel has completely finished spinning
        if (!_isSpinning && _showWinnerResult && _lastWinner != null)
          AnimatedOpacity(
            opacity: _showWinnerResult ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 350),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'SAIU',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _lastWinner!.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.petroleo,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Chance de ${_lastProbability.toInt()}% · ${_activeOptions.length} opções ativas · ${DateFormat('HH:mm').format(_lastResultTime ?? DateTime.now())}',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 13,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_isSpinning)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.nevoa.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.brasa,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Girando a roleta...',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.petroleo,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aguarde a parada no ponteiro',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),

        // Action: Girar de novo (Petróleo #0E3B43)
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSpinning ? AppColors.petroleo.withOpacity(0.5) : AppColors.petroleo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: _isSpinning ? null : _spin,
            icon: _isSpinning
                ? const SizedBox.shrink()
                : const Icon(Icons.sync_rounded, size: 22),
            label: Text(
              _isSpinning
                  ? 'Girando...'
                  : (_lastWinner == null ? 'Girar roleta' : 'Girar de novo'),
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Secondary Buttons: Tirar e girar / Compartilhar
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _isSpinning || _lastWinner == null ? Colors.grey.shade400 : AppColors.petroleo,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isSpinning || _lastWinner == null ? null : _removeWinnerAndSpin,
                  child: Text(
                    'Tirar e girar',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _isSpinning || _lastWinner == null ? Colors.grey.shade400 : AppColors.petroleo,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _isSpinning || _lastWinner == null ? Colors.grey.shade400 : AppColors.petroleo,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isSpinning || _lastWinner == null ? null : _shareResult,
                  icon: Icon(
                    Icons.upload_rounded,
                    size: 18,
                    color: _isSpinning || _lastWinner == null ? Colors.grey.shade400 : AppColors.petroleo,
                  ),
                  label: Text(
                    'Compartilhar',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _isSpinning || _lastWinner == null ? Colors.grey.shade400 : AppColors.petroleo,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brasa
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.petroleo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
