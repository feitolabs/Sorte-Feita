import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'wheel_screen.dart';
import 'name_draw_screen.dart';
import 'number_draw_screen.dart';
import 'teams_screen.dart';
import 'pairs_screen.dart';
import 'decision_screen.dart';
import 'letters_screen.dart';
import 'tasks_screen.dart';
import 'cards_screen.dart';
import 'challenges_screen.dart';

class ToolItem {
  final String title;
  final String subtitle;
  final String iconPath;
  final IconData fallbackIcon;
  final String category;
  final Widget screen;

  const ToolItem({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.fallbackIcon,
    required this.category,
    required this.screen,
  });
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _selectedCategory = 'Todas';

  final List<String> _categories = [
    'Todas',
    'Roletas',
    'Sorteios',
    'Grupos',
    'Decisões',
  ];

  final List<ToolItem> _tools = [
    const ToolItem(
      title: 'Roleta',
      subtitle: 'Gire e decida',
      iconPath: 'assets/interface/ferramentas/roleta.svg',
      fallbackIcon: Icons.pie_chart_outline_rounded,
      category: 'Roletas',
      screen: WheelScreen(),
    ),
    const ToolItem(
      title: 'Nomes',
      subtitle: 'Ganhadores e suplentes',
      iconPath: 'assets/interface/ferramentas/nomes.svg',
      fallbackIcon: Icons.format_list_bulleted_rounded,
      category: 'Sorteios',
      screen: NameDrawScreen(),
    ),
    const ToolItem(
      title: 'Números',
      subtitle: 'Intervalo e exclusões',
      iconPath: 'assets/interface/ferramentas/numeros.svg',
      fallbackIcon: Icons.tag_rounded,
      category: 'Sorteios',
      screen: NumberDrawScreen(),
    ),
    const ToolItem(
      title: 'Equipes',
      subtitle: 'Grupos equilibrados',
      iconPath: 'assets/interface/ferramentas/equipes.svg',
      fallbackIcon: Icons.groups_rounded,
      category: 'Grupos',
      screen: TeamsScreen(),
    ),
    const ToolItem(
      title: 'Duplas e trios',
      subtitle: 'Sobras resolvidas',
      iconPath: 'assets/interface/ferramentas/duplas-trios.svg',
      fallbackIcon: Icons.people_outline_rounded,
      category: 'Grupos',
      screen: PairsScreen(),
    ),
    const ToolItem(
      title: 'Tarefas',
      subtitle: 'Quem faz o quê',
      iconPath: 'assets/interface/ferramentas/tarefas.svg',
      fallbackIcon: Icons.assignment_turned_in_outlined,
      category: 'Grupos',
      screen: TasksScreen(),
    ),
    const ToolItem(
      title: 'Sim ou não',
      subtitle: 'Resposta na hora',
      iconPath: 'assets/interface/ferramentas/sim-ou-nao.svg',
      fallbackIcon: Icons.check_circle_outline_rounded,
      category: 'Decisões',
      screen: DecisionScreen(),
    ),
    const ToolItem(
      title: 'Cartas',
      subtitle: 'Monte seu baralho',
      iconPath: 'assets/interface/ferramentas/cartas.svg',
      fallbackIcon: Icons.style_outlined,
      category: 'Decisões',
      screen: CardsScreen(),
    ),
    const ToolItem(
      title: 'Letras',
      subtitle: 'De A a Z',
      iconPath: 'assets/interface/ferramentas/letras.svg',
      fallbackIcon: Icons.text_fields_rounded,
      category: 'Sorteios',
      screen: LettersScreen(),
    ),
    const ToolItem(
      title: 'Desafios',
      subtitle: 'Leves e para todos',
      iconPath: 'assets/interface/ferramentas/desafios.svg',
      fallbackIcon: Icons.star_border_rounded,
      category: 'Decisões',
      screen: ChallengesScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'Todas'
        ? _tools
        : _tools.where((t) => t.category == _selectedCategory).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ferramentas',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.petroleo,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Todas liberadas, sem cadastro e sem pagar nada.',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 15,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 18),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.petroleo,
                        labelStyle: GoogleFonts.hankenGrotesk(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.petroleo,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.petroleo : AppColors.borderLight,
                          ),
                        ),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Responsive Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildToolCard(item);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(ToolItem item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => item.screen),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: SvgPicture.asset(
                item.iconPath,
                colorFilter: const ColorFilter.mode(AppColors.petroleo, BlendMode.srcIn),
                placeholderBuilder: (_) => Icon(item.fallbackIcon, size: 28, color: AppColors.petroleo),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.petroleo,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

