import 'package:InstiApp/src/api/model/body.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'post.g.dart';

class Post {
  @JsonKey("id")
  String id;

  @JsonKey("guid")
  String guid;

  @JsonKey("link")
  String link;

  @JsonKey("title")
  String title;

  @JsonKey("content")
  String content;

  @JsonKey("published")
  String published;

  Post({this.id, this.guid, this.link, this.title, this.content, this.published});

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);
}

class PlacementBlogPost extends Post {
  

  PlacementBlogPost();

  factory PlacementBlogPost.fromJson(Map<String, dynamic> json) =>
      _$PlacementBlogPostFromJson(json);

  Map<String, dynamic> toJson() => _$PlacementBlogPostToJson(this);
}

class ExternalBlogPost extends Post {
  @JsonKey("body")
  String body;

  ExternalBlogPost({this.body});
  factory ExternalBlogPost.fromJson(Map<String, dynamic> json) =>
      _$ExternalBlogPostFromJson(json);
  Map<String, dynamic> toJson() => _$ExternalBlogPostToJson(this);
}

class TrainingBlogPost extends Post {

  TrainingBlogPost();
  factory TrainingBlogPost.fromJson(Map<String, dynamic> json) =>
      _$TrainingBlogPostFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingBlogPostToJson(this);
}

class NewsArticle extends Post {
  @JsonKey("body")
  Body body;

  @JsonKey("reactions_count")
  Map<String, int> reactionCount;

  @JsonKey("user_reaction")
  int userReaction;

  NewsArticle({this.body, this.reactionCount, this.userReaction});

  factory NewsArticle.fromJson(Map<String, dynamic> json) =>
      _$NewsArticleFromJson(json);
  
  Map<String, dynamic> toJson() => _$NewsArticleToJson(this);

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
