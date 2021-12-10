import 'package:InstiApp/src/api/model/event.dart';
import 'package:json_annotation/json_annotation.dart';


part 'news_feed_response.g.dart';

@JsonSerializable()
class NewsFeedResponse {
  @JsonKey(name: "data")
  List<Event>? events;
  @JsonKey(name: "count")
  int? count;

  NewsFeedResponse(this.events, this.count);
  
  factory NewsFeedResponse.fromJson(Map<String, dynamic> json) =>
      _$NewsFeedResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NewsFeedResponseToJson(this);
}
