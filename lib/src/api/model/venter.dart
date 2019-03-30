import 'package:InstiApp/src/api/model/user.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'venter.jser.dart';

class Complaint {
  @Alias("id")
  String complaintID;
  @Alias("created_by")
  User complaintCreatedBy;
  @Alias("description")
  String description;
  @Alias("suggestions")
  String suggestions;
  @Alias("location_details")
  String locationDetails;
  @Alias("report_date")
  String complaintReportDate;
  @Alias("status")
  String status;
  @Alias("latitude")
  double latitude;
  @Alias("longitude")
  double longitude;
  @Alias("location_description")
  String locationDescription;
  @Alias("tags")
  List<TagUri> tags;
  @Alias("comments")
  List<Comment> comments;
  @Alias("users_up_voted")
  List<User> usersUpVoted;
  @Alias("images")
  List<String> images;
  @Alias("is_subscribed")
  bool isSubscribed;
  int voteCount;
}

class TagUri {
  @Alias("id")
  String id;
  @Alias("tag_uri")
  String tagUri;
}

class Comment {
  @Alias("id")
  String id;
  @Alias("time")
  String time;
  @Alias("text")
  String text;
  @Alias("commented_by")
  User commentedBy;
  @Alias("complaint")
  String complaintID;
}

@GenSerializer()
class ComplaintSerializer extends Serializer<Complaint>
    with _$ComplaintSerializer {}

@GenSerializer()
class TagUriSerializer extends Serializer<TagUri> with _$TagUriSerializer {}

@GenSerializer()
class CommentSerializer extends Serializer<Comment> with _$CommentSerializer {}
