import 'package:InstiApp/src/api/model/post.dart';

List<Post> Function() placementPosts = () => List.generate(
      20,
      (i) => new PlacementBlogPost(
          i.toString(),
          i.toString(),
          "",
          "Demo Placement Title " + i.toString(),
          "Demo Placement Content " + i.toString(),
          "2022-01-01T00:00:00+05:30"),
    );

List<Post> Function() trainingPosts = () => List.generate(
      20,
      (i) => new TrainingBlogPost(
          i.toString(),
          i.toString(),
          "",
          "Demo Internship Title " + i.toString(),
          "Demo Internship Content " + i.toString(),
          "2022-01-01T00:00:00+05:30"),
    );

List<Post> Function() externalBlogPosts = () => List.generate(
      20,
      (i) => new ExternalBlogPost(
          i.toString(),
          i.toString(),
          "",
          "Demo External Blog Title " + i.toString(),
          "Demo External Blog Content " + i.toString(),
          "2022-01-01T00:00:00+05:30",
          body: "Someone"),
    );

List<Post> Function() queryPosts = () => List.generate(
      20,
      (i) => new Query(
          content: "Demo Answer " + i.toString(),
          link: "",
          guid: i.toString(),
          title: "Demo Question " + i.toString(),
          published: "2022-01-01T00:00:00+05:30",
          subCategory: "Demo Sub Category "),
    );
