import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/ai_chat_model.dart';
import 'package:ckcandr/services/ai_database_service.dart';
import 'package:ckcandr/services/ai_service.dart';
import 'package:ckcandr/providers/user_provider.dart';

// AI Chat Sessions Controller
class AiChatSessionsController extends StateNotifier<AsyncValue<List<AiChatSession>>> {
  final AiDatabaseService _dbService;
  final String? _userId;

  AiChatSessionsController(this._dbService, this._userId) : super(const AsyncValue.loading()) {
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = await _dbService.getSessions(userId: _userId);
      state = AsyncValue.data(sessions);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<AiChatSession> createNewSession({String? title, String? model}) async {
    final now = DateTime.now();
    final session = AiChatSession(
      title: title ?? 'Chat mới ${now.day}/${now.month}',
      createdAt: now,
      updatedAt: now,
      userId: _userId,
      model: model ?? 'gemini-2.5-flash',
    );

    final sessionId = await _dbService.insertSession(session);
    final newSession = session.copyWith(id: sessionId);
    
    await _loadSessions();
    return newSession;
  }

  Future<void> updateSession(AiChatSession session) async {
    await _dbService.updateSession(session);
    await _loadSessions();
  }

  Future<void> deleteSession(int sessionId) async {
    await _dbService.deleteSession(sessionId);
    await _loadSessions();
  }

  Future<void> refresh() async {
    await _loadSessions();
  }
}

// AI Chat Messages Controller for specific session
class AiChatMessagesController extends StateNotifier<AsyncValue<List<AiChatMessage>>> {
  final AiService _aiService;
  final AiDatabaseService _dbService;
  final int _sessionId;
  final String? _userId;

  AiChatMessagesController(this._aiService, this._dbService, this._sessionId, this._userId) 
      : super(const AsyncValue.loading()) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _dbService.getMessages(sessionId: _sessionId, userId: _userId);
      state = AsyncValue.data(messages);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> sendMessage(String message, {String? contextPrompt}) async {
    if (message.trim().isEmpty) return;

    try {
      // Save user message to database first
      final userMessage = AiChatMessage(
        sessionId: _sessionId,
        message: message.trim(),
        isUser: true,
        timestamp: DateTime.now(),
        userId: _userId,
      );
      await _dbService.insertMessage(userMessage);

      // Add user message immediately to UI
      final currentMessages = state.value ?? [];
      state = AsyncValue.data([...currentMessages, userMessage]);

      // Prepare full prompt with context for AI
      String fullPrompt = message.trim();
      if (contextPrompt != null && contextPrompt.isNotEmpty) {
        fullPrompt = '$contextPrompt\n\nUser: $message';
      }

      // Send full prompt to AI but don't save it to database
      // We'll manually handle the AI response
      final response = await _aiService.sendToAI(fullPrompt);

      if (response != null && response.isNotEmpty) {
        // Save AI response to database
        final aiMessage = AiChatMessage(
          sessionId: _sessionId,
          message: response,
          isUser: false,
          timestamp: DateTime.now(),
          userId: _userId,
        );
        await _dbService.insertMessage(aiMessage);
      }

      // Reload messages to get the updated list
      await _loadMessages();
    } catch (e) {
      // Reload messages to show any error messages that were saved
      await _loadMessages();
      rethrow;
    }
  }

  Future<void> clearHistory() async {
    try {
      await _dbService.deleteAllMessages(sessionId: _sessionId, userId: _userId);
      state = const AsyncValue.data([]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadMessages();
  }
}

// Current selected session provider
final currentChatSessionProvider = StateProvider<AiChatSession?>((ref) => null);

// Chat sessions provider
final aiChatSessionsProvider = StateNotifierProvider.family<AiChatSessionsController, AsyncValue<List<AiChatSession>>, String?>((ref, userId) {
  final dbService = AiDatabaseService();
  return AiChatSessionsController(dbService, userId);
});

// Chat messages provider for specific session
final aiChatMessagesProvider = StateNotifierProvider.family<AiChatMessagesController, AsyncValue<List<AiChatMessage>>, int>((ref, sessionId) {
  final aiService = AiService();
  final dbService = AiDatabaseService();
  final currentUser = ref.read(currentUserProvider);
  return AiChatMessagesController(aiService, dbService, sessionId, currentUser?.id);
});

// Chat summarization provider
final chatSummaryProvider = FutureProvider.family<String?, int>((ref, sessionId) async {
  final dbService = AiDatabaseService();
  final messages = await dbService.getMessages(sessionId: sessionId, limit: 20);
  
  if (messages.length < 5) return null;
  
  // Simple summarization logic - in real app, you'd use AI for this
  final topics = <String>[];
  for (final message in messages) {
    if (message.isUser && message.message.length > 10) {
      // Extract key topics from user messages
      final words = message.message.toLowerCase().split(' ');
      for (final word in words) {
        if (word.length > 4 && !topics.contains(word)) {
          topics.add(word);
        }
      }
    }
  }
  
  return topics.take(5).join(', ');
});
