import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/user.dart';

class ShareURLMaker {
    static final String WEB_HOST = "https://insti.app/";

    static String getEventURL(Event event) {
        return WEB_HOST + "event/" + event.eventStrID;
    }

    static String getBodyURL(Body body) {
        return WEB_HOST + "org/" + body.strId;
    }

    static String getUserURL(User user) {
        return WEB_HOST + "user/" + user.ldapId;
    }
}