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
      imageUrl: json['product_image'] as String?,
      brand: json['brand'] as String?,
      warranty: json['warranty'] as bool?,
      packaging: json['packaging'] as bool?,
      condition: json['condition'] as int?,
      action: json['action'] as String?,
      status: json['status'] as bool?,
      deleted: json['deleted'] as bool?,
      price: json['price'] as int?,
    )
      ..negotiable = json['negotiable'] as bool?
      ..contactDetails = json['contactDetails'] as int?
      ..timeOfCreation = json['time_of_creation'] as String?
      ..category = json['category'] as String?
      ..user = (json['user'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();

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
      'contactDetails': instance.contactDetails,
      'time_of_creation': instance.timeOfCreation,
      'category': instance.category,
      'user': instance.user,
    };
