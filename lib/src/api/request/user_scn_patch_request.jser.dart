// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_scn_patch_request.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$UserSCNPatchRequestSerializer
    implements Serializer<UserSCNPatchRequest> {
  @override
  Map<String, dynamic> toMap(UserSCNPatchRequest model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'show_contact_no', model.userShowContactNumber);
    return ret;
  }

  @override
  UserSCNPatchRequest fromMap(Map map) {
    if (map == null) return null;
    final obj = new UserSCNPatchRequest();
    obj.userShowContactNumber = map['show_contact_no'] as bool;
    return obj;
  }
}
