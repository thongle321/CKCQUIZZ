import 'package:flutter_test/flutter_test.dart';
import 'package:ckcandr/services/ai_service.dart';
import 'package:ckcandr/services/ai_database_service.dart';
import 'package:ckcandr/models/ai_chat_model.dart';

void main() {
  group('AI Service Tests', () {
    test('should validate API key format correctly', () {
      // Valid API key formats (39-40 characters total)
      expect(AiService.isValidApiKeyFormat('AIzaSyDummyKeyForDevelopmentTesting123'), true); // 39 chars
      expect(AiService.isValidApiKeyFormat('AIzaSyDummyKeyForDevelopmentTesting1234'), true); // 40 chars

      // Invalid API key formats
      expect(AiService.isValidApiKeyFormat('invalid_key'), false);
      expect(AiService.isValidApiKeyFormat(''), false);
      expect(AiService.isValidApiKeyFormat('AIza'), false);
      expect(AiService.isValidApiKeyFormat('BIzaSyDummyKeyForDevelopmentTesting123'), false);
      expect(AiService.isValidApiKeyFormat('AIzaSyDummyKeyForDevelopmentTesting12345'), false); // 41 chars
      expect(AiService.isValidApiKeyFormat('AIzaSyDummyKeyForDevelopmentTesting12'), false); // 38 chars
    });

    test('should return available models', () {
      final models = AiService.getAvailableModels();

      expect(models, isNotEmpty);
      expect(models, contains('gemini-2.5-flash'));
      expect(models, contains('gemini-2.5-pro'));
      expect(models, contains('gemini-2.0-flash'));
      expect(models, contains('gemini-1.5-pro'));
      expect(models, contains('gemini-1.5-flash'));
    });
  });

  group('AI Chat Model Tests', () {
    test('should create AiChatMessage correctly', () {
      final timestamp = DateTime.now();
      final message = AiChatMessage(
        id: 1,
        sessionId: 1,
        message: 'Hello AI',
        isUser: true,
        timestamp: timestamp,
        userId: 'user123',
      );

      expect(message.id, 1);
      expect(message.message, 'Hello AI');
      expect(message.isUser, true);
      expect(message.timestamp, timestamp);
      expect(message.userId, 'user123');
    });

    test('should create AiSettings with default values', () {
      const settings = AiSettings();

      expect(settings.apiKey, null);
      expect(settings.model, 'gemini-1.5-flash');
      expect(settings.temperature, 0.7);
      expect(settings.maxTokens, 8192);
      expect(settings.hasApiKey, false);
    });

    test('should create AiSettings with API key', () {
      const settings = AiSettings(
        apiKey: 'AIzaSyDummyKeyForDevelopment12345678',
        model: 'gemini-1.5-pro',
        temperature: 0.5,
        maxTokens: 4096,
      );

      expect(settings.apiKey, 'AIzaSyDummyKeyForDevelopment12345678');
      expect(settings.model, 'gemini-1.5-pro');
      expect(settings.temperature, 0.5);
      expect(settings.maxTokens, 4096);
      expect(settings.hasApiKey, true);
    });

    test('should copy AiSettings correctly', () {
      const originalSettings = AiSettings(
        apiKey: 'original_key',
        model: 'original_model',
      );

      final copiedSettings = originalSettings.copyWith(
        apiKey: 'new_key',
        temperature: 0.9,
      );

      expect(copiedSettings.apiKey, 'new_key');
      expect(copiedSettings.model, 'original_model'); // Should remain unchanged
      expect(copiedSettings.temperature, 0.9);
      expect(copiedSettings.maxTokens, 8192); // Should use default
    });

    test('should copy AiChatMessage correctly', () {
      final originalTimestamp = DateTime.now();
      final originalMessage = AiChatMessage(
        id: 1,
        sessionId: 1,
        message: 'Original message',
        isUser: true,
        timestamp: originalTimestamp,
        userId: 'user1',
      );

      final newTimestamp = DateTime.now().add(const Duration(minutes: 1));
      final copiedMessage = originalMessage.copyWith(
        message: 'New message',
        timestamp: newTimestamp,
      );

      expect(copiedMessage.id, 1); // Should remain unchanged
      expect(copiedMessage.message, 'New message');
      expect(copiedMessage.isUser, true); // Should remain unchanged
      expect(copiedMessage.timestamp, newTimestamp);
      expect(copiedMessage.userId, 'user1'); // Should remain unchanged
    });
  });

  group('AI Database Service Tests', () {
    late AiDatabaseService dbService;

    setUp(() {
      dbService = AiDatabaseService();
    });

    test('should be singleton', () {
      final instance1 = AiDatabaseService();
      final instance2 = AiDatabaseService();
      
      expect(identical(instance1, instance2), true);
    });

    // Note: Database tests would require more setup for actual database testing
    // These are basic structure tests
  });

  group('AI Models JSON Serialization Tests', () {
    test('should serialize and deserialize AiChatMessage', () {
      final timestamp = DateTime.parse('2024-01-01T12:00:00.000Z');
      final originalMessage = AiChatMessage(
        id: 1,
        sessionId: 1,
        message: 'Test message',
        isUser: true,
        timestamp: timestamp,
        userId: 'user123',
      );

      // Serialize to JSON
      final json = originalMessage.toJson();
      
      expect(json['id'], 1);
      expect(json['message'], 'Test message');
      expect(json['isUser'], true);
      expect(json['timestamp'], timestamp.toIso8601String());
      expect(json['userId'], 'user123');

      // Deserialize from JSON
      final deserializedMessage = AiChatMessage.fromJson(json);
      
      expect(deserializedMessage.id, originalMessage.id);
      expect(deserializedMessage.message, originalMessage.message);
      expect(deserializedMessage.isUser, originalMessage.isUser);
      expect(deserializedMessage.timestamp, originalMessage.timestamp);
      expect(deserializedMessage.userId, originalMessage.userId);
    });

    test('should serialize and deserialize AiSettings', () {
      const originalSettings = AiSettings(
        apiKey: 'test_api_key',
        model: 'gemini-1.5-pro',
        temperature: 0.8,
        maxTokens: 4096,
      );

      // Serialize to JSON
      final json = originalSettings.toJson();
      
      expect(json['apiKey'], 'test_api_key');
      expect(json['model'], 'gemini-1.5-pro');
      expect(json['temperature'], 0.8);
      expect(json['maxTokens'], 4096);

      // Deserialize from JSON
      final deserializedSettings = AiSettings.fromJson(json);
      
      expect(deserializedSettings.apiKey, originalSettings.apiKey);
      expect(deserializedSettings.model, originalSettings.model);
      expect(deserializedSettings.temperature, originalSettings.temperature);
      expect(deserializedSettings.maxTokens, originalSettings.maxTokens);
    });
  });
}
