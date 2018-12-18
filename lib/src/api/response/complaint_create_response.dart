import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'complaint_create_response.jser.dart';

class ComplaintCreateResponse {
  String result;
  String complaintId;
}

@GenSerializer()
class ComplaintCreateResponseSerializer extends Serializer<ComplaintCreateResponse> with _$ComplaintCreateResponseSerializer {}