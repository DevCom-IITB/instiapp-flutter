
import 'package:json_annotation/json_annotation.dart';

part 'UserTag.g.dart';

@JsonSerializable()
class UserTag {
  @JsonKey(name: "id")
  int? tagID;

  @JsonKey(name: "name")
  String? tagName;


  UserTag({
    this.tagID,
    this.tagName
  });

  factory UserTag.fromJson(Map<String, dynamic> json) =>
      _$UserTagFromJson(json);

  Map<String, dynamic> toJson() => _$UserTagToJson(this);

}

@JsonSerializable()
class UserTagHolder {
  @JsonKey(name: "id")
  int? holderID;

  @JsonKey(name: "name")
  String? holderName;

  @JsonKey(name: "tags")
  List<UserTag>? holderTags;


  UserTagHolder({
    this.holderID,
    this.holderName,
    this.holderTags
  });

  factory UserTagHolder.fromJson(Map<String, dynamic> json) =>
      _$UserTagHolderFromJson(json);

  Map<String, dynamic> toJson() => _$UserTagHolderToJson(this);

}
