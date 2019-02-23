import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'user_scn_patch_request.jser.dart';

class UserSCNPatchRequest {
  @Alias("show_contact_no")
  bool userShowContactNumber;
}

@GenSerializer()
class UserSCNPatchRequestSerializer extends Serializer<UserSCNPatchRequest>
    with _$UserSCNPatchRequestSerializer {}
