import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/storage/local_storage_service.dart';
import '../widgets/ad_banner.dart';
import 'wheel_screen.dart';
import 'name_draw_screen.dart';
import 'teams_screen.dart';
import 'decision_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenCatalog;
  final VoidCallback onOpenHistory;

  const HomeScreen({
    super.key,
    required this.onOpenCatalog,
    required this.onOpenHistory,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: localStorageService,
          builder: (context, _) {
            final recents = localStorageService.history.take(3).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Sorte Feita logo + Favorite heart icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/icone/png/sorte-feita-icone-48.png',
                            width: 32,
                            height: 32,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.pie_chart_rounded,
                              color: AppColors.azulRio,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Row(
                            children: [
                              Text(
                                'sorte ',
                                style: GoogleFonts.bricolageGrotesque(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.petroleo,
                                ),
                              ),
                              Text(
                                'feita',
                                style: GoogleFonts.bricolageGrotesque(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.azulRio,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border_rounded, color: AppColors.petroleo, size: 22),
                          onPressed: widget.onOpenHistory,
                          tooltip: 'Favoritos e Histórico',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Title: "O que vamos sortear hoje?"
                  Text(
                    'O que vamos sortear hoje?',
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.petroleo,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight, width: 1.5),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Buscar ferramenta ou modelo',
                        hintStyle: GoogleFonts.hankenGrotesk(
                          fontSize: 15,
                          color: AppColors.textSecondaryLight,
                        ),
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
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3 Big Featured Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        children: [
                          Expanded(
                            child: _buildBigCard(
                              title: 'Roleta',
                              color: AppColors.petroleo,
                              textColor: Colors.white,
                              iconPath: 'assets/interface/ferramentas/roleta.svg',
                              fallbackIcon: Icons.pie_chart_outline_rounded,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const WheelScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBigCard(
                              title: 'Nomes',
                              color: AppColors.azulRio,
                              textColor: Colors.white,
                              iconPath: 'assets/interface/ferramentas/nomes.svg',
                              fallbackIcon: Icons.format_list_bulleted_rounded,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const NameDrawScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBigCard(
                              title: 'Equipes',
                              color: AppColors.nevoa,
                              textColor: AppColors.petroleo,
                              iconPath: 'assets/interface/ferramentas/equipes.svg',
                              fallbackIcon: Icons.groups_rounded,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const TeamsScreen()),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Section: RECENTES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RECENTES',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onOpenHistory,
                        child: Text(
                          'Ver histórico',
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

                  // Recents list
                  if (recents.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      alignment: Alignment.center,
                      child: Text(
                        'Nenhum sorteio recente ainda. Comece girando uma roleta!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    )
                  else
                    ...recents.map((entry) => _buildRecentItem(entry)),

                  const SizedBox(height: 16),

                  // ESPAÇO DE ANÚNCIO (Ad placeholder per spec)
                  const AdBanner(placement: 'home'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBigCard({
    required String title,
    required Color color,
    required Color textColor,
    required String iconPath,
    required IconData fallbackIcon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                placeholderBuilder: (_) => Icon(fallbackIcon, size: 28, color: textColor),
              ),
            ),
            Text(
              title,
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItem(dynamic entry) {
    final isWheel = entry.type == 'wheel';
    final iconColor = isWheel ? AppColors.petroleo : AppColors.azulRio;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.borderLight),
        ),
        child: ListTile(
          onTap: () {
            if (isWheel) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WheelScreen()));
            } else if (entry.type == 'name_draw') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NameDrawScreen()));
            } else if (entry.type == 'teams') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamsScreen()));
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DecisionScreen()));
            }
          },
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isWheel ? Icons.pie_chart_outline_rounded : Icons.format_list_bulleted_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          title: Text(
            entry.title,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.petroleo,
            ),
          ),
          subtitle: Text(
            entry.summary,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.petroleo,
          ),
        ),
      ),
    );
  }
}
