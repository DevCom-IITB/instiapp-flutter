// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'postFAQ_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostFAQRequest _$PostFAQRequestFromJson(Map<String, dynamic> json) =>
    PostFAQRequest(
      category: json['category'] as String?,
      question: json['question'] as String?,
    );

Map<String, dynamic> _$PostFAQRequestToJson(PostFAQRequest instance) =>
    <String, dynamic>{
      'question': instance.question,
      'category': instance.category,
    };
