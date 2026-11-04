import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_colors.dart';
import '../core/random/crypto_random.dart';
import '../core/storage/local_storage_service.dart';
import '../models/history_entry.dart';

class TeamGroup {
  final String name;
  final Color headerColor;
  String? captain;
  final List<String> members;

  TeamGroup({
    required this.name,
    required this.headerColor,
    this.captain,
    required this.members,
  });
}

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final TextEditingController _participantsController = TextEditingController(
    text: 'Gabriela\nBruno\nEduarda\nJonas\nDiego\nCarla\nHenrique\nLaura\nIsabela\nFelipe\nAna Beatriz\nMarcos\nNina',
  );

  int _teamsCount = 3;
  bool _pickCaptains = true;
  bool _showResult = false;

  List<TeamGroup> _teams = [];
  List<String> _reserves = [];

  final List<Map<String, dynamic>> _presetThemes = [
    {'name': 'Equipe Rio', 'color': AppColors.petroleo},
    {'name': 'Equipe Mar', 'color': AppColors.azulRio},
    {'name': 'Equipe Serra', 'color': AppColors.azulRioClaro},
    {'name': 'Equipe Sol', 'color': AppColors.brasa},
    {'name': 'Equipe Duna', 'color': AppColors.nevoa},
  ];

  @override
  void dispose() {
    _participantsController.dispose();
    super.dispose();
  }

  void _generateTeams() {
    final participants = _participantsController.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (participants.length < _teamsCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número de participantes deve ser maior ou igual ao número de equipes')),
      );
      return;
    }

    if (localStorageService.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }

    final shuffled = CryptoRandom.shuffle(participants);

    final baseSize = shuffled.length ~/ _teamsCount;
    final remainder = shuffled.length % _teamsCount;

    final List<TeamGroup> generated = [];
    int startIdx = 0;

    for (int i = 0; i < _teamsCount; i++) {
      final size = baseSize + (i < remainder ? 1 : 0);
      final members = shuffled.sublist(startIdx, startIdx + size);
      startIdx += size;

      final theme = _presetThemes[i % _presetThemes.length];
      final captain = _pickCaptains && members.isNotEmpty ? members.first : null;

      generated.add(TeamGroup(
        name: theme['name'],
        headerColor: theme['color'],
        captain: captain,
        members: members,
      ));
    }

    setState(() {
      _teams = generated;
      _reserves = [];
      _showResult = true;
    });

    localStorageService.addHistoryEntry(HistoryEntry(
      type: 'teams',
      title: 'Divisão em $_teamsCount equipes',
      summary: '${participants.length} participantes · $_teamsCount equipes',
      configSnapshot: {
        'teams_count': _teamsCount,
        'participants': participants,
      },
      result: generated.map((t) => {'name': t.name, 'members': t.members}).toList(),
    ));
  }

  void _shuffleCaptains() {
    setState(() {
      for (final t in _teams) {
        if (t.members.isNotEmpty) {
          final shuffledMembers = CryptoRandom.shuffle(t.members);
          t.captain = shuffledMembers.first;
        }
      }
    });
  }

  void _shareTeams() {
    final buffer = StringBuffer();
    buffer.writeln('⚽ Divisão de Equipes - Sorte Feita:\n');
    for (final t in _teams) {
      buffer.writeln('${t.name} (${t.members.length} integrantes):');
      for (final m in t.members) {
        final isCap = m == t.captain ? ' ★ (Capitão)' : '';
        buffer.writeln(' - $m$isCap');
      }
      buffer.writeln();
    }
    Share.share(buffer.toString(), subject: 'Equipes Sorte Feita');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipes'),
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
              icon: const Icon(Icons.upload_rounded, size: 22),
              onPressed: _shareTeams,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PARTICIPANTES',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: TextField(
            controller: _participantsController,
            maxLines: 7,
            decoration: const InputDecoration(
              hintText: 'Cole a lista de participantes...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Stepper: Quantidade de equipes
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Número de equipes',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.petroleo,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_teamsCount > 2) setState(() => _teamsCount--);
                    },
                    icon: const Icon(Icons.remove_rounded, color: AppColors.petroleo),
                    style: IconButton.styleFrom(backgroundColor: AppColors.areia),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_teamsCount',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.petroleo,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _teamsCount++),
                    icon: const Icon(Icons.add_rounded, color: AppColors.petroleo),
                    style: IconButton.styleFrom(backgroundColor: AppColors.areia),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Switch: Sortear capitães
        Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: AppColors.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeTrackColor: AppColors.petroleo,
              title: Text(
                'Sortear capitães',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.petroleo,
                ),
              ),
              subtitle: Text(
                'Escolhe um capitão para cada equipe com ★',
                style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.textSecondaryLight),
              ),
              value: _pickCaptains,
              onChanged: (val) => setState(() => _pickCaptains = val),
            ),
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brasa,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _generateTeams,
            child: Text(
              'Dividir em $_teamsCount equipes',
              style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_teamsCount equipes equilibradas',
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.petroleo,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_participantsController.text.split("\n").where((l) => l.trim().isNotEmpty).length} pessoas no total',
          style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 18),

        // Team cards (matching PDF Page 9)
        ..._teams.map((team) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderLight, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with team color
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: team.headerColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        team.name,
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${team.members.length}',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: team.members.map((member) {
                      final isCaptain = member == team.captain;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCaptain) ...[
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.brasa),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            member,
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 15,
                              fontWeight: isCaptain ? FontWeight.w700 : FontWeight.w500,
                              color: AppColors.petroleo,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }),

        if (_reserves.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.nevoa, width: 1.5),
            ),
            child: Row(
              children: [
                Text(
                  'RESERVA',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: AppColors.petroleo,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _reserves.join(', '),
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.petroleo,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // Dividir de novo (Petróleo #0E3B43)
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.petroleo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _generateTeams,
            icon: const Icon(Icons.sync_rounded, size: 22),
            label: Text(
              'Dividir de novo',
              style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Novos capitães / Editar regras
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
                  onPressed: _shuffleCaptains,
                  child: Text(
                    'Novos capitães',
                    style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.petroleo),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                    'Editar regras',
                    style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.petroleo),
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
