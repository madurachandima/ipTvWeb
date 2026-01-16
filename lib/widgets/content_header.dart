import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme.dart';
import '../services/iptv_provider.dart';

class ContentHeader extends StatelessWidget {
  const ContentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Consumer<IPTVProvider>(
      builder: (context, provider, child) {
        final featured = provider.featuredChannel;

        if (featured == null) {
          return SizedBox(
            height: isMobile ? 300 : 400,
            child: const Center(child: Text('No featured content')),
          );
        }

        return Container(
          height: isMobile ? 300 : 400,
          width: double.infinity,
          decoration: BoxDecoration(
            color: CodeThemes.surfaceColor,
            image: featured.logo != null
                ? DecorationImage(
                    image: CachedNetworkImageProvider(featured.logo!.url),
                    fit: BoxFit.contain,
                    opacity: 0.2,
                  )
                : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [CodeThemes.backgroundColor, Colors.transparent],
              ),
            ),
            padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'FEATURED CHANNEL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  featured.channel.name,
                  style: TextStyle(
                    fontSize: isMobile ? 32 : 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Country: ${featured.channel.country ?? "Global"} | Categories: ${featured.channel.categories.join(", ")}',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildWatchButton(context, featured),
                      const SizedBox(height: 12),
                      _buildDetailsButton(),
                    ],
                  )
                else
                  Row(
                    children: [
                      _buildWatchButton(context, featured),
                      const SizedBox(width: 16),
                      _buildDetailsButton(),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWatchButton(BuildContext context, dynamic featured) {
    return ElevatedButton.icon(
      onPressed: () {
        context.read<IPTVProvider>().playChannel(featured);
      },
      icon: const Icon(Icons.play_arrow_rounded),
      label: const Text('Watch Live'),
      style: ElevatedButton.styleFrom(
        backgroundColor: CodeThemes.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailsButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.info_outline_rounded),
      label: const Text('Channel Details'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      ),
    );
  }
}
