import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:InstiApp/src/api/apiclient.dart';
import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/request/achievement_create_request.dart';
import 'package:InstiApp/src/api/response/achievement_create_response.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/body.dart';
//import 'package:flutter/src/widgets/framework.dart';

import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/bodypage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:device_calendar/device_calendar.dart' as cal;

class Validators {
  var validator =
      StreamTransformer<String, String>.fromHandlers(handleData: (text, sink) {
    if (text.length > 4) {
      sink.add(text);
    } else {
      sink.addError("Length must be greater than 4");
    }
  });
}

// class for sending request to API
class _AchievementCreateRequest {
  String title;
  String description;
  String admin_note;
  String verauth;
  String event;
  String body;
}

class Bloc extends Object with Validators {
  InstiAppBloc bloc;
  final _titleController = StreamController<String>.broadcast();
  final _descriptionController = StreamController<String>.broadcast();
  final _admin_noteController = StreamController<String>.broadcast();
  final _eventController = StreamController<String>.broadcast();
  final _veryfying_authController = StreamController<String>.broadcast();

  Function(String) get titlechanged => _titleController.sink.add;

  Function(String) get descchanged => _descriptionController.sink.add;

  Function(String) get adminchanged => _admin_noteController.sink.add;

  Function(String) get eventChanged => _eventController.sink.add;

  Function(String) get verauthChanged => _veryfying_authController.sink.add;

  //
  //Another way
  // StreamSink<String> get emailChanged => _emailController.sink;
  // StreamSink<String> get passwordChanged => _passwordController.sink;

  Stream<String> get title => _titleController.stream.transform(validator);

  Stream<String> get description =>
      _descriptionController.stream.transform(validator);

  Stream<String> get admin_note =>
      _admin_noteController.stream.transform(validator);

  Stream<String> get event => _eventController.stream.transform(validator);

  Stream<String> get verauth =>
      _veryfying_authController.stream.transform(validator);

  List<Event> _events = [];
  List<Body> _bodies = [];

  // Stream<bool> get submitCheck =>
  //     Observable.combineLatest2(email, password, (e, p) => true);

  // submit() {
  //   print("xyx");
  // }

  // Future<AchievementCreateResponse> postForm(_AchievementCreateRequest req) async {
  //   try {
  //     return bloc.client.postForm(bloc.getSessionIdHeader(), req);
  //   } catch (ex) {
  //     print(ex);
  //     return null;
  //   }
  // }
  Bloc(this.bloc);

  Future<AchievementCreateResponse> postForm(
      AchievementCreateRequest req) async {
    try {
      var comment = await bloc.client.postForm(bloc.getSessionIdHeader(), req);
      //log(comment.result); //comment.whenComplete(() => null);
      return comment;
    } catch (ex) {
      print(ex);
      return null;
    }
  }

  Future<List<Event>> searchForEvent(String query) async {
    print("Search called");
    if (query.length < 3) {
      return [];
    }
    var searchResponse =
        await bloc.client.search(bloc.getSessionIdHeader(), query);
    print("Search responed");

    _events = searchResponse.events;
    print(_events.map((e) => e.eventName));
    return _events;
  }

  Future<List<Body>> searchForBody(String query) async {
    print("Search called");
    if (query.length < 3) {
      return [];
    }
    var searchResponse =
        await bloc.client.search(bloc.getSessionIdHeader(), query);
    print("Search responed");

    _bodies = searchResponse.bodies;
    print(_bodies.map((e) => e.bodyName));
    return _bodies;
  }

  void dispose() {
    _titleController.close();
    _descriptionController.close();
    _admin_noteController.close();
    _eventController.close();
    _veryfying_authController.close();
  }
}
