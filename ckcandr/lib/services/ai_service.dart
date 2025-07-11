import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ckcandr/models/ai_chat_model.dart';
import 'package:ckcandr/services/ai_database_service.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  final AiDatabaseService _dbService = AiDatabaseService();
  GenerativeModel? _model;
  ChatSession? _chatSession;

  // Initialize AI service with API key
  Future<bool> initialize() async {
    try {
      final settings = await _dbService.getSettings();
      if (!settings.hasApiKey) {
        debugPrint('❌ AI Service: No API key found');
        return false;
      }

      _model = GenerativeModel(
        model: settings.model,
        apiKey: settings.apiKey!,
        generationConfig: GenerationConfig(
          temperature: settings.temperature,
          maxOutputTokens: settings.maxTokens,
        ),
      );

      // Initialize chat session
      _chatSession = _model!.startChat();
      
      debugPrint('✅ AI Service initialized with model: ${settings.model}');
      return true;
    } catch (e) {
      debugPrint('❌ AI Service initialization failed: $e');
      return false;
    }
  }

  // Check if AI service is ready
  bool get isReady => _model != null && _chatSession != null;

  // Send message to AI and get response
  Future<String?> sendMessage(String message, {String? userId}) async {
    if (!isReady) {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('AI service not initialized. Please check your API key.');
      }
    }

    try {
      // Save user message to database (using default session)
      await _dbService.insertMessage(AiChatMessage(
        sessionId: 1, // Default session
        message: message,
        isUser: true,
        timestamp: DateTime.now(),
        userId: userId,
      ));

      // Send message to AI
      final response = await _chatSession!.sendMessage(Content.text(message));
      final aiResponse = response.text;

      if (aiResponse != null && aiResponse.isNotEmpty) {
        // Save AI response to database
        await _dbService.insertMessage(AiChatMessage(
          sessionId: 1, // Default session
          message: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
          userId: userId,
        ));

        return aiResponse;
      } else {
        throw Exception('Empty response from AI');
      }
    } catch (e) {
      debugPrint('❌ AI Service error: $e');
      
      // Save error message to database
      await _dbService.insertMessage(AiChatMessage(
        sessionId: 1, // Default session
        message: 'Xin lỗi, đã có lỗi xảy ra khi xử lý tin nhắn của bạn. Vui lòng thử lại.',
        isUser: false,
        timestamp: DateTime.now(),
        userId: userId,
      ));
      
      rethrow;
    }
  }

  // Send message to AI for specific session
  Future<String?> sendMessageToSession(int sessionId, String message, {String? userId}) async {
    if (!isReady) {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('AI service not initialized. Please check your API key.');
      }
    }

    try {
      // Save user message to database
      await _dbService.insertMessage(AiChatMessage(
        sessionId: sessionId,
        message: message,
        isUser: true,
        timestamp: DateTime.now(),
        userId: userId,
      ));

      // Send message to AI
      final response = await _chatSession!.sendMessage(Content.text(message));
      final aiResponse = response.text;

      if (aiResponse != null && aiResponse.isNotEmpty) {
        // Save AI response to database
        await _dbService.insertMessage(AiChatMessage(
          sessionId: sessionId,
          message: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
          userId: userId,
        ));

        return aiResponse;
      } else {
        throw Exception('Empty response from AI');
      }
    } catch (e) {
      debugPrint('❌ AI Service error: $e');

      // Save error message to database
      await _dbService.insertMessage(AiChatMessage(
        sessionId: sessionId,
        message: 'Xin lỗi, đã có lỗi xảy ra khi xử lý tin nhắn của bạn. Vui lòng thử lại.',
        isUser: false,
        timestamp: DateTime.now(),
        userId: userId,
      ));

      rethrow;
    }
  }

  // Send message to AI without saving to database (for context prompts)
  Future<String?> sendToAI(String message) async {
    if (!isReady) {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('AI service not initialized. Please check your API key.');
      }
    }

    try {
      // Send message to AI
      final response = await _chatSession!.sendMessage(Content.text(message));
      final aiResponse = response.text;

      if (aiResponse != null && aiResponse.isNotEmpty) {
        return aiResponse;
      } else {
        throw Exception('Empty response from AI');
      }
    } catch (e) {
      debugPrint('❌ AI Service error: $e');
      rethrow;
    }
  }

  // Get chat history
  Future<List<AiChatMessage>> getChatHistory({String? userId, int? limit}) async {
    return await _dbService.getMessages(userId: userId, limit: limit);
  }

  // Clear chat history
  Future<void> clearChatHistory({String? userId}) async {
    await _dbService.deleteAllMessages(userId: userId);
    
    // Reset chat session to clear context
    if (_model != null) {
      _chatSession = _model!.startChat();
    }
  }

  // Update API key
  Future<bool> updateApiKey(String apiKey) async {
    try {
      // Test the API key by creating a temporary model
      final testModel = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      // Try a simple test request
      final testResponse = await testModel.generateContent([
        Content.text('Hello')
      ]);

      if (testResponse.text != null) {
        // API key is valid, save it
        await _dbService.updateApiKey(apiKey);
        
        // Reinitialize the service
        await initialize();
        
        debugPrint('✅ API key updated successfully');
        return true;
      } else {
        debugPrint('❌ Invalid API key - no response');
        return false;
      }
    } catch (e) {
      debugPrint('❌ API key validation failed: $e');
      return false;
    }
  }

  // Get current settings
  Future<AiSettings> getSettings() async {
    return await _dbService.getSettings();
  }

  // Update settings
  Future<void> updateSettings(AiSettings settings) async {
    await _dbService.updateSettings(settings);
    
    // Reinitialize if API key is available
    if (settings.hasApiKey) {
      await initialize();
    }
  }

  // Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats({String? userId}) async {
    final messageCount = await _dbService.getMessageCount(userId: userId);
    final dbSize = await _dbService.getDatabaseSize();
    
    return {
      'messageCount': messageCount,
      'databaseSize': dbSize,
      'formattedSize': _formatBytes(dbSize),
    };
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _dbService.clearAllData();
    
    // Reset chat session
    _chatSession = null;
    _model = null;
  }

  // Format bytes to human readable format
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Validate API key format
  static bool isValidApiKeyFormat(String apiKey) {
    // Google AI API keys start with 'AIza' and are typically 39-40 characters long
    return apiKey.startsWith('AIza') && apiKey.length >= 39 && apiKey.length <= 40;
  }

  // Get available models
  static List<String> getAvailableModels() {
    return [
      'gemini-2.5-flash',
      'gemini-2.5-pro',
      'gemini-2.0-flash',
      'gemini-1.5-pro',
      'gemini-1.5-flash',
    ];
  }

  // Dispose resources
  void dispose() {
    _chatSession = null;
    _model = null;
  }
}
