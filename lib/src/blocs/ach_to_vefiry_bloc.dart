import 'dart:collection';

import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:InstiApp/src/api/request/achievement_create_request.dart';
import 'package:rxdart/rxdart.dart';

import 'ia_bloc.dart';

class VerifyBloc extends Object {
  final InstiAppBloc bloc;

  List<Achievement> _achievements = [];

  VerifyBloc(this.bloc);

  ValueStream<UnmodifiableListView<Achievement>> get achievements =>
      _achievementSubject.stream;
  final _achievementSubject =
      BehaviorSubject<UnmodifiableListView<Achievement>>();

  Future<void> updateAchievements(String bodyId) async {
    var yourAchievementResponse = await bloc.client
        .getBodyAchievements(bloc.getSessionIdHeader(), bodyId);
    _achievements = yourAchievementResponse;
    _achievementSubject.add(UnmodifiableListView(_achievements));
  }

  Future<void> dismissAchievement(bool verify, Achievement achievement) async {
    print("Entered dismiss achievement");
    var req = AchievementCreateRequest();
    req.adminNote = achievement.adminNote;
    req.body = achievement.body;
    req.event = achievement.event;
    req.id = achievement.id;
    req.offer = achievement.offer;
    req.timeOfCreation = achievement.timeOfCreation;
    req.timeOfModification = achievement.timeOfModification;
    req.user = achievement.user;
    req.verifiedBy = achievement.verifiedBy;
    req.bodyID = achievement.body.bodyID;
    req.verified = verify && !achievement.verified;
    req.dismissed = true;
    req.title = achievement.title;
    req.description = achievement.description;

    await bloc.client
        .dismissAchievement(bloc.getSessionIdHeader(), req.id, req);
    print(req);
  }
}
