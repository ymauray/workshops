import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lxd/lxd.dart';
import 'package:lxd_service/lxd_service.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class InstanceInfoModel extends SafeChangeNotifier {
  InstanceInfoModel({
    required this.instanceName,
    required this.service,
    @visibleForTesting Duration? updateInterval,
  }) : _updateInterval = updateInterval ?? const Duration(seconds: 1);
  final String instanceName;
  final Duration _updateInterval;
  final LxdService service;
  bool initialized = false;

  late LxdInstanceState _instanceState;
  late final LxdInstance _instance;
  Timer? _timer;

  LxdInstance get instance => _instance;
  LxdInstanceState get instanceState => _instanceState;

  Future<void> init() async {
    _instance = await service.getInstance(instanceName);
    await _updateInstanceState();
    _timer = Timer.periodic(
      _updateInterval,
      (_) => _updateInstanceState(),
    );
    initialized = true;
    notifyListeners();
  }

  Future<void> _updateInstanceState() async {
    _instanceState = await service.getInstanceState(instanceName);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
