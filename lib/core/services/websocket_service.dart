import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../config/api_config.dart';

class WebSocketService extends GetxService {
  late WebSocketChannel _channel;

  String get _url {
    // Convert http/https to ws/wss
    final baseUrl = ApiConfig.baseUrl;
    if (baseUrl.startsWith('https://')) {
      return baseUrl.replaceFirst('https://', 'wss://');
    } else {
      return baseUrl.replaceFirst('http://', 'ws://');
    }
  }

  // Connection state
  final isConnected = false.obs;
  Timer? _reconnectTimer;

  // Global Streams
  final routerStatus = <String, dynamic>{}.obs;
  final activeUserStats = <String, dynamic>{}.obs;
  final latestLogs = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    connect();
  }

  @override
  void onClose() {
    _channel.sink.close();
    _reconnectTimer?.cancel();
    super.onClose();
  }

  void connect() {
    try {
      print('Connecting to WebSocket: $_url');
      _channel = WebSocketChannel.connect(Uri.parse(_url));

      _channel.stream.listen(
        (message) {
          isConnected.value = true;
          _handleMessage(message);
        },
        onDone: () {
          print('WebSocket closed');
          isConnected.value = false;
          _scheduleReconnect();
        },
        onError: (error) {
          print('WebSocket error: $error');
          isConnected.value = false;
          _scheduleReconnect();
        },
      );
    } catch (e) {
      print('WebSocket connection failed: $e');
      isConnected.value = false;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive ?? false) return;

    print('Scheduling reconnect in 5 seconds...');
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      connect();
    });
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);

      // Expected format: { "type": "...", "data": ... }
      if (data is Map<String, dynamic>) {
        final type = data['type'];
        final payload = data['data'];

        switch (type) {
          case 'router_stats':
            routerStatus.value = payload;
            break;
          case 'active_users':
            activeUserStats.value = payload;
            break;
          case 'logs':
            if (payload is List) {
              latestLogs.assignAll(payload.map((e) => e.toString()).toList());
            }
            break;
          default:
            print('Unknown message type: $type');
        }
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  void sendMessage(String type, dynamic data) {
    if (isConnected.value) {
      final message = jsonEncode({'type': type, 'data': data});
      _channel.sink.add(message);
    }
  }
}
