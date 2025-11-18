import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../models/chat_message.dart';
import 'api_service.dart';
import 'package:repartir_frontend/network/api_config.dart';

class ChatService {
  final ApiService _api = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  StompClient? _stompClient;
  bool _isConnected = false;

  // Stream controller pour les messages reçus
  final Map<int, StreamController<ChatMessage>> _messageControllers = {};
  
  // Stream controller pour les notifications de suppression
  final Map<int, StreamController<Map<String, dynamic>>> _deletionControllers = {};

  bool get isConnected => _isConnected;

  /// Connexion WebSocket avec authentification JWT
  Future<void> connect() async {
    if (_isConnected && _stompClient != null) {
      print('💬 Déjà connecté au WebSocket');
      return;
    }

    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        throw Exception('Token JWT manquant');
      }
      
      print('💬 Token récupéré: ${token.substring(0, 20)}...');

      print('💬 Connexion WebSocket en cours...');
      
      // Build WS endpoint from base origin (handles Android emulator / iOS / web)
      final origin = ApiConfig.baseOrigin;
      final wsOrigin = origin.startsWith('https')
          ? origin.replaceFirst('https', 'wss')
          : origin.replaceFirst('http', 'ws');
      final wsUrl = '$wsOrigin/ws';
      print('💬 WS URL: $wsUrl');

      _stompClient = StompClient(
        config: StompConfig(
          url: wsUrl,
          onConnect: _onConnectCallback,
          onDisconnect: _onDisconnectCallback,
          onStompError: _onStompError,
          onWebSocketError: _onWebSocketError,
          onWebSocketDone: _onWebSocketDone,
          stompConnectHeaders: {
            'Authorization': 'Bearer $token',
          },
          webSocketConnectHeaders: {
            'Authorization': 'Bearer $token',
          },
          heartbeatIncoming: const Duration(seconds: 10),
          heartbeatOutgoing: const Duration(seconds: 10),
        ),
      );

      _stompClient!.activate();
    } catch (e) {
      debugPrint('❌ Erreur lors de la connexion WebSocket: $e');
      rethrow;
    }
  }

  void _onConnectCallback(StompFrame frame) {
    _isConnected = true;
    debugPrint('✅ Connecté au WebSocket');
  }

  void _onDisconnectCallback(StompFrame frame) {
    _isConnected = false;
    debugPrint('🔌 Déconnecté du WebSocket');
  }

  void _onStompError(StompFrame frame) {
    debugPrint('❌ Erreur STOMP: ${frame.body}');
  }

  void _onWebSocketError(dynamic error) {
    debugPrint('❌ Erreur WebSocket: $error');
  }

  void _onWebSocketDone() {
    _isConnected = false;
    debugPrint('🔌 WebSocket fermé');
  }

  /// S'abonner aux messages d'un mentoring
  Stream<ChatMessage> subscribeToMentoring(int mentoringId) {
    if (_messageControllers.containsKey(mentoringId)) {
      return _messageControllers[mentoringId]!.stream;
    }

    final controller = StreamController<ChatMessage>.broadcast();
    _messageControllers[mentoringId] = controller;

    if (_stompClient != null && _isConnected) {
      _subscribeToTopic(mentoringId);
    } else {
      // Attendre la connexion
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_stompClient != null && _isConnected) {
          _subscribeToTopic(mentoringId);
        }
      });
    }

    return controller.stream;
  }

  void _subscribeToTopic(int mentoringId) {
    debugPrint('📡 Abonnement au topic /topic/chat/$mentoringId');
    
    _stompClient!.subscribe(
      destination: '/topic/chat/$mentoringId',
      callback: (frame) {
        try {
          if (frame.body != null) {
            final data = jsonDecode(frame.body!);
            
            // Vérifier si c'est une notification de suppression
            if (data['type'] == 'message_deleted') {
              debugPrint('🗑️ Message ${data['messageId']} supprimé');
              if (_deletionControllers.containsKey(mentoringId)) {
                _deletionControllers[mentoringId]!.add(data);
              }
            } else {
              // C'est un message normal
              final message = ChatMessage.fromJson(data);
              debugPrint('📩 Message reçu: ${message.content}');
              if (_messageControllers.containsKey(mentoringId)) {
                _messageControllers[mentoringId]!.add(message);
              }
            }
          }
        } catch (e) {
          debugPrint('❌ Erreur de parsing du message: $e');
        }
      },
    );
  }

  /// S'abonner aux notifications de suppression
  Stream<Map<String, dynamic>> subscribeToDeletions(int mentoringId) {
    if (_deletionControllers.containsKey(mentoringId)) {
      return _deletionControllers[mentoringId]!.stream;
    }

    final controller = StreamController<Map<String, dynamic>>.broadcast();
    _deletionControllers[mentoringId] = controller;
    return controller.stream;
  }

  /// Envoyer un message
  Future<void> sendMessage(int mentoringId, String content) async {
    if (_stompClient == null || !_isConnected) {
      throw Exception('WebSocket non connecté');
    }

    debugPrint('📤 Envoi du message: $content');

    _stompClient!.send(
      destination: '/app/chat/$mentoringId',
      body: jsonEncode({
        'content': content,
      }),
    );
  }

  /// Supprimer un message (via REST API)
  Future<void> deleteMessage(int messageId) async {
    try {
      debugPrint('🗑️ Suppression du message $messageId...');
      
      final response = await _api.delete('/messages/$messageId');
      
      if (response.statusCode == 200) {
        debugPrint('✅ Message $messageId supprimé');
      } else {
        throw Exception('Échec de la suppression: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Erreur suppression message: $e');
      rethrow;
    }
  }

  /// Récupérer l'historique des messages (REST API)
  Future<List<ChatMessage>> getMessageHistory(int mentoringId) async {
    try {
      debugPrint('📜 Récupération historique chat pour mentoring $mentoringId');
      
      final response = await _api.get('/mentorings/$mentoringId/messages');
      final data = _api.decodeJson<List<dynamic>>(response, (d) => d as List<dynamic>);
      
      final messages = data
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
      
      debugPrint('✅ ${messages.length} messages récupérés');
      return messages;
    } catch (e) {
      debugPrint('❌ Erreur récupération historique: $e');
      return [];
    }
  }

  /// Déconnexion WebSocket
  void disconnect() {
    _stompClient?.deactivate();
    _isConnected = false;
    
    // Fermer tous les streams
    for (var controller in _messageControllers.values) {
      controller.close();
    }
    for (var controller in _deletionControllers.values) {
      controller.close();
    }
    
    _messageControllers.clear();
    _deletionControllers.clear();
    
    debugPrint('🔌 WebSocket déconnecté');
  }

  void dispose() {
    disconnect();
  }
}

