import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../widgets/sidebar.dart';
import '../widgets/channel_grid.dart';
import '../widgets/content_header.dart';
import '../services/iptv_provider.dart';
import '../widgets/video_player_overlay.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CodeThemes.backgroundColor,
                  Color(0xFF1E1B4B), // Indigo 950
                ],
              ),
            ),
          ),

          Row(
            children: [
              // Sidebar
              Consumer<IPTVProvider>(
                builder: (context, provider, child) {
                  return Sidebar(
                    selectedOption: provider.sidebarOption,
                    onOptionSelected: (option) =>
                        provider.setSidebarOption(option),
                  );
                },
              ),

              // Main Content
              Expanded(
                child: Consumer<IPTVProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: CodeThemes.primaryColor,
                        ),
                      );
                    }

                    if (provider.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 16),
                            Text('Error: ${provider.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => provider.loadData(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return CustomScrollView(
                      slivers: [
                        const SliverToBoxAdapter(child: ContentHeader()),
                        SliverPadding(
                          padding: const EdgeInsets.all(32.0),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Live TV Categories',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    const Spacer(),
                                    _buildSearchBar(context, provider),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildCategoryChips(context, provider),
                              ],
                            ),
                          ),
                        ),
                        const SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 32.0),
                          sliver: ChannelGrid(),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 50)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          // Video Player Overlay
          Consumer<IPTVProvider>(
            builder: (context, provider, child) {
              if (provider.selectedChannel != null) {
                return VideoPlayerOverlay(channel: provider.selectedChannel!);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, IPTVProvider provider) {
    return Container(
      width: 300,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        onChanged: (val) => provider.setSearchQuery(val),
        decoration: const InputDecoration(
          hintText: 'Search channels...',
          prefixIcon: Icon(Icons.search, size: 20, color: Colors.white54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, IPTVProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: provider.categories.take(20).map((cat) {
          final isSelected = provider.selectedCategory == cat.id;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: FilterChip(
              label: Text(cat.name),
              selected: isSelected,
              onSelected: (val) {
                provider.setSelectedCategory(cat.id);
              },
              backgroundColor: CodeThemes.surfaceColor,
              selectedColor: CodeThemes.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
