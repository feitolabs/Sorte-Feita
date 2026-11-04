import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/random/crypto_random.dart';

class PairsScreen extends StatefulWidget {
  const PairsScreen({super.key});

  @override
  State<PairsScreen> createState() => _PairsScreenState();
}

class _PairsScreenState extends State<PairsScreen> {
  final TextEditingController _controller = TextEditingController(
    text: 'Ana\nBruno\nCarla\nDiego\nEduarda\nFelipe\nGabriela',
  );

  int _groupSize = 2; // 2 for duplas, 3 for trios
  List<List<String>> _groups = [];
  bool _showResult = false;

  void _generate() {
    final participants = _controller.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (participants.length < _groupSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insira pelo menos $_groupSize participantes')),
      );
      return;
    }

    final shuffled = CryptoRandom.shuffle(participants);
    final List<List<String>> result = [];

    for (int i = 0; i < shuffled.length; i += _groupSize) {
      if (i + _groupSize <= shuffled.length) {
        result.add(shuffled.sublist(i, i + _groupSize));
      } else {
        // Handle odd remainder: append to last group to make trio or keep as remainder
        if (result.isNotEmpty) {
          result.last.addAll(shuffled.sublist(i));
        } else {
          result.add(shuffled.sublist(i));
        }
      }
    }

    setState(() {
      _groups = result;
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duplas e Trios'),
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
          padding: const EdgeInsets.all(20),
          child: _showResult ? _buildResult() : _buildConfig(),
        ),
      ),
    );
  }

  Widget _buildConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TIPO DE FORMAÇÃO', style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.textPrimaryLight)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('Duplas (2)')),
                selected: _groupSize == 2,
                onSelected: (_) => setState(() => _groupSize = 2),
                selectedColor: AppColors.petroleo,
                labelStyle: TextStyle(color: _groupSize == 2 ? Colors.white : AppColors.petroleo, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('Trios (3)')),
                selected: _groupSize == 3,
                onSelected: (_) => setState(() => _groupSize = 3),
                selectedColor: AppColors.petroleo,
                labelStyle: TextStyle(color: _groupSize == 3 ? Colors.white : AppColors.petroleo, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('PARTICIPANTES', style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.textPrimaryLight)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
          child: TextField(
            controller: _controller,
            maxLines: 8,
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16)),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brasa, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: _generate,
            child: Text('Formar ${_groupSize == 2 ? "duplas" : "trios"}', style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    return Column(
      children: [
        ..._groups.asMap().entries.map((entry) {
          final idx = entry.key + 1;
          final members = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: AppColors.azulRio, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('$idx', style: GoogleFonts.bricolageGrotesque(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(members.join(' & '), style: GoogleFonts.bricolageGrotesque(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.petroleo)),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.petroleo, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: _generate,
            child: Text('Formar novamente', style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }
}

