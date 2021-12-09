import 'package:InstiApp/src/api/model/user.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'venter.g.dart';

class Complaint {
  @JsonKey("id")
  String complaintID;
  @JsonKey("created_by")
  User complaintCreatedBy;
  @JsonKey("description")
  String description;
  @JsonKey("suggestions")
  String suggestions;
  @JsonKey("location_details")
  String locationDetails;
  @JsonKey("report_date")
  String complaintReportDate;
  @JsonKey("status")
  String status;
  @JsonKey("latitude")
  double latitude;
  @JsonKey("longitude")
  double longitude;
  @JsonKey("location_description")
  String locationDescription;
  @JsonKey("tags")
  List<TagUri> tags;
  @JsonKey("comments")
  List<Comment> comments;
  @JsonKey("users_up_voted")
  List<User> usersUpVoted;
  @JsonKey("images")
  List<String> images;
  @JsonKey("is_subscribed")
  bool isSubscribed;
  int voteCount;

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

class TagUri {
  @JsonKey("id")
  String id;
  @JsonKey("tag_uri")
  String tagUri;

  TagUri({this.id, this.tagUri});
  factory TagUri.fromJson(Map<String, dynamic> json) =>
      _$TagUriFromJson(json);
  Map<String, dynamic> toJson() => _$TagUriToJson(this);
}

class Comment {
  @JsonKey("id")
  String id;
  @JsonKey("time")
  String time;
  @JsonKey("text")
  String text;
  @JsonKey("commented_by")
  User commentedBy;
  @JsonKey("complaint")
  String complaintID;

  Comment(
      {this.id, this.time, this.text, this.commentedBy, this.complaintID});
  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

@GenSerializer()
class ComplaintSerializer extends Serializer<Complaint>
    with _$ComplaintSerializer {}

@GenSerializer()
class TagUriSerializer extends Serializer<TagUri> with _$TagUriSerializer {}

@GenSerializer()
class CommentSerializer extends Serializer<Comment> with _$CommentSerializer {}
