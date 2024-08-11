// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Complaint _$ComplaintFromJson(Map<String, dynamic> json) => Complaint(
      complaintID: json['id'] as String?,
      complaintCreatedBy: json['created_by'] == null
          ? null
          : User.fromJson(json['created_by'] as Map<String, dynamic>),
      description: json['description'] as String?,
      suggestions: json['suggestions'] as String?,
      locationDetails: json['location_details'] as String?,
      complaintReportDate: json['report_date'] as String?,
      status: json['status'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationDescription: json['location_description'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => TagUri.fromJson(e as Map<String, dynamic>))
          .toList(),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
      usersUpVoted: (json['users_up_voted'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isSubscribed: json['is_subscribed'] as bool?,
      voteCount: (json['voteCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ComplaintToJson(Complaint instance) => <String, dynamic>{
      'id': instance.complaintID,
      'created_by': instance.complaintCreatedBy,
      'description': instance.description,
      'suggestions': instance.suggestions,
      'location_details': instance.locationDetails,
      'report_date': instance.complaintReportDate,
      'status': instance.status,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'location_description': instance.locationDescription,
      'tags': instance.tags,
      'comments': instance.comments,
      'users_up_voted': instance.usersUpVoted,
      'images': instance.images,
      'is_subscribed': instance.isSubscribed,
      'voteCount': instance.voteCount,
    };

TagUri _$TagUriFromJson(Map<String, dynamic> json) => TagUri(
      id: json['id'] as String?,
      tagUri: json['tag_uri'] as String?,
    );

Map<String, dynamic> _$TagUriToJson(TagUri instance) => <String, dynamic>{
      'id': instance.id,
      'tag_uri': instance.tagUri,
    };

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: json['id'] as String?,
      time: json['time'] as String?,
      text: json['text'] as String?,
      commentedBy: json['commented_by'] == null
          ? null
          : User.fromJson(json['commented_by'] as Map<String, dynamic>),
      complaintID: json['complaint'] as String?,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'time': instance.time,
      'text': instance.text,
      'commented_by': instance.commentedBy,
      'complaint': instance.complaintID,
    };
