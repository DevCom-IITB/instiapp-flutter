// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_bot_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatBotResponse _$ChatBotResponseFromJson(Map<String, dynamic> json) =>
    ChatBotResponse(
      data: (json['data'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ChatBotResponseToJson(ChatBotResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
