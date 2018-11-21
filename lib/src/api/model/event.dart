import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'event.jser.dart';

class Event {
  // TODO
}

@GenSerializer()
class EventSerializer extends Serializer<Event> with _$EventSerializer {}