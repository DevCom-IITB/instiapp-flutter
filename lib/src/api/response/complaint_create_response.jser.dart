// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint_create_response.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$ComplaintCreateResponseSerializer
    implements Serializer<ComplaintCreateResponse> {
  @override
  Map<String, dynamic> toMap(ComplaintCreateResponse model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'result', model.result);
    setMapValue(ret, 'complaintId', model.complaintId);
    return ret;
  }

  @override
  ComplaintCreateResponse fromMap(Map map) {
    if (map == null) return null;
    final obj = new ComplaintCreateResponse();
    obj.result = map['result'] as String;
    obj.complaintId = map['complaintId'] as String;
    return obj;
  }
}
