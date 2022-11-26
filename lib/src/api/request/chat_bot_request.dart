import 'package:json_annotation/json_annotation.dart';

part 'chat_bot_request.g.dart';

@JsonSerializable()
class ChatBotRequest {
  @JsonKey(name: "data")
  String? question;

  ChatBotRequest({
    this.question
  });

  factory ChatBotRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatBotRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChatBotRequestToJson(this);
}
