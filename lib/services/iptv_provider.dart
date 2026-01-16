import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/iptv_models.dart';
import '../services/iptv_service.dart';

class IPTVProvider with ChangeNotifier {
  final IPTVService _service = IPTVService();
  static const String _favKey = 'favorite_channels';

  List<ChannelModel> _allChannels = [];
  List<ChannelModel> _filteredChannels = [];
  List<Category> _categories = [];
  Set<String> _favoriteIds = {};
  String _selectedCategory = 'all';
  String _searchQuery = '';
  String _sidebarOption = 'Live TV';
  bool _isLoading = false;
  bool _showOnlyFavorites = false;
  ChannelModel? _selectedChannel;
  String? _error;

  List<ChannelModel> get filteredChannels => _filteredChannels;
  List<Category> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get sidebarOption => _sidebarOption;
  ChannelModel? get selectedChannel => _selectedChannel;
  bool get isLoading => _isLoading;
  bool get showOnlyFavorites => _showOnlyFavorites;
  String? get error => _error;

  IPTVProvider() {
    loadData();
  }

  void playChannel(ChannelModel? channel) {
    _selectedChannel = channel;
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

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _loadFavorites();
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

  // Helper to get featured channel (limit to 1st for now)
  ChannelModel? get featuredChannel =>
      _allChannels.isNotEmpty ? _allChannels.first : null;
}
