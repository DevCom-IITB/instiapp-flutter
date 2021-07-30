import 'dart:async';
import 'dart:developer';
import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:InstiApp/src/api/request/achievement_create_request.dart';
import 'package:InstiApp/src/api/response/achievement_create_response.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/api/model/event.dart';
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
class Bloc extends Object with Validators {

  InstiAppBloc bloc;
  final _titleController = StreamController<String>();
  final _descriptionController = StreamController<String>();
  final _admin_noteController = StreamController<String>();
  final _eventController = StreamController<String>();
  final _veryfying_authController = StreamController<String>();

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

  Bloc(this.bloc);
  Future<AchievementCreateResponse> postForm(AchievementCreateRequest req) async {
    try {
      req.description=description.toString();
      req.title=title.toString();
      req.adminNote=admin_note.toString();
      req.verauth=verauth.toString();
      req.event=event.toString();
      req.body=event.toString();


      var comment= bloc.client.postForm(bloc.getSessionIdHeader(), req);
      log(comment.toString());
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

