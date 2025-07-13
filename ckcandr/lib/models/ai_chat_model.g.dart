// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatSession _$AiChatSessionFromJson(Map<String, dynamic> json) =>
    AiChatSession(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      summary: json['summary'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as String?,
      model: json['model'] as String? ?? 'gemini-2.5-flash',
    );

Map<String, dynamic> _$AiChatSessionToJson(AiChatSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'summary': instance.summary,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'userId': instance.userId,
      'model': instance.model,
    };

AiChatMessage _$AiChatMessageFromJson(Map<String, dynamic> json) =>
    AiChatMessage(
      id: (json['id'] as num?)?.toInt(),
      sessionId: (json['sessionId'] as num).toInt(),
      message: json['message'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$AiChatMessageToJson(AiChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'message': instance.message,
      'isUser': instance.isUser,
      'timestamp': instance.timestamp.toIso8601String(),
      'userId': instance.userId,
    };

AiSettings _$AiSettingsFromJson(Map<String, dynamic> json) => AiSettings(
      apiKey: json['apiKey'] as String?,
      model: json['model'] as String? ?? 'gemini-1.5-flash',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 8192,
    );

Map<String, dynamic> _$AiSettingsToJson(AiSettings instance) =>
    <String, dynamic>{
      'apiKey': instance.apiKey,
      'model': instance.model,
      'temperature': instance.temperature,
      'maxTokens': instance.maxTokens,
    };
