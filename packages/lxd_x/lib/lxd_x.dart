library lxd_x;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:lxd/lxd.dart';

String resolveLxdSocketPath([String? socketPath]) {
  final lxdDir = Platform.environment['LXD_DIR'];
  final paths = [
    if (socketPath != null) socketPath,
    if (lxdDir != null) '$lxdDir/unix.socket',
    '/var/snap/lxd/common/lxd/unix.socket',
  ];
  return paths.firstWhereOrNull((path) => File(path).existsSync()) ??
      '/var/lib/lxd/unix.socket';
}

extension LxdClientX on LxdClient {
  Future<void> mkdir(LxdInstanceId id, String path) async {
    final op = await execInstance(id, command: ['mkdir', '-p', path]);
    await waitOperation(op.id);
  }

  Future<String> uid(LxdInstanceId id, String username) {
    return _exec(id, ['id', '-u', username]);
  }

  Future<String> gid(LxdInstanceId id, String username) {
    return _exec(id, ['id', '-g', username]);
  }

  Future<String> _exec(LxdInstanceId id, List<String> command) async {
    final exec = await execInstance(
      id,
      command: command,
      interactive: true,
      waitForWebSocket: true,
    );

    Future<WebSocket> getWebSocket(String id) {
      final fd = exec.metadata!['fds'][id] as String;
      return getOperationWebSocket(exec.id, fd);
    }

    final wsc = await getWebSocket('control');
    final ws0 = await getWebSocket('0');

    final out = <String>[];
    final sub = ws0.listen((data) async {
      if (data is List<int>) {
        out.add(utf8.decode(data).trim());
      } else if (data == '') {
        await ws0.close();
        await wsc.close();
      }
    });

    await waitOperation(exec.id);
    await sub.cancel();
    await ws0.close();
    await wsc.close();

    return out.join();
  }
}

extension LxdEventX on LxdEvent {
  bool get isOperation => type == LxdEventType.operation;
  LxdOperation toOperation() {
    return LxdOperation.fromJson(metadata ?? <String, dynamic>{});
  }
}

extension LxdImageX on LxdImage {
  String? get description => properties['description'];
  String? get name => properties['name'];
  String? get os => properties['os'];
  String? get release => properties['release'];
  String? get variant => properties['variant'];
}

extension LxdInstanceX on LxdInstance {
  String? get os => config['image.os'];

  bool get isBusy => isStarting || isStopping;
  bool get isStarting => statusCode == LxdStatusCode.starting;
  bool get isStarted => statusCode == LxdStatusCode.started;
  bool get isRunning => statusCode == LxdStatusCode.running;
  bool get isStopping => statusCode == LxdStatusCode.stopping;
  bool get isStopped => statusCode == LxdStatusCode.stopped;
}

extension LxdNetworkAddressX on LxdNetworkAddress {
  bool get isIPv4 => family == 'inet' && !isLinkLocal;
  bool get isIPv6 => family == 'inet6' && !isLinkLocal;
  bool get isLinkLocal => scope == 'link' || scope == 'local';
}

extension LxdNetworkStateX on LxdNetworkState {
  bool get isLoopback => type == 'loopback';

  List<LxdNetworkAddress> get ipv4s {
    return addresses.where((address) => address.isIPv4).toList();
  }

  List<LxdNetworkAddress> get ipv6s {
    return addresses.where((address) => address.isIPv6).toList();
  }
}

extension LxdOperationX on LxdOperation {
  List<String>? get instances =>
      resources?['instances']?.map((path) => path.split('/').last).toList();

  bool get isRunning => statusCode == LxdStatusCode.running;
  bool get isPending => statusCode == LxdStatusCode.pending;

  String? get downloadProgress => metadata?['download_progress'] as String?;
  String? get unpackProgress =>
      metadata?['create_instance_from_image_unpack_progress'] as String?;
}
