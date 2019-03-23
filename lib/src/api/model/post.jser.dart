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
    final obj = new Post();
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
    final obj = new PlacementBlogPost();
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
    final obj = new TrainingBlogPost();
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
  Serializer<Body> get _bodySerializer =>
      __bodySerializer ??= new BodySerializer();
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
    final obj = new NewsArticle();
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
