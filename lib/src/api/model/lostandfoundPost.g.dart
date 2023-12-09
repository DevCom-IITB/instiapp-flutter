// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lostandfoundPost.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LostAndFoundPost _$LostAndFoundPostFromJson(Map<String, dynamic> json) =>
    LostAndFoundPost(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      imageUrl: (json['product_image'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      foundAt: json['found_at'] as String?,
      claimed: json['claimed'] as bool?,
      claimedBy: json['claimed_by'] == null
          ? null
          : User.fromJson(json['claimed_by'] as Map<String, dynamic>),
      contactDetails: json['contact_details'] as String?,
      timeOfCreation: json['time_of_creation'] as String?,
    )..category = json['category'] as String?;

Map<String, dynamic> _$LostAndFoundPostToJson(LostAndFoundPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'product_image': instance.imageUrl,
      'category': instance.category,
      'found_at': instance.foundAt,
      'claimed': instance.claimed,
      'contact_details': instance.contactDetails,
      'time_of_creation': instance.timeOfCreation,
      'claimed_by': instance.claimedBy,
    };
