import 'package:json_annotation/json_annotation.dart';

part 'popup_mark_read_request.g.dart';

@JsonSerializable()
class PopupMarkReadRequest {
  @JsonKey(name: "name")
  String? name;

  PopupMarkReadRequest({
    this.name,
  });

  factory PopupMarkReadRequest.fromJson(
      Map<String, dynamic> json) =>
      _$PopupMarkReadRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PopupMarkReadRequestToJson(this);
}