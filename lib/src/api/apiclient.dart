import 'package:instiapp/src/api/model/mess.dart';
import 'package:jaguar_resty/jaguar_resty.dart';
import 'package:jaguar_resty/jaguar_resty.dart' as resty;
import 'package:jaguar_retrofit/jaguar_retrofit.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:instiapp/src/api/model/serializers.dart';

part 'apiclient.jretro.dart';

@GenApiClient()
class InstiAppApi extends _$InstiAppApiClient implements ApiClient {
  final resty.Route base = Route("https://api.insti.app/api");
  final SerializerRepo serializers = standardSerializers;

  InstiAppApi();

  @GetReq(path: "/mess")
  Future<List<Hostel>> getHostelMess();
}