import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'login_response.jser.dart';

class LoginResponse {
  @Alias('sessionid')
  String sessionID;
  
  @Alias('user')
  String userID;
  
  @Alias('profile_id')
  String profileID;
}

@GenSerializer()
class LoginResponseSerializer extends Serializer<LoginResponse> with _$LoginResponseSerializer {}