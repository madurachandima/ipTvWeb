import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/iptv_provider.dart';
import '../theme.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 40),
          _buildSection(context, 'Playback', [
            Consumer<IPTVProvider>(
              builder: (context, provider, child) {
                return _buildSwitchTile(
                  'Use Media Kit by Default',
                  'Media Kit is more robust but may use more resources.',
                  provider.useMediaKitByDefault,
                  (val) => provider.setUseMediaKitByDefault(val),
                );
              },
            ),
          ]),
          const SizedBox(height: 32),
          _buildSection(context, 'Data Management', [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Clear Favorites'),
              subtitle: const Text(
                'Remove all channels from your favorites list.',
              ),
              trailing: TextButton(
                onPressed: () => _confirmClearFavorites(context),
                child: const Text(
                  'CLEAR',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Clear Recent History'),
              subtitle: const Text(
                'Remove all channels from your recent history.',
              ),
              trailing: TextButton(
                onPressed: () => _confirmClearRecents(context),
                child: const Text(
                  'CLEAR',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _buildSection(context, 'About Solixa', [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Version'),
              trailing: Text('1.0.0', style: TextStyle(color: Colors.white54)),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Developer'),
              trailing: Text(
                'CodeWithDias',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: CodeThemes.primaryColor,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.white54),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: CodeThemes.primaryColor,
      ),
    );
  }

  void _confirmClearFavorites(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CodeThemes.surfaceColor,
        title: const Text('Clear Favorites?'),
        content: const Text(
          'This will remove all saved channels from your favorites.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              context.read<IPTVProvider>().clearFavorites();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favorites cleared')),
              );
            },
            child: const Text(
              'CLEAR',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearRecents(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CodeThemes.surfaceColor,
        title: const Text('Clear Recent History?'),
        content: const Text('This will remove all recently watched channels.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              context.read<IPTVProvider>().clearRecents();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recent history cleared')),
              );
            },
            child: const Text(
              'CLEAR',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
