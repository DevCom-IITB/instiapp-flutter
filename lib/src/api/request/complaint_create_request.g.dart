// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComplaintCreateRequest _$ComplaintCreateRequestFromJson(
        Map<String, dynamic> json) =>
    ComplaintCreateRequest(
      complaintDescription: json['description'] as String?,
      complaintSuggestions: json['suggestions'] as String?,
      complaintLocationDetails: json['location_details'] as String?,
      complaintLocation: json['location_description'] as String?,
      complaintLatitude: (json['latitude'] as num?)?.toDouble(),
      complaintLongitude: (json['longitude'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ComplaintCreateRequestToJson(
        ComplaintCreateRequest instance) =>
    <String, dynamic>{
      'description': instance.complaintDescription,
      'suggestions': instance.complaintSuggestions,
      'location_details': instance.complaintLocationDetails,
      'location_description': instance.complaintLocation,
      'latitude': instance.complaintLatitude,
      'longitude': instance.complaintLongitude,
      'tags': instance.tags,
      'images': instance.images,
    };
