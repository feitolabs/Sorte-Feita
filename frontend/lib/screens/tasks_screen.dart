import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/random/crypto_random.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _peopleController = TextEditingController(
    text: 'Ana\nBruno\nCarla\nDiego',
  );
  final TextEditingController _tasksController = TextEditingController(
    text: 'Lavar a louça\nTirar o lixo\nVarrer a sala\nComprar o pão',
  );

  Map<String, String> _assignments = {};
  bool _showResult = false;

  void _assignTasks() {
    final people = _peopleController.text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final tasks = _tasksController.text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    if (people.isEmpty || tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insira pelo menos 1 pessoa e 1 tarefa')),
      );
      return;
    }

    final shuffledTasks = CryptoRandom.shuffle(tasks);
    final result = <String, String>{};

    for (int i = 0; i < shuffledTasks.length; i++) {
      final person = people[i % people.length];
      if (result.containsKey(person)) {
        result[person] = '${result[person]}, ${shuffledTasks[i]}';
      } else {
        result[person] = shuffledTasks[i];
      }
    }

    setState(() {
      _assignments = result;
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribuição de Tarefas'),
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
        Text('PESSOAS', style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.textPrimaryLight)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
          child: TextField(
            controller: _peopleController,
            maxLines: 4,
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(14)),
          ),
        ),
        const SizedBox(height: 18),
        Text('TAREFAS', style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.textPrimaryLight)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
          child: TextField(
            controller: _tasksController,
            maxLines: 4,
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(14)),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brasa, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: _assignTasks,
            child: Text('Distribuir tarefas', style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    return Column(
      children: [
        ..._assignments.entries.map((e) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.azulRio, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key, style: GoogleFonts.bricolageGrotesque(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.petroleo)),
                      const SizedBox(height: 2),
                      Text(e.value, style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textSecondaryLight)),
                    ],
                  ),
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
            onPressed: _assignTasks,
            child: Text('Distribuir de novo', style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }
}
