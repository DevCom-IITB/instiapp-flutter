// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatbotlog_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatBotLogRequest _$ChatBotLogRequestFromJson(Map<String, dynamic> json) =>
    ChatBotLogRequest(
      json['question'] as String?,
      json['answer'] as String?,
      json['reaction'] as int?,
    );

Map<String, dynamic> _$ChatBotLogRequestToJson(ChatBotLogRequest instance) =>
    <String, dynamic>{
      'question': instance.question,
      'answer': instance.answer,
      'reaction': instance.reaction,
    };
