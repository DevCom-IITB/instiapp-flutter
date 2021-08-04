import 'dart:async';
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
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:device_calendar/device_calendar.dart' as cal;

class Validators{

  var validator = StreamTransformer<String,String>.fromHandlers(
      handleData: (text,sink){
        if(text.length>4){
          sink.add(text);
        }else{
          sink.addError("Length must be greater than 4");
        }
      }
  );

}



// class for sending request to API
class _AchievementCreateRequest{
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
  Stream<String> get event =>
      _eventController.stream.transform(validator);
  Stream<String> get verauth =>
      _veryfying_authController.stream.transform(validator);

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
  Future<AchievementCreateResponse> postForm(AchievementCreateRequest req) async {
    try {
      req.event=Event();
      req.verauth=Body();
      var comment= await bloc.client.postForm(bloc.getSessionIdHeader(), req);
      log(comment.result);//comment.whenComplete(() => null);
      return comment;
    } catch (ex) {
      print(ex);
      return null;
    }
  }



  void dispose(){
    _titleController.close();
    _descriptionController.close();
    _admin_noteController.close();
    _eventController.close();
    _veryfying_authController.close();
  }
}

