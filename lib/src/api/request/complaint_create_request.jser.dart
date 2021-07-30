// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint_create_request.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$ComplaintCreateRequestSerializer
    implements Serializer<ComplaintCreateRequest> {
  @override
  Map<String, dynamic> toMap(ComplaintCreateRequest model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'description', model.complaintDescription);
    setMapValue(ret, 'suggestions', model.complaintSuggestions);
    setMapValue(ret, 'location_details', model.complaintLocationDetails);
    setMapValue(ret, 'location_description', model.complaintLocation);
    setMapValue(ret, 'latitude', model.complaintLatitude);
    setMapValue(ret, 'longitude', model.complaintLongitude);
    setMapValue(ret, 'tags', codeIterable(model.tags, (val) => val as String));
    setMapValue(
        ret, 'images', codeIterable(model.images, (val) => val as String));
    return ret;
  }

  @override
  ComplaintCreateRequest fromMap(Map map) {
    if (map == null) return null;
    final obj = ComplaintCreateRequest();
    obj.complaintDescription = map['description'] as String;
    obj.complaintSuggestions = map['suggestions'] as String;
    obj.complaintLocationDetails = map['location_details'] as String;
    obj.complaintLocation = map['location_description'] as String;
    obj.complaintLatitude = map['latitude'] as double;
    obj.complaintLongitude = map['longitude'] as double;
    obj.tags =
        codeIterable<String>(map['tags'] as Iterable, (val) => val as String);
    obj.images =
        codeIterable<String>(map['images'] as Iterable, (val) => val as String);
    return obj;
  }
}
