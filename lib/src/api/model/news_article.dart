import 'package:InstiApp/src/api/model/body.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'news_article.jser.dart';

class NewsArticle {
  @Alias("id")
  String articleID;

  @Alias("link")
  String link;

  @Alias("title")
  String title;

  @Alias("content")
  String content;

  @Alias("published")
  String published;

  @Alias("body")
  Body body;
}

@GenSerializer()
class NewsArticleSerializer extends Serializer<NewsArticle> with _$NewsArticleSerializer {}