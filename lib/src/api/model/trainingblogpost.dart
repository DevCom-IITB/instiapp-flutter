import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'trainingblogpost.jser.dart';

class TrainingBlogPost {
  @Alias("id")
  String postID;

  @Alias("link")
  String link;

  @Alias("title")
  String title;

  @Alias("content")
  String content;

  @Alias("published")
  String published;
}

@GenSerializer()
class TrainingBlogPostSerializer extends Serializer<TrainingBlogPost> with _$TrainingBlogPostSerializer {}