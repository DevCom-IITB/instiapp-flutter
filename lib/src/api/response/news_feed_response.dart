import 'package:InstiApp/src/api/model/event.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'news_feed_response.jser.dart';

class NewsFeedResponse {
  @Alias("data")
  List<Event> events;
  @Alias("count")
  int count;
}

@GenSerializer()
class NewsFeedResponseSerializer extends Serializer<NewsFeedResponse>
    with _$NewsFeedResponseSerializer {}
