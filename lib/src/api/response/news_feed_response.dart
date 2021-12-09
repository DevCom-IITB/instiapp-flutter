import 'package:InstiApp/src/api/model/event.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'news_feed_response.g.dart';

class NewsFeedResponse {
  @JsonKey("data")
  List<Event> events;
  @JsonKey("count")
  int count;

  NewsFeedResponse(this.events, this.count);
  
  factory NewsFeedResponse.fromJson(Map<String, dynamic> json) =>
      _$NewsFeedResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NewsFeedResponseToJson(this);
}

@GenSerializer()
class NewsFeedResponseSerializer extends Serializer<NewsFeedResponse>
    with _$NewsFeedResponseSerializer {}
