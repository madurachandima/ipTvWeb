import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme.dart';
import '../services/iptv_provider.dart';
import '../models/iptv_models.dart';

class ChannelGrid extends StatelessWidget {
  const ChannelGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IPTVProvider>(
      builder: (context, provider, child) {
        final channels = provider.filteredChannels;

        if (channels.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text('No channels found')),
          );
        }

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 0.85,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final channelModel = channels[index];
            return _ChannelCard(channel: channelModel);
          }, childCount: channels.length),
        );
      },
    );
  }
}

class _ChannelCard extends StatefulWidget {
  final ChannelModel channel;

  const _ChannelCard({required this.channel});

  @override
  State<_ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<_ChannelCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final channel = widget.channel.channel;
    final logoUrl = widget.channel.logo?.url;
    final category = channel.categories.isNotEmpty
        ? channel.categories.first
        : 'General';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.read<IPTVProvider>().playChannel(widget.channel);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isHovered
              ? Matrix4.diagonal3Values(1.05, 1.05, 1.0)
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: CodeThemes.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? CodeThemes.primaryColor.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.05),
              width: 2,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: CodeThemes.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (logoUrl != null)
                        CachedNetworkImage(
                          imageUrl: logoUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: CodeThemes.primaryColor,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(
                              Icons.live_tv_rounded,
                              size: 48,
                              color: Colors.white24,
                            ),
                          ),
                        )
                      else
                        const Center(
                          child: Icon(
                            Icons.live_tv_rounded,
                            size: 48,
                            color: Colors.white24,
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Consumer<IPTVProvider>(
                          builder: (context, provider, _) {
                            final isFav = provider.isFavorite(
                              widget.channel.channel.id,
                            );
                            return IconButton(
                              onPressed: () => provider.toggleFavorite(
                                widget.channel.channel.id,
                              ),
                              icon: Icon(
                                isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFav
                                    ? Colors.redAccent
                                    : Colors.white70,
                                size: 20,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withValues(
                                  alpha: 0.5,
                                ),
                                padding: const EdgeInsets.all(4),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: CodeThemes.backgroundColor.withValues(
                              alpha: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.play_arrow_rounded, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            channel.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_isHovered)
                          const Icon(
                            Icons.play_circle_fill_rounded,
                            color: CodeThemes.primaryColor,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
