import 'package:json_annotation/json_annotation.dart';

part 'chat_bot_response.g.dart';

@JsonSerializable()
class ChatBotResponse {
  @JsonKey(name: "data")
  List<String>? data;


  ChatBotResponse({this.data});
  factory ChatBotResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatBotResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatBotResponseToJson(this);
}
