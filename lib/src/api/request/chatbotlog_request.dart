import 'package:json_annotation/json_annotation.dart';

part 'chatbotlog_request.g.dart';

@JsonSerializable()
class ChatBotLogRequest {
  @JsonKey(name: "question")
  String? question;

  @JsonKey(name: "answer")
  String? answer;

  @JsonKey(name: "reaction")
  int? reaction;

  ChatBotLogRequest(
    this.question,
    this.answer,
    this.reaction,
  );

  factory ChatBotLogRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatBotLogRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChatBotLogRequestToJson(this);
}
