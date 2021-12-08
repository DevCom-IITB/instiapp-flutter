// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$PostSerializer implements Serializer<Post> {
  @override
  Map<String, dynamic> toMap(Post model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'guid', model.guid);
    setMapValue(ret, 'link', model.link);
    setMapValue(ret, 'title', model.title);
    setMapValue(ret, 'content', model.content);
    setMapValue(ret, 'published', model.published);
    return ret;
  }

  @override
  Post fromMap(Map map) {
    if (map == null) return null;
    final obj = Post();
    obj.id = map['id'] as String;
    obj.guid = map['guid'] as String;
    obj.link = map['link'] as String;
    obj.title = map['title'] as String;
    obj.content = map['content'] as String;
    obj.published = map['published'] as String;
    return obj;
  }
}

abstract class _$PlacementBlogPostSerializer
    implements Serializer<PlacementBlogPost> {
  @override
  Map<String, dynamic> toMap(PlacementBlogPost model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'guid', model.guid);
    setMapValue(ret, 'link', model.link);
    setMapValue(ret, 'title', model.title);
    setMapValue(ret, 'content', model.content);
    setMapValue(ret, 'published', model.published);
    return ret;
  }

  @override
  PlacementBlogPost fromMap(Map map) {
    if (map == null) return null;
    final obj = PlacementBlogPost();
    obj.id = map['id'] as String;
    obj.guid = map['guid'] as String;
    obj.link = map['link'] as String;
    obj.title = map['title'] as String;
    obj.content = map['content'] as String;
    obj.published = map['published'] as String;
    return obj;
  }
}

abstract class _$ExternalBlogPostSerializer
    implements Serializer<ExternalBlogPost> {
  @override
  Map<String, dynamic> toMap(ExternalBlogPost model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'body', model.body);
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'guid', model.guid);
    setMapValue(ret, 'link', model.link);
    setMapValue(ret, 'title', model.title);
    setMapValue(ret, 'content', model.content);
    setMapValue(ret, 'published', model.published);
    return ret;
  }

  @override
  ExternalBlogPost fromMap(Map map) {
    if (map == null) return null;
    final obj = ExternalBlogPost();
    obj.body = map['body'] as String;
    obj.id = map['id'] as String;
    obj.guid = map['guid'] as String;
    obj.link = map['link'] as String;
    obj.title = map['title'] as String;
    obj.content = map['content'] as String;
    obj.published = map['published'] as String;
    return obj;
  }
}

abstract class _$TrainingBlogPostSerializer
    implements Serializer<TrainingBlogPost> {
  @override
  Map<String, dynamic> toMap(TrainingBlogPost model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'guid', model.guid);
    setMapValue(ret, 'link', model.link);
    setMapValue(ret, 'title', model.title);
    setMapValue(ret, 'content', model.content);
    setMapValue(ret, 'published', model.published);
    return ret;
  }

  @override
  TrainingBlogPost fromMap(Map map) {
    if (map == null) return null;
    final obj = TrainingBlogPost();
    obj.id = map['id'] as String;
    obj.guid = map['guid'] as String;
    obj.link = map['link'] as String;
    obj.title = map['title'] as String;
    obj.content = map['content'] as String;
    obj.published = map['published'] as String;
    return obj;
  }
}

abstract class _$NewsArticleSerializer implements Serializer<NewsArticle> {
  Serializer<Body> __bodySerializer;
  Serializer<Body> get _bodySerializer => __bodySerializer ??= BodySerializer();
  @override
  Map<String, dynamic> toMap(NewsArticle model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'body', _bodySerializer.toMap(model.body));
    setMapValue(ret, 'reactions_count',
        codeMap(model.reactionCount, (val) => val as int));
    setMapValue(ret, 'user_reaction', model.userReaction);
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'guid', model.guid);
    setMapValue(ret, 'link', model.link);
    setMapValue(ret, 'title', model.title);
    setMapValue(ret, 'content', model.content);
    setMapValue(ret, 'published', model.published);
    return ret;
  }

  @override
  NewsArticle fromMap(Map map) {
    if (map == null) return null;
    final obj = NewsArticle();
    obj.body = _bodySerializer.fromMap(map['body'] as Map);
    obj.reactionCount =
        codeMap<int>(map['reactions_count'] as Map, (val) => val as int);
    obj.userReaction = map['user_reaction'] as int;
    obj.id = map['id'] as String;
    obj.guid = map['guid'] as String;
    obj.link = map['link'] as String;
    obj.title = map['title'] as String;
    obj.content = map['content'] as String;
    obj.published = map['published'] as String;
    return obj;
  }
}

abstract class _$QuerySerializer implements Serializer<Query> {
  @override
  Map<String, dynamic> toMap(Query model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'question', model.title);
    setMapValue(ret, 'answer', model.content);
    setMapValue(ret, 'category', model.published);
    setMapValue(ret, 'sub_category', model.subCategory);
    setMapValue(ret, 'sub_sub_category', model.subSubCategory);
    setMapValue(ret, 'id', model.id);
    return ret;
  }

  @override
  Query fromMap(Map map) {
    if (map == null) return null;
    final obj = Query();
    obj.title = map['question'] as String;
    obj.content = map['answer'] as String;
    obj.published = map['category'] as String;
    obj.subCategory = map['sub_category'] as String;
    obj.subSubCategory = map['sub_sub_category'] as String;
    obj.id = map['id'] as String;
    return obj;
  }
}
