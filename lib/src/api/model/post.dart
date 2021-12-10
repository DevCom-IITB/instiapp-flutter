import 'package:InstiApp/src/api/model/body.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "guid")
  String? guid;

  @JsonKey(name: "link")
  String? link;

  @JsonKey(name: "title")
  String? title;

  @JsonKey(name: "content")
  String? content;

  @JsonKey(name: "published")
  String? published;

  Post({this.id, this.guid, this.link, this.title, this.content, this.published});

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable()
class PlacementBlogPost extends Post {

  PlacementBlogPost(String? id,
    String? guid,
    String? link,
    String? title,
    String? content,
    String? published):super(id: id, guid: guid, link: link, title: title, content: content, published: published);

  factory PlacementBlogPost.fromJson(Map<String, dynamic> json) =>
      _$PlacementBlogPostFromJson(json);

  Map<String, dynamic> toJson() => _$PlacementBlogPostToJson(this);
}

@JsonSerializable()
class ExternalBlogPost extends Post {
  @JsonKey(name: "body")
  String? body;

  ExternalBlogPost(String? id,
  String? guid,
  String? link,
  String? title,
  String? content,
  String? published, {this.body}):super(id: id, guid: guid, link: link, title: title, content: content, published: published);
  factory ExternalBlogPost.fromJson(Map<String, dynamic> json) =>
      _$ExternalBlogPostFromJson(json);
  Map<String, dynamic> toJson() => _$ExternalBlogPostToJson(this);
}

@JsonSerializable()
class TrainingBlogPost extends Post {

  TrainingBlogPost(String? id,
  String? guid,
  String? link,
  String? title,
  String? content,
  String? published):super(id: id, guid: guid, link: link, title: title, content: content, published: published);
  factory TrainingBlogPost.fromJson(Map<String, dynamic> json) =>
      _$TrainingBlogPostFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingBlogPostToJson(this);
}

@JsonSerializable()
class NewsArticle extends Post {
  @JsonKey(name: "body")
  Body? body;

  @JsonKey(name: "reactions_count")
  Map<String, int> reactionCount;

  @JsonKey(name: "user_reaction")
  int? userReaction;

  NewsArticle(String? id,
  String? guid,
  String? link,
  String? title,
  String? content,
  String? published, {this.body, this.reactionCount = const {}, this.userReaction}):super(id: id, guid: guid, link: link, title: title, content: content, published: published);

  factory NewsArticle.fromJson(Map<String, dynamic> json) =>
      _$NewsArticleFromJson(json);
  
  Map<String, dynamic> toJson() => _$NewsArticleToJson(this);

}

@JsonSerializable()
class Query extends Post {
  @JsonKey(name: "question")
  String? title;

  @JsonKey(name: "answer")
  String? content;

  @JsonKey(name: "category")
  String? published;

  @JsonKey(name: "sub_category")
  String? subCategory;

  @JsonKey(name: "sub_sub_category")
  String? subSubCategory;

  @JsonKey(ignore: true)
  String? guid;

  @JsonKey(ignore: true)
  String? link;

  Query({
    this.content,
    this.guid,
    this.link,
    this.published,
    this.subCategory,
    this.subSubCategory,
    this.title
  });

  factory Query.fromJson(Map<String, dynamic> json) =>
      _$QueryFromJson(json);
  
  Map<String, dynamic> toJson() => _$QueryToJson(this);
}
