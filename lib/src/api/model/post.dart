import 'package:InstiApp/src/api/model/body.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'post.jser.dart';

class Post {
  @Alias("id")
  String id;

  @Alias("guid")
  String guid;

  @Alias("link")
  String link;

  @Alias("title")
  String title;

  @Alias("content")
  String content;

  @Alias("published")
  String published;
}

class PlacementBlogPost extends Post {}

class ExternalBlogPost extends Post {
  @Alias("body")
  String body;
}

class TrainingBlogPost extends Post {}

class NewsArticle extends Post {
  @Alias("body")
  Body body;

  @Alias("reactions_count")
  Map<String, int> reactionCount;

  @Alias("user_reaction")
  int userReaction;
}

class Query extends Post {
  @Alias("question")
  String title;

  @Alias("answer")
  String content;

  @Alias("category")
  String published;

  @Alias("sub_category")
  String subCategory;

  @Alias("sub_sub_category")
  String subSubCategory;

  @Ignore()
  String guid;

  @Ignore()
  String link;
}

@GenSerializer()
class PostSerializer extends Serializer<Post> with _$PostSerializer {}

@GenSerializer()
class PlacementBlogPostSerializer extends Serializer<PlacementBlogPost>
    with _$PlacementBlogPostSerializer {}

@GenSerializer()
class ExternalBlogPostSerializer extends Serializer<ExternalBlogPost>
    with _$ExternalBlogPostSerializer {}

@GenSerializer()
class TrainingBlogPostSerializer extends Serializer<TrainingBlogPost>
    with _$TrainingBlogPostSerializer {}

@GenSerializer()
class NewsArticleSerializer extends Serializer<NewsArticle>
    with _$NewsArticleSerializer {}

@GenSerializer()
class QuerySerializer extends Serializer<Query> with _$QuerySerializer {}
