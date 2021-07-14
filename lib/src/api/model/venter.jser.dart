// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venter.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$ComplaintSerializer implements Serializer<Complaint> {
  Serializer<User> __userSerializer;
  Serializer<User> get _userSerializer => __userSerializer ??= UserSerializer();
  Serializer<TagUri> __tagUriSerializer;
  Serializer<TagUri> get _tagUriSerializer =>
      __tagUriSerializer ??= TagUriSerializer();
  Serializer<Comment> __commentSerializer;
  Serializer<Comment> get _commentSerializer =>
      __commentSerializer ??= CommentSerializer();
  @override
  Map<String, dynamic> toMap(Complaint model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.complaintID);
    setMapValue(
        ret, 'created_by', _userSerializer.toMap(model.complaintCreatedBy));
    setMapValue(ret, 'description', model.description);
    setMapValue(ret, 'suggestions', model.suggestions);
    setMapValue(ret, 'location_details', model.locationDetails);
    setMapValue(ret, 'report_date', model.complaintReportDate);
    setMapValue(ret, 'status', model.status);
    setMapValue(ret, 'latitude', model.latitude);
    setMapValue(ret, 'longitude', model.longitude);
    setMapValue(ret, 'location_description', model.locationDescription);
    setMapValue(
        ret,
        'tags',
        codeIterable(
            model.tags, (val) => _tagUriSerializer.toMap(val as TagUri)));
    setMapValue(
        ret,
        'comments',
        codeIterable(
            model.comments, (val) => _commentSerializer.toMap(val as Comment)));
    setMapValue(
        ret,
        'users_up_voted',
        codeIterable(
            model.usersUpVoted, (val) => _userSerializer.toMap(val as User)));
    setMapValue(
        ret, 'images', codeIterable(model.images, (val) => val as String));
    setMapValue(ret, 'is_subscribed', model.isSubscribed);
    setMapValue(ret, 'voteCount', model.voteCount);
    return ret;
  }

  @override
  Complaint fromMap(Map map) {
    if (map == null) return null;
    final obj = Complaint();
    obj.complaintID = map['id'] as String;
    obj.complaintCreatedBy = _userSerializer.fromMap(map['created_by'] as Map);
    obj.description = map['description'] as String;
    obj.suggestions = map['suggestions'] as String;
    obj.locationDetails = map['location_details'] as String;
    obj.complaintReportDate = map['report_date'] as String;
    obj.status = map['status'] as String;
    obj.latitude = map['latitude'] as double;
    obj.longitude = map['longitude'] as double;
    obj.locationDescription = map['location_description'] as String;
    obj.tags = codeIterable<TagUri>(map['tags'] as Iterable,
        (val) => _tagUriSerializer.fromMap(val as Map));
    obj.comments = codeIterable<Comment>(map['comments'] as Iterable,
        (val) => _commentSerializer.fromMap(val as Map));
    obj.usersUpVoted = codeIterable<User>(map['users_up_voted'] as Iterable,
        (val) => _userSerializer.fromMap(val as Map));
    obj.images =
        codeIterable<String>(map['images'] as Iterable, (val) => val as String);
    obj.isSubscribed = map['is_subscribed'] as bool;
    obj.voteCount = map['voteCount'] as int;
    return obj;
  }
}

abstract class _$TagUriSerializer implements Serializer<TagUri> {
  @override
  Map<String, dynamic> toMap(TagUri model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'tag_uri', model.tagUri);
    return ret;
  }

  @override
  TagUri fromMap(Map map) {
    if (map == null) return null;
    final obj = TagUri();
    obj.id = map['id'] as String;
    obj.tagUri = map['tag_uri'] as String;
    return obj;
  }
}

abstract class _$CommentSerializer implements Serializer<Comment> {
  Serializer<User> __userSerializer;
  Serializer<User> get _userSerializer => __userSerializer ??= UserSerializer();
  @override
  Map<String, dynamic> toMap(Comment model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'time', model.time);
    setMapValue(ret, 'text', model.text);
    setMapValue(ret, 'commented_by', _userSerializer.toMap(model.commentedBy));
    setMapValue(ret, 'complaint', model.complaintID);
    return ret;
  }

  @override
  Comment fromMap(Map map) {
    if (map == null) return null;
    final obj = Comment();
    obj.id = map['id'] as String;
    obj.time = map['time'] as String;
    obj.text = map['text'] as String;
    obj.commentedBy = _userSerializer.fromMap(map['commented_by'] as Map);
    obj.complaintID = map['complaint'] as String;
    return obj;
  }
}
