import 'package:flutter/material.dart';
import 'package:tija/models/author_model.dart';
import 'package:tija/services/author_service.dart';

class AuthorState extends ChangeNotifier {
  List<Author> _authors = [];
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';

  AuthorDetail? _authorDetail;
  bool _isDetailLoading = false;
  bool _isDetailError = false;
  String _detailErrorMessage = '';

  AuthorDashboard? _authorDashboard;
  bool _isDashboardLoading = false;
  bool _isDashboardError = false;
  String _dashboardErrorMessage = '';

  List<Author> get authors => _authors;
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  String get errorMessage => _errorMessage;

  AuthorDetail? get authorDetail => _authorDetail;
  bool get isDetailLoading => _isDetailLoading;
  bool get isDetailError => _isDetailError;
  String get detailErrorMessage => _detailErrorMessage;

  AuthorDashboard? get authorDashboard => _authorDashboard;
  bool get isDashboardLoading => _isDashboardLoading;
  bool get isDashboardError => _isDashboardError;
  String get dashboardErrorMessage => _dashboardErrorMessage;

  // ── Get Authors ───────────────────────────────────────────────────────────
  Future<bool> getAuthors() async {

    _isLoading = true;
    _isError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await AuthorService.getAuthors();

      if (result != null) {
        _authors = result.items;
        _isError = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isError = true;
        _errorMessage = 'Failed to load authors.';
      }
    } catch (e) {
      _isError = true;
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Get Author By ID ──────────────────────────────────────────────────────
  Future<bool> getAuthorById(String id) async {
    _isDetailLoading = true;
    _isDetailError = false;
    _detailErrorMessage = '';
    notifyListeners();

    try {
      final result = await AuthorService.getAuthorById(id);

      if (result != null) {
        _authorDetail = result;
        _isDetailError = false;
        _isDetailLoading = false;
        notifyListeners();
        return true;
      } else {
        _isDetailError = true;
        _detailErrorMessage = 'Failed to load author details.';
      }
    } catch (e) {
      _isDetailError = true;
      _detailErrorMessage = e.toString();
    }

    _isDetailLoading = false;
    notifyListeners();
    return false;
  }

  // ── Get Author Dashboard ──────────────────────────────────────────────────
  Future<bool> getAuthorDashboard() async {
    _isDashboardLoading = true;
    _isDashboardError = false;
    _dashboardErrorMessage = '';
    notifyListeners();

    try {
      final result = await AuthorService.getAuthorDashboard();

      if (result != null) {
        _authorDashboard = result;
        _isDashboardError = false;
        _isDashboardLoading = false;
        notifyListeners();
        return true;
      } else {
        _isDashboardError = true;
        _dashboardErrorMessage = 'Failed to load author dashboard.';
      }
    } catch (e) {
      _isDashboardError = true;
      _dashboardErrorMessage = e.toString();
    }

    _isDashboardLoading = false;
    notifyListeners();
    return false;
  }
}
