// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint_create_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComplaintCreateResponse _$ComplaintCreateResponseFromJson(
        Map<String, dynamic> json) =>
    ComplaintCreateResponse(
      result: json['result'] as String?,
      complaintId: json['complaintId'] as String?,
    );

Map<String, dynamic> _$ComplaintCreateResponseToJson(
        ComplaintCreateResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'complaintId': instance.complaintId,
    };
