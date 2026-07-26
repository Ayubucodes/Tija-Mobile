import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityState with ChangeNotifier {
  bool _isConnectedToNetwork = true;
  bool get connectivityStatus => _isConnectedToNetwork;

  bool _networkConnectivityStatus = false;
  bool get networkConnectivityStatus => _networkConnectivityStatus;

  bool _isLoadingConnectivityStatus = false;
  bool get isLoadingConnectivityStatus => _isLoadingConnectivityStatus;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityState() {
    _initializeConnectivityState();
  }

  void changeConnectivityStatus({bool isConnected = false}) {
    _isConnectedToNetwork = isConnected;
    notifyListeners();
  }

  void initializeConnectionStatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    _isConnectedToNetwork =
        connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);

    notifyListeners();
  }

  void _initializeConnectivityState() async {
    _isLoadingConnectivityStatus = true;
    List<ConnectivityResult> connectivityResult = await _connectivity
        .checkConnectivity();
    _updateConnectivityStatus(connectivityResult);
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectivityStatus,
    );
  }

  void _updateConnectivityStatus(
    List<ConnectivityResult> connectivityResult,
  ) async {
    _networkConnectivityStatus =
        connectivityResult.isNotEmpty &&
        !connectivityResult.contains(ConnectivityResult.none);
    _isConnectedToNetwork = _networkConnectivityStatus;
    _isLoadingConnectivityStatus = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
