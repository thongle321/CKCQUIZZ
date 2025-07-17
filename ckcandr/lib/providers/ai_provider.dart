import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/ai_chat_model.dart';
import 'package:ckcandr/services/ai_service.dart';
import 'package:ckcandr/providers/user_provider.dart';

// AI Service Provider
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

// AI Settings Provider
final aiSettingsProvider = FutureProvider<AiSettings>((ref) async {
  final aiService = ref.read(aiServiceProvider);
  return await aiService.getSettings();
});

// AI Chat Messages Provider
final aiChatMessagesProvider = FutureProvider.family<List<AiChatMessage>, String?>((ref, userId) async {
  final aiService = ref.read(aiServiceProvider);
  return await aiService.getChatHistory(userId: userId, limit: 100);
});

// AI Chat Controller
class AiChatController extends StateNotifier<AsyncValue<List<AiChatMessage>>> {
  final AiService _aiService;
  final String? _userId;

  AiChatController(this._aiService, this._userId) : super(const AsyncValue.loading()) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _aiService.getChatHistory(userId: _userId, limit: 100);
      state = AsyncValue.data(messages);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    try {
      // Add user message immediately to UI
      final currentMessages = state.value ?? [];
      final userMessage = AiChatMessage(
        sessionId: 1, // Default session for legacy support
        message: message.trim(),
        isUser: true,
        timestamp: DateTime.now(),
        userId: _userId,
      );
      
      state = AsyncValue.data([...currentMessages, userMessage]);

      // Send to AI and get response
      await _aiService.sendMessage(message.trim(), userId: _userId);
      
      // Reload messages to get the AI response
      await _loadMessages();
    } catch (e, stackTrace) {
      // Reload messages to show any error messages that were saved
      await _loadMessages();
      rethrow;
    }
  }

  Future<void> clearHistory() async {
    try {
      await _aiService.clearChatHistory(userId: _userId);
      state = const AsyncValue.data([]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadMessages();
  }
}

// AI Chat Controller Provider
final aiChatControllerProvider = StateNotifierProvider.family<AiChatController, AsyncValue<List<AiChatMessage>>, String?>((ref, userId) {
  final aiService = ref.read(aiServiceProvider);
  return AiChatController(aiService, userId);
});

// AI Settings Controller
class AiSettingsController extends StateNotifier<AsyncValue<AiSettings>> {
  final AiService _aiService;

  AiSettingsController(this._aiService) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _aiService.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<bool> updateApiKey(String apiKey) async {
    try {
      final success = await _aiService.updateApiKey(apiKey);
      if (success) {
        await _loadSettings();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateSettings(AiSettings settings) async {
    try {
      await _aiService.updateSettings(settings);
      state = AsyncValue.data(settings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadSettings();
  }
}

// AI Settings Controller Provider
final aiSettingsControllerProvider = StateNotifierProvider<AiSettingsController, AsyncValue<AiSettings>>((ref) {
  final aiService = ref.read(aiServiceProvider);
  return AiSettingsController(aiService);
});

// AI Database Stats Provider
final aiDatabaseStatsProvider = FutureProvider.family<Map<String, dynamic>, String?>((ref, userId) async {
  final aiService = ref.read(aiServiceProvider);
  return await aiService.getDatabaseStats(userId: userId);
});

// AI Ready State Provider
final aiReadyStateProvider = FutureProvider<bool>((ref) async {
  final aiService = ref.read(aiServiceProvider);
  return await aiService.initialize();
});

// Current User AI Chat Provider (convenience provider)
final currentUserAiChatProvider = Provider<StateNotifierProvider<AiChatController, AsyncValue<List<AiChatMessage>>>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final userId = currentUser?.id;
  return aiChatControllerProvider(userId);
});

// Current User AI Database Stats Provider
final currentUserAiStatsProvider = Provider<FutureProvider<Map<String, dynamic>>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final userId = currentUser?.id;
  return aiDatabaseStatsProvider(userId);
});
