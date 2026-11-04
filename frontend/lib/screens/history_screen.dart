import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/storage/local_storage_service.dart';
import '../models/wheel_model.dart';
import 'wheel_screen.dart';
import 'name_draw_screen.dart';
import 'teams_screen.dart';
import 'number_draw_screen.dart';
import 'decision_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'Todos';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['Todos', 'Roleta', 'Nomes', 'Números', 'Equipes', 'Decisões'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Limpar Histórico',
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.petroleo,
          ),
        ),
        content: Text(
          'Tem certeza que deseja apagar todo o histórico local? Esta ação não pode ser desfeita.',
          style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textPrimaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondaryLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              localStorageService.clearHistory();
              Navigator.pop(ctx);
            },
            child: Text('Limpar Tudo', style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.petroleo),
            tooltip: 'Limpar histórico',
            onPressed: _confirmClearHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: localStorageService,
          builder: (context, _) {
            final allItems = localStorageService.history;

            final filtered = allItems.where((item) {
              if (_selectedFilter == 'Roleta' && item.type != 'wheel') return false;
              if (_selectedFilter == 'Nomes' && item.type != 'name_draw') return false;
              if (_selectedFilter == 'Números' && item.type != 'number_draw') return false;
              if (_selectedFilter == 'Equipes' && item.type != 'teams') return false;
              if (_selectedFilter == 'Decisões' && item.type != 'decision') return false;

              if (_searchQuery.isNotEmpty) {
                final matchTitle = item.title.toLowerCase().contains(_searchQuery);
                final matchSummary = item.summary.toLowerCase().contains(_searchQuery);
                return matchTitle || matchSummary;
              }
              return true;
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Buscar no histórico...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.petroleo),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppColors.textSecondaryLight),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((f) {
                        final isSel = f == _selectedFilter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(f),
                            selected: isSel,
                            onSelected: (_) => setState(() => _selectedFilter = f),
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.petroleo,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : AppColors.petroleo,
                              fontWeight: FontWeight.w700,
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // List
                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Icon(Icons.history_toggle_off_rounded, size: 56, color: AppColors.nevoa),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhum registro encontrado',
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.petroleo,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Seus sorteios salvos aparecerão aqui',
                            style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filtered.map((item) {
                      final isWheel = item.type == 'wheel';
                      final color = isWheel ? AppColors.petroleo : AppColors.azulRio;

                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                        ),
                        onDismissed: (_) {
                          localStorageService.deleteHistoryEntry(item.id);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.white,
                            clipBehavior: Clip.antiAlias,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                              side: BorderSide(color: AppColors.borderLight),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isWheel ? Icons.pie_chart_outline_rounded : Icons.format_list_bulleted_rounded,
                                  color: color,
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                item.title,
                                style: GoogleFonts.bricolageGrotesque(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.petroleo,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(
                                    item.summary,
                                    style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.textSecondaryLight),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt),
                                    style: GoogleFonts.hankenGrotesk(fontSize: 11, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: item.isFavorite ? AppColors.brasa : AppColors.textSecondaryLight,
                                ),
                                onPressed: () => localStorageService.toggleFavoriteHistory(item.id),
                              ),
                              onTap: () {
                                if (item.type == 'wheel') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => WheelScreen(
                                        initialWheel: WheelModel.fromJson(item.configSnapshot),
                                      ),
                                    ),
                                  );
                                } else if (item.type == 'name_draw') {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NameDrawScreen()));
                                } else if (item.type == 'teams') {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamsScreen()));
                                } else if (item.type == 'number_draw') {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NumberDrawScreen()));
                                } else {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DecisionScreen()));
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
