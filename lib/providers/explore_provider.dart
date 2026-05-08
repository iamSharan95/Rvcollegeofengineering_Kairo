import 'package:flutter/material.dart';
import '../models/content_item.dart';
import '../services/news_service.dart';

class ExploreProvider with ChangeNotifier {
  final NewsService _newsService = NewsService();
  List<ContentItem> _items = [];
  bool _isLoading = false;

  List<ContentItem> get items => _items;
  bool get isLoading => _isLoading;

  ExploreProvider() {
    fetchContent();
  }

  Future<void> fetchContent({bool refresh = false}) async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final newContent = await _newsService.fetchDiscoveryContent();
      if (refresh) {
        _items = newContent;
      } else {
        _items.addAll(newContent);
      }
    } catch (e) {
      debugPrint("Explore Scout Error: \$e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
