// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_bot_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatBotRequest _$ChatBotRequestFromJson(Map<String, dynamic> json) =>
    ChatBotRequest(
      question: json['data'] as String?,
    );

Map<String, dynamic> _$ChatBotRequestToJson(ChatBotRequest instance) =>
    <String, dynamic>{
      'data': instance.question,
    };
