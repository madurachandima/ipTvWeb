import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

class Sidebar extends StatelessWidget {
  final String selectedOption;
  final Function(String) onOptionSelected;
  final double? width;
  const Sidebar({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
    this.width = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: width == null
            ? Colors.transparent
            : Colors.white.withValues(alpha: 0.05),
        border: width == null
            ? null
            : Border(
                right: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              const SizedBox(height: 50),
              _buildLogo(),
              const SizedBox(height: 50),
              _buildMenuItem(
                Icons.live_tv_rounded,
                'Live TV',
                selectedOption == 'Live TV',
              ),
              _buildMenuItem(
                Icons.favorite_outline_rounded,
                'Favorites',
                selectedOption == 'Favorites',
              ),
              _buildMenuItem(
                Icons.history_rounded,
                'Recent',
                selectedOption == 'Recent',
              ),
              const Spacer(),
              _buildMenuItem(Icons.settings_outlined, 'Settings', false),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CodeThemes.primaryColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CodeThemes.primaryColor.withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'IPTV Web',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? CodeThemes.primaryColor.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: CodeThemes.primaryColor.withValues(alpha: 0.5))
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? CodeThemes.primaryColor : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => onOptionSelected(title),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
