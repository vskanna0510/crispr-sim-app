import 'package:flutter/foundation.dart';

import '../models/settings_models.dart';
import '../services/api_service.dart';
import 'theme_provider.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({required ApiService api}) : _api = api;

  final ApiService _api;

  bool isLoading = false;
  String? error;

  bool saveHistory = true;
  bool analyticsEnabled = true;
  AppRating? rating;
  UsageAnalytics? analytics;
  List<HistorySession> sessions = const [];
  List<HistorySimulation> simulations = const [];

  Future<void> loadSettings({ThemeProvider? theme}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final s = await _api.fetchSettings();
      saveHistory = s.saveHistory;
      analyticsEnabled = s.analyticsEnabled;
      theme?.applyFromServer(s.themeMode);
      rating = await _api.fetchRating();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setSaveHistory(bool value) async {
    saveHistory = value;
    notifyListeners();
    try {
      final s = await _api.updateSettings(saveHistory: value);
      saveHistory = s.saveHistory;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setAnalyticsEnabled(bool value) async {
    final previous = analyticsEnabled;
    analyticsEnabled = value;
    if (!value) analytics = null;
    notifyListeners();
    try {
      final s = await _api.updateSettings(
        saveHistory: saveHistory,
        analyticsEnabled: value,
      );
      analyticsEnabled = s.analyticsEnabled;
      saveHistory = s.saveHistory;
      error = null;
      notifyListeners();
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        // Old backend only accepts save_history; keep local toggle.
        error = null;
        notifyListeners();
        return;
      }
      analyticsEnabled = previous;
      error = e.message;
      notifyListeners();
    } catch (e) {
      analyticsEnabled = previous;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> syncTheme(String themeMode) async {
    try {
      final s = await _api.updateSettings(
        saveHistory: saveHistory,
        themeMode: themeMode,
      );
      analyticsEnabled = s.analyticsEnabled;
      saveHistory = s.saveHistory;
      error = null;
      notifyListeners();
    } on ApiException catch (e) {
      // Theme is stored locally; ignore 422 from older API builds.
      if (e.statusCode != 422) {
        error = e.message;
        notifyListeners();
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadAnalytics() async {
    if (!analyticsEnabled) {
      analytics = null;
      notifyListeners();
      return;
    }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      analytics = await _api.fetchAnalytics();
      isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      isLoading = false;
      if (e.statusCode == 404) {
        error = 'Analytics API is not available yet. Rebuild the backend (docker compose up --build).';
      } else if (e.statusCode == 403) {
        error = 'Enable usage analytics in Settings to view your dashboard.';
      } else {
        error = e.message;
      }
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadHistory() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      sessions = await _api.fetchHistorySessions();
      simulations = await _api.fetchHistorySimulations();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> submitRating(int stars, {String? comment}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      rating = await _api.submitRating(stars: stars, comment: comment);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
