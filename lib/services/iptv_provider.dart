import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/iptv_models.dart';
import '../services/iptv_service.dart';

class IPTVProvider with ChangeNotifier {
  final IPTVService _service = IPTVService();
  static const String _favKey = 'favorite_channels';
  static const String _playerKey = 'default_player';
  static const String _recentKey = 'recent_channels';

  List<ChannelModel> _allChannels = [];
  List<ChannelModel> _filteredChannels = [];
  List<Category> _categories = [];
  Set<String> _favoriteIds = {};
  List<String> _recentIds = [];
  String _selectedCategory = 'all';
  String _searchQuery = '';
  String _sidebarOption = 'Live TV';
  bool _isLoading = false;
  bool _showOnlyFavorites = false;
  ChannelModel? _selectedChannel;
  String? _error;
  bool _useMediaKitByDefault = false;

  List<ChannelModel> get filteredChannels => _filteredChannels;
  List<Category> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get sidebarOption => _sidebarOption;
  ChannelModel? get selectedChannel => _selectedChannel;
  bool get isLoading => _isLoading;
  bool get showOnlyFavorites => _showOnlyFavorites;
  String? get error => _error;
  bool get useMediaKitByDefault => _useMediaKitByDefault;

  IPTVProvider() {
    loadData();
  }

  void playChannel(ChannelModel? channel) {
    _selectedChannel = channel;
    if (channel != null) {
      _addToRecent(channel.channel.id);
    }
    notifyListeners();
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    await _saveFavorites();
    _applyFilters();
    notifyListeners();
  }

  void setShowOnlyFavorites(bool value) {
    _showOnlyFavorites = value;
    _applyFilters();
    notifyListeners();
  }

  Future<void> setUseMediaKitByDefault(bool value) async {
    _useMediaKitByDefault = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_playerKey, value);
    notifyListeners();
  }

  Future<void> clearFavorites() async {
    _favoriteIds.clear();
    await _saveFavorites();
    _applyFilters();
    notifyListeners();
  }

  Future<void> clearRecents() async {
    _recentIds.clear();
    await _saveRecents();
    _applyFilters();
    notifyListeners();
  }

  void _addToRecent(String id) {
    _recentIds.remove(id);
    _recentIds.insert(0, id);
    if (_recentIds.length > 50) {
      _recentIds = _recentIds.sublist(0, 50);
    }
    _saveRecents();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _loadFavorites();
      await _loadSettings();
      await _loadRecents();
      _allChannels = await _service.fetchChannels();
      _categories = await _service.fetchCategories();

      // Add 'All' category if not present or just for UI
      if (!_categories.any((c) => c.id == 'all')) {
        _categories.insert(0, Category(id: 'all', name: 'All Channels'));
      }

      _applyFilters();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSidebarOption(String option) {
    _sidebarOption = option;
    _showOnlyFavorites = option == 'Favorites';
    _applyFilters();
    notifyListeners();
  }

  void setSelectedCategory(String categoryId) {
    _selectedCategory = categoryId;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    if (_sidebarOption == 'Recent') {
      final recentChannels = <ChannelModel>[];
      for (final id in _recentIds) {
        try {
          final channel = _allChannels.firstWhere((c) => c.channel.id == id);
          recentChannels.add(channel);
        } catch (_) {
          // Channel not found in current list, skip
        }
      }
      _filteredChannels = recentChannels;
      return;
    }

    _filteredChannels = _allChannels.where((c) {
      if (_showOnlyFavorites && !_favoriteIds.contains(c.channel.id)) {
        return false;
      }
      final matchesCategory =
          _selectedCategory == 'all' ||
          c.channel.categories.contains(_selectedCategory);
      final matchesSearch =
          _searchQuery.isEmpty ||
          c.channel.name.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? recents = prefs.getStringList(_recentKey);
    if (recents != null) {
      _recentIds = recents;
    }
  }

  Future<void> _saveRecents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, _recentIds);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favs = prefs.getStringList(_favKey);
    if (favs != null) {
      _favoriteIds = favs.toSet();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favKey, _favoriteIds.toList());
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _useMediaKitByDefault = prefs.getBool(_playerKey) ?? false;
  }

  // Helper to get featured channel (limit to 1st for now)
  ChannelModel? get featuredChannel =>
      _allChannels.isNotEmpty ? _allChannels.first : null;
}
