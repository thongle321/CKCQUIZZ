import 'package:json_annotation/json_annotation.dart';

part 'ai_chat_model.g.dart';

@JsonSerializable()
class AiChatSession {
  final int? id;
  final String title;
  final String? summary;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userId;
  final String model;

  const AiChatSession({
    this.id,
    required this.title,
    this.summary,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.model = 'gemini-2.5-flash',
  });

  factory AiChatSession.fromJson(Map<String, dynamic> json) =>
      _$AiChatSessionFromJson(json);

  Map<String, dynamic> toJson() => _$AiChatSessionToJson(this);

  AiChatSession copyWith({
    int? id,
    String? title,
    String? summary,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    String? model,
  }) {
    return AiChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      model: model ?? this.model,
    );
  }
}

@JsonSerializable()
class AiChatMessage {
  final int? id;
  final int sessionId;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String? userId;

  const AiChatMessage({
    this.id,
    required this.sessionId,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.userId,
  });

  factory AiChatMessage.fromJson(Map<String, dynamic> json) =>
      _$AiChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$AiChatMessageToJson(this);

  AiChatMessage copyWith({
    int? id,
    int? sessionId,
    String? message,
    bool? isUser,
    DateTime? timestamp,
    String? userId,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      message: message ?? this.message,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'AiChatMessage(id: $id, sessionId: $sessionId, message: $message, isUser: $isUser, timestamp: $timestamp, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiChatMessage &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.message == message &&
        other.isUser == isUser &&
        other.timestamp == timestamp &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        sessionId.hashCode ^
        message.hashCode ^
        isUser.hashCode ^
        timestamp.hashCode ^
        userId.hashCode;
  }
}

@JsonSerializable()
class AiSettings {
  final String? apiKey;
  final String model;
  final double temperature;
  final int maxTokens;

  const AiSettings({
    this.apiKey,
    this.model = 'gemini-2.5-flash',
    this.temperature = 0.7,
    this.maxTokens = 8192,
  });

  factory AiSettings.fromJson(Map<String, dynamic> json) =>
      _$AiSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AiSettingsToJson(this);

  AiSettings copyWith({
    String? apiKey,
    String? model,
    double? temperature,
    int? maxTokens,
  }) {
    return AiSettings(
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
    );
  }

  bool get hasApiKey => apiKey != null && apiKey!.isNotEmpty;

  @override
  String toString() {
    return 'AiSettings(apiKey: ${apiKey?.substring(0, 10)}..., model: $model, temperature: $temperature, maxTokens: $maxTokens)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiSettings &&
        other.apiKey == apiKey &&
        other.model == model &&
        other.temperature == temperature &&
        other.maxTokens == maxTokens;
  }

  @override
  int get hashCode {
    return apiKey.hashCode ^
        model.hashCode ^
        temperature.hashCode ^
        maxTokens.hashCode;
  }
}
