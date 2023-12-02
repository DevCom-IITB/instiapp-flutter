// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buynsellPost.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuynSellPost _$BuynSellPostFromJson(Map<String, dynamic> json) => BuynSellPost(
      id: json['id'] as String?,
      buysellPostStrId: json['str_id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      imageUrl: (json['product_image'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      brand: json['brand'] as String?,
      warranty: json['warranty'] as bool?,
      packaging: json['packaging'] as bool?,
      condition: json['condition'] as String?,
      action: json['action'] as String?,
      status: json['status'] as bool?,
      deleted: json['deleted'] as bool?,
      price: json['price'] as int?,
      timeOfCreation: json['time_of_creation'] as String?,
    )
      ..negotiable = json['negotiable'] as bool?
      ..contactDetails = json['contact_details'] as String?
      ..category = json['category'] as String?
      ..user = json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>);

Map<String, dynamic> _$BuynSellPostToJson(BuynSellPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'str_id': instance.buysellPostStrId,
      'name': instance.name,
      'description': instance.description,
      'product_image': instance.imageUrl,
      'brand': instance.brand,
      'warranty': instance.warranty,
      'packaging': instance.packaging,
      'condition': instance.condition,
      'action': instance.action,
      'status': instance.status,
      'deleted': instance.deleted,
      'price': instance.price,
      'negotiable': instance.negotiable,
      'contact_details': instance.contactDetails,
      'time_of_creation': instance.timeOfCreation,
      'category': instance.category,
      'user': instance.user,
    };
