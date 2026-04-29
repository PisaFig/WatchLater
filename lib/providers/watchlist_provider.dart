import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/content_item.dart';

class WatchlistProvider extends ChangeNotifier {
  static const _boxName = 'watchlist';

  late Box _box;
  List<ContentItem> _watchlist = [];
  String _activeFilter = 'all';

  List<ContentItem> get watchlist => _watchlist;
  String get activeFilter => _activeFilter;

  Future<void> loadWatchlist() async {
    _box = await Hive.openBox(_boxName);
    _watchlist = _box.values
        .whereType<ContentItem>()
        .toList();
    notifyListeners();
  }

  void addToWatchlist(ContentItem item) {
    if (isInWatchlist(item.id)) return;
    final saved = item.copyWith(isSaved: true);
    _box.put(saved.id, saved);
    _watchlist.add(saved);
    notifyListeners();
  }

  void removeFromWatchlist(String id) {
    _box.delete(id);
    _watchlist.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  bool isInWatchlist(String id) => _watchlist.any((item) => item.id == id);

  bool isItemWatched(String id) =>
      _watchlist.any((item) => item.id == id && item.isWatched);

  void toggleWatched(String id) {
    final idx = _watchlist.indexWhere((item) => item.id == id);
    if (idx == -1) return;
    final updated =
        _watchlist[idx].copyWith(isWatched: !_watchlist[idx].isWatched);
    _box.put(id, updated);
    _watchlist[idx] = updated;
    notifyListeners();
  }

  void clearAll() {
    _box.clear();
    _watchlist.clear();
    notifyListeners();
  }

  List<ContentItem> filterByType(String type) {
    _activeFilter = type;
    notifyListeners();
    if (type == 'all') return _watchlist;
    return _watchlist.where((item) => item.contentType == type).toList();
  }

  List<ContentItem> get filteredWatchlist {
    if (_activeFilter == 'all') return _watchlist;
    return _watchlist
        .where((item) => item.contentType == _activeFilter)
        .toList();
  }
}
