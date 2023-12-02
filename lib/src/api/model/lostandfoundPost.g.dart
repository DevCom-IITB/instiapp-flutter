// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lostandfoundPost.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LostAndFoundPost _$LostAndFoundPostFromJson(Map<String, dynamic> json) =>
    LostAndFoundPost(
      id: json['id'] as String?,
      lostAndFoundPostStrId: json['str_id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      imageUrl: (json['product_image'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      foundAt: json['brand'] as String?,
      whenFound: json['condition'] as String?,
      action: json['action'] as String?,
      status: json['status'] as bool?,
      deleted: json['deleted'] as bool?,
      ifClaimed: json['price'] as bool?,
      timeOfCreation: json['time_of_creation'] as String?,
    )
      ..contactDetails = json['contact_details'] as String?
      ..category = json['category'] as String?
      ..user = json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>);

Map<String, dynamic> _$LostAndFoundPostToJson(LostAndFoundPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'str_id': instance.lostAndFoundPostStrId,
      'name': instance.name,
      'description': instance.description,
      'product_image': instance.imageUrl,
      'brand': instance.foundAt,
      'condition': instance.whenFound,
      'action': instance.action,
      'status': instance.status,
      'deleted': instance.deleted,
      'price': instance.ifClaimed,
      'contact_details': instance.contactDetails,
      'time_of_creation': instance.timeOfCreation,
      'category': instance.category,
      'user': instance.user,
    };
