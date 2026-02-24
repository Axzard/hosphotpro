import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import '../../config/api_config.dart';
import '../../data/services/token_service.dart';

class WebSocketService extends GetxService {
  final TokenService _tokenService = Get.find<TokenService>();
  socket_io.Socket? _socket;
  final _instanceId = DateTime.now().millisecondsSinceEpoch % 10000;

  final _eventBus = GetStream<Map<String, dynamic>>();
  Stream<Map<String, dynamic>> get eventStream => _eventBus.stream;

  final isConnected = false.obs;

  final lastEvent = ''.obs;
  final lastData = Rxn<dynamic>();
  final eventTrigger = 0.obs;

  final routerStatus = <String, dynamic>{}.obs;
  final activeUserStats = Rxn<dynamic>();
  final latestLogs = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    connect();
  }

  @override
  void onClose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.onClose();
  }

  void connect() {
    if (!_tokenService.hasToken()) {
      print('[WS-$_instanceId] No token, skipping connection.');
      return;
    }

    if (_socket != null) {
      print('[WS-$_instanceId] Disconnecting existing socket...');
      _socket?.disconnect();
      _socket?.dispose();
    }

    final token = _tokenService.getToken();
    final url = ApiConfig.baseUrl;

    print('[WS-$_instanceId] Connecting to Socket.io: $url');

    try {
      _socket = socket_io.io(
        url,
        socket_io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .build(),
      );

      _socket!.onAny((event, data) {
        _onAnyHandler(event, data);
      });

      _socket!.onConnect((_) {
        print('[WS-$_instanceId] Connected: ${_socket!.id}');
        isConnected.value = true;
      });

      _socket!.onDisconnect((_) {
        print('[WS-$_instanceId] Disconnected');
        isConnected.value = false;
      });

      _socket!.onConnectError((err) {
        print('[WS-$_instanceId] Connect error: $err');
        isConnected.value = false;
      });

      _socket!.onError((err) {
        print('[WS-$_instanceId] General error: $err');
      });

      _socket!.on(
        'router_stats',
        (payload) => _onAnyHandler('router_stats', payload),
      );
      _socket!.on(
        'active_users',
        (payload) => _onAnyHandler('active_users', payload),
      );
      _socket!.on('logs', (payload) => _onAnyHandler('logs', payload));

      _socket!.connect();
    } catch (e) {
      print('[WS-$_instanceId] Initialization failed: $e');
      isConnected.value = false;
    }
  }

  void _onAnyHandler(dynamic event, dynamic data) {
    if (event == null) return;
    final eventName = event.toString();

    if (eventName == 'ping' || eventName == 'pong') return;

    print('[WS-$_instanceId] Event: $eventName');

    lastEvent.value = eventName;
    lastData.value = data;
    eventTrigger.value++;

    if (isBusinessEvent(eventName)) {
      _eventBus.add({'event': eventName, 'data': data});
    }

    if (eventName == 'router_stats') routerStatus.value = data;
    if (eventName == 'active_users') activeUserStats.value = data;
    if (eventName == 'logs' && data is List) {
      latestLogs.assignAll(data.map((e) => e.toString()).toList());
    }
  }

  void sendMessage(String event, dynamic data) {
    if (isConnected.value && _socket != null) {
      _socket!.emit(event, data);
    }
  }

  bool isBusinessEvent(String event) {
    if (event.isEmpty) return false;

    const technicalEvents = [
      'connect',
      'connect_error',
      'connect_timeout',
      'connecting',
      'disconnect',
      'error',
      'reconnect',
      'reconnect_attempt',
      'reconnect_failed',
      'reconnect_error',
      'reconnecting',
      'ping',
      'pong',
    ];

    return !technicalEvents.contains(event.toLowerCase());
  }
}
