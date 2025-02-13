import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:developer';

class SocketService {
  late IO.Socket socket;
  Function(dynamic)? onMessageReceived;

  void connect() {
    log('SocketService - Attempting to connect');
    socket = IO.io(Constants.apiBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.onConnect((_) {
      log('SocketService - Connected successfully');
    });

    socket.onConnectError((err) => log('SocketService - Connect error: $err'));
    socket.onDisconnect((_) => log('SocketService - Disconnected'));

    socket.on('message', (data) {
      log('SocketService - Received message: $data');
      if (onMessageReceived != null) {
        onMessageReceived!(data);
      }
    });

    socket.on('error', (error) {
      log('SocketService - Socket error: $error');
    });

    socket.connect();
  }

  void send(String event, dynamic data) {
    log('SocketService - Sending event: $event, data: $data');
    socket.emit(event, data);
  }

  void close() {
    log('SocketService - Closing socket connection');
    socket.disconnect();
  }
}