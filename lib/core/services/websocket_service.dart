import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:hosphotpro/data/services/token_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../config/api_config.dart';


class WebSocketService extends GetxService {
  final TokenService _tokenService = Get.find<TokenService>();
  WebSocketChannel? _channel;

  String get _url {
    // Convert http/https to ws/wss
    final baseUrl = ApiConfig.baseUrl;
    String wsBase;
    if (baseUrl.startsWith('https://')) {
      wsBase = baseUrl.replaceFirst('https://', 'wss://');
    } else {
      wsBase = baseUrl.replaceFirst('http://', 'ws://');
    }

    final token = _tokenService.getToken();
    // Reverting to root path but keeping token
    return '$wsBase?token=$token';
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
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    super.onClose();
  }

  void connect() {
    if (!_tokenService.hasToken()) {
      print('⚠️ WebSocket: No token available, skipping connection.');
      return;
    }

    try {
      print('🌐 Connecting to WebSocket: $_url');
      
      // Use a more robust connection with headers if needed
      // and explicit ping interval to keep connection alive
      _channel = WebSocketChannel.connect(
        Uri.parse(_url),
        // protocols: ['json'], // Optional, some backends expect this
      );

      // Ping interval to keep connection alive (optional but recommended for stability)
      // IOWebSocketChannel supports pingInterval but standard WebSocketChannel might not directly.
      // However, we can use the stream listen normally.

      _channel!.stream.listen(
        (message) {
          isConnected.value = true;
          _handleMessage(message);
        },
        onDone: () {
          print('❌ WebSocket closed');
          isConnected.value = false;
          _scheduleReconnect();
        },
        onError: (error) {
          print('🛑 WebSocket error: $error');
          isConnected.value = false;
          _scheduleReconnect();
        },
        cancelOnError: true,
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
    if (isConnected.value && _channel != null) {
      final message = jsonEncode({'type': type, 'data': data});
      _channel!.sink.add(message);
    }
  }
}
