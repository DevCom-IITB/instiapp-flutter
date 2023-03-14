import 'package:InstiApp/src/api/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'venter.g.dart';

@JsonSerializable()
class Complaint {
  @JsonKey(name: "id")
  String? complaintID;
  @JsonKey(name: "created_by")
  User? complaintCreatedBy;
  @JsonKey(name: "description")
  String? description;
  @JsonKey(name: "suggestions")
  String? suggestions;
  @JsonKey(name: "location_details")
  String? locationDetails;
  @JsonKey(name: "report_date")
  String? complaintReportDate;
  @JsonKey(name: "status")
  String? status;
  @JsonKey(name: "latitude")
  double? latitude;
  @JsonKey(name: "longitude")
  double? longitude;
  @JsonKey(name: "location_description")
  String? locationDescription;
  @JsonKey(name: "tags")
  List<TagUri>? tags;
  @JsonKey(name: "comments")
  List<Comment>? comments;
  @JsonKey(name: "users_up_voted")
  List<User>? usersUpVoted;
  @JsonKey(name: "images")
  List<String>? images;
  @JsonKey(name: "is_subscribed")
  bool? isSubscribed;
  int? voteCount;

  Complaint(
      {this.complaintID,
      this.complaintCreatedBy,
      this.description,
      this.suggestions,
      this.locationDetails,
      this.complaintReportDate,
      this.status,
      this.latitude,
      this.longitude,
      this.locationDescription,
      this.tags,
      this.comments,
      this.usersUpVoted,
      this.images,
      this.isSubscribed,
      this.voteCount});
  factory Complaint.fromJson(Map<String, dynamic> json) =>
      _$ComplaintFromJson(json);
  Map<String, dynamic> toJson() => _$ComplaintToJson(this);
}

@JsonSerializable()
class TagUri {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "tag_uri")
  String? tagUri;

  TagUri({this.id, this.tagUri});
  factory TagUri.fromJson(Map<String, dynamic> json) =>
      _$TagUriFromJson(json);
  Map<String, dynamic> toJson() => _$TagUriToJson(this);
}

@JsonSerializable()
class Comment {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "time")
  String? time;
  @JsonKey(name: "text")
  String? text;
  @JsonKey(name: "commented_by")
  User? commentedBy;
  @JsonKey(name: "complaint")
  String? complaintID;

  Comment(
      {this.id, this.time, this.text, this.commentedBy, this.complaintID});
  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
