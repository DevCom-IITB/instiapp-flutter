// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_article.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$NewsArticleSerializer implements Serializer<NewsArticle> {
  Serializer<Body> __bodySerializer;
  Serializer<Body> get _bodySerializer =>
      __bodySerializer ??= new BodySerializer();
  @override
  Map<String, dynamic> toMap(NewsArticle model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.articleID);
    setMapValue(ret, 'link', model.link);
    setMapValue(ret, 'title', model.title);
    setMapValue(ret, 'content', model.content);
    setMapValue(ret, 'published', model.published);
    setMapValue(ret, 'body', _bodySerializer.toMap(model.body));
    return ret;
  }

  @override
  NewsArticle fromMap(Map map) {
    if (map == null) return null;
    final obj = new NewsArticle();
    obj.articleID = map['id'] as String;
    obj.link = map['link'] as String;
    obj.title = map['title'] as String;
    obj.content = map['content'] as String;
    obj.published = map['published'] as String;
    obj.body = _bodySerializer.fromMap(map['body'] as Map);
    return obj;
  }
}
