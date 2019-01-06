import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/response/explore_response.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:rxdart/rxdart.dart';

class ExploreBloc {
  // parent bloc
  InstiAppBloc bloc;

  // Streams
  Stream<ExploreResponse> get explore => _exploreSubject.stream;
  final _exploreSubject = BehaviorSubject<ExploreResponse>();

  // Params
  String query = "";

  // State
  List<Body> allBodies;
  ExploreResponse currExploreResponse;

  ExploreBloc(this.bloc);

  _push(ExploreResponse resp) {
    currExploreResponse = resp;
    _exploreSubject.add(resp);
  }

  Future<void> refresh() async {
    if ((query ?? "") == "") {
      if (allBodies?.isEmpty ?? true) {
        allBodies = await bloc.client.getAllBodies(bloc.getSessionIdHeader());
      }
      _push(ExploreResponse(bodies: allBodies));

    } else {
      _push(await bloc.client.search(bloc.getSessionIdHeader(), query));
    }
    return Future.delayed(Duration(milliseconds: 300));
  }
}
