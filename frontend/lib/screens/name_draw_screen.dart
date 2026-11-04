import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_colors.dart';
import '../core/random/crypto_random.dart';
import '../core/storage/local_storage_service.dart';
import '../models/history_entry.dart';

class NameDrawScreen extends StatefulWidget {
  const NameDrawScreen({super.key});

  @override
  State<NameDrawScreen> createState() => _NameDrawScreenState();
}

class _NameDrawScreenState extends State<NameDrawScreen> {
  final TextEditingController _textController = TextEditingController(
    text: 'Ana Beatriz\nBruno\nCarla\nDiego\nEduarda\nFelipe\nGabriela\nHenrique\nIsabela',
  );

  int _winnersCount = 3;
  int _alternatesCount = 2;
  bool _removeDuplicates = true;

  bool _showResult = false;
  List<String> _winners = [];
  List<String> _alternates = [];
  DateTime? _drawnAt;
  int _totalParticipants = 0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  List<String> _getCleanedParticipants() {
    final lines = _textController.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (!_removeDuplicates) {
      return lines;
    }

    final seen = <String>{};
    final unique = <String>[];
    for (final name in lines) {
      if (!seen.contains(name.toLowerCase())) {
        seen.add(name.toLowerCase());
        unique.add(name);
      }
    }
    return unique;
  }

  int _getRawDuplicatesCount() {
    final raw = _textController.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final unique = _getCleanedParticipants();
    return raw.length - unique.length;
  }

  void _executeDraw() {
    final eligible = _getCleanedParticipants();
    if (eligible.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insira pelo menos 1 participante na lista')),
      );
      return;
    }

    if (_winnersCount > eligible.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ganhadores ($_winnersCount) excede o total elegível (${eligible.length})')),
      );
      return;
    }

    if ((_winnersCount + _alternatesCount) > eligible.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ganhadores + Suplentes excede participantes elegíveis (${eligible.length})')),
      );
      return;
    }

    if (localStorageService.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }

    final shuffled = CryptoRandom.shuffle(eligible);
    final winners = shuffled.take(_winnersCount).toList();
    final alternates = shuffled.skip(_winnersCount).take(_alternatesCount).toList();

    setState(() {
      _winners = winners;
      _alternates = alternates;
      _drawnAt = DateTime.now();
      _totalParticipants = eligible.length;
      _showResult = true;
    });

    // Save to local storage
    localStorageService.addHistoryEntry(HistoryEntry(
      type: 'name_draw',
      title: 'Sorteio de Nomes',
      summary: '$_winnersCount ganhadores · $_totalParticipants participantes · ${DateFormat('dd/MM, HH:mm').format(_drawnAt!)}',
      configSnapshot: {
        'winners_count': _winnersCount,
        'alternates_count': _alternatesCount,
        'participants': eligible,
      },
      result: winners,
    ));
  }

  void _shareResult() {
    final winnersText = _winners.asMap().entries.map((e) => '${e.key + 1}º ${e.value}').join('\n');
    final alternatesText = _alternates.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');
    final text = '🎉 Resultado do Sorteio:\n\nGANHADORES:\n$winnersText\n\n'
        '${_alternates.isNotEmpty ? "SUPLENTES:\n$alternatesText\n\n" : ""}'
        'Sorteado pelo app Sorte Feita · Feito Labs';
    Share.share(text, subject: 'Resultado do Sorteio de Nomes');
  }

  void _copyToClipboard() {
    final winnersText = _winners.asMap().entries.map((e) => '${e.key + 1}º ${e.value}').join('\n');
    Clipboard.setData(ClipboardData(text: winnersText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ganhadores copiados para a área de transferência!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showResult ? 'Resultado' : 'Sorteio de nomes'),
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
        actions: [
          if (_showResult)
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 22),
              tooltip: 'Copiar Resultado',
              onPressed: _copyToClipboard,
            )
          else
            IconButton(
              icon: const Icon(Icons.file_upload_outlined, size: 24),
              tooltip: 'Importar lista',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cole sua lista diretamente na caixa de texto abaixo!')),
                );
              },
            ),
        ],
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
    final eligibleCount = _getCleanedParticipants().length;
    final duplicatesCount = _getRawDuplicatesCount();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PARTICIPANTES · UM POR LINHA',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),

        // Text Area
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight, width: 1.5),
          ),
          child: TextField(
            controller: _textController,
            maxLines: 8,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryLight,
            ),
            decoration: const InputDecoration(
              hintText: 'Cole os nomes aqui...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 8),

        // Helper text with duplicate count (like in prototype)
        Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.azulRio),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$eligibleCount participantes.${duplicatesCount > 0 ? " $duplicatesCount nome repetido foi removido." : ""}',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.petroleo,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Steppers: Ganhadores & Suplentes side-by-side
        Row(
          children: [
            Expanded(
              child: _buildCounterCard(
                title: 'Ganhadores',
                value: _winnersCount,
                onMinus: () {
                  if (_winnersCount > 1) setState(() => _winnersCount--);
                },
                onPlus: () {
                  setState(() => _winnersCount++);
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildCounterCard(
                title: 'Suplentes',
                value: _alternatesCount,
                onMinus: () {
                  if (_alternatesCount > 0) setState(() => _alternatesCount--);
                },
                onPlus: () {
                  setState(() => _alternatesCount++);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Switch: Remover nomes iguais
        Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: AppColors.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeTrackColor: AppColors.petroleo,
              title: Text(
                'Remover nomes iguais',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.petroleo,
                ),
              ),
              subtitle: Text(
                '“Ana” e “Ana Maria” continuam',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              value: _removeDuplicates,
              onChanged: (val) => setState(() => _removeDuplicates = val),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Primary Button: Sortear N nomes (Brasa #F26B21)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brasa,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: _executeDraw,
            child: Text(
              'Sortear $_winnersCount ${_winnersCount == 1 ? "nome" : "nomes"}',
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

  Widget _buildCounterCard({
    required String title,
    required int value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.petroleo,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onMinus,
                icon: const Icon(Icons.remove_rounded, color: AppColors.petroleo),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.areia,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Text(
                '$value',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.petroleo,
                ),
              ),
              IconButton(
                onPressed: onPlus,
                icon: const Icon(Icons.add_rounded, color: AppColors.petroleo),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.areia,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dark Card for Ganhadores (as in PDF Page 8)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.petroleo,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GANHADORES',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: AppColors.nevoaClaro,
                ),
              ),
              const SizedBox(height: 18),
              ..._winners.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final name = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: idx == 1 ? AppColors.brasa : AppColors.azulRio,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$idxº',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Suplentes Card
        if (_alternates.isNotEmpty) ...[
          Text(
            'SUPLENTES',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _alternates.asMap().entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    '${entry.key + 1}. ${entry.value}',
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.petroleo,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Metadata
        Text(
          '$_totalParticipants participantes · sem repetição · ${DateFormat('dd/MM/yyyy, HH:mm').format(_drawnAt ?? DateTime.now())}',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 13,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 16),

        // Sem anúncio junto ao resultado (spec 13.2: resultado tem prioridade)
        const SizedBox(height: 24),

        // Actions: Sortear de novo
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.petroleo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: _executeDraw,
            icon: const Icon(Icons.sync_rounded, size: 22),
            label: Text(
              'Sortear de novo',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Duplicar & Compartilhar
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
                  child: Text(
                    'Editar lista',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.petroleo,
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
                    side: const BorderSide(color: AppColors.petroleo, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _shareResult,
                  icon: const Icon(Icons.upload_rounded, size: 18, color: AppColors.petroleo),
                  label: Text(
                    'Compartilhar',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.petroleo,
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
