import 'package:InstiApp/src/api/model/community.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:rxdart/rxdart.dart';

// List<Community> defCommunities = [
//   Community(
//       id: "0",
//       name: "Insight Discussion Forum",
//       followerCount: "200",
//       about:
//           "A platform meant to channel discussions on topics and issues pertinent to the student community of IIT Bombay.",
//       logo_img:
//           "https://api.insti.app/static/upload/2c/d8/2cd8bf5c-eafb-409b-8a04-f62f94ccd58d-9a4b7273-d80.jpg.jpg",
//       cover_img:
//           "https://newevolutiondesigns.com/images/freebies/colorful-facebook-cover-3.jpg",
//       description:
//           "Insight Discussion Forum is a platform meant to channel discussions on topics and issues pertinent to the student community of IIT Bombay. This group can be used by students to share their thoughts on various happenings in the institute, your opinions on any decisions taken by the institute administration or student policies, your thoughts on government policies regarding IITs or education in the country, and to ask queries to student representatives in the institute with regards to their work and decisions made in their respective fields."),
//   Community(
//     id: "1",
//     name: "CSE group",
//     followerCount: "70",
//     about:
//         "Dolore et voluptatem. Rerum veritatis culpa recusandae qui. Eaque consectetur nesciunt amet quod natus.",
//     logo_img:
//         "https://play-lh.googleusercontent.com/8ddL1kuoNUB5vUvgDVjYY3_6HwQcrg1K2fd_R8soD-e2QYj8fT9cfhfh3G0hnSruLKec",
//     cover_img:
//         "https://newevolutiondesigns.com/images/freebies/colorful-facebook-cover-5.jpg",
//   ),
// ];

class CommunityBloc {
  final String storageID = "community";

  InstiAppBloc bloc;

  List<Community> _communities = [];

  ValueStream<List<Community>> get communities => _communitySubject.stream;
  final _communitySubject = BehaviorSubject<List<Community>>();

  String query = "";

  CommunityBloc(this.bloc);

  Future<Community?> getCommunity(String id) async {
    // try {
    //   return _communities.firstWhere((community) => community.id == id);
    // } catch (ex) {
    return await bloc.client.getCommunity(bloc.getSessionIdHeader(), id);
    // }
  }

  Future refresh() async {
    // _communities = defCommunities;
    // _communitySubject.add(defCommunities);

    _communities = await bloc.client.getCommunities(bloc.getSessionIdHeader());
    _communitySubject.add(_communities);
  }
}
