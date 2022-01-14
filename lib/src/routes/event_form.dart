
import 'dart:math';

import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';

import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class CreateEventBtn extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function formPoster;
  CreateEventBtn({required this.formKey, required this.formPoster});

  @override
  _CreateEventBtnState createState() => _CreateEventBtnState();
}

class _CreateEventBtnState extends State<CreateEventBtn> {
  late GlobalKey<FormState> formKey;
  @override
  void initState() {
    formKey = widget.formKey;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    formKey = widget.formKey;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 15.0
      ),
      child: TextButton(
        onPressed: () {
          if(!widget.formKey.currentState!.validate()){
            return;
          }
          formKey.currentState!.save();
          //post formdata;
        },
        child: Text('Create'),
        style: TextButton.styleFrom(
            primary: Colors.black,
            backgroundColor: Colors.amber,
            onSurface: Colors.grey,
            elevation: 5.0
        ),
      ),
    );
  }
}

class DatePickerField extends StatefulWidget {
  final String labelText;
  final Function onSaved;
  DatePickerField({required this.labelText, required this.onSaved});

  @override
  _DatePickerFieldState createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  DateTime setDate = DateTime.now();
  DateTime initDate = DateTime.now();
  DateTime lastDate = DateTime.now();
  TextEditingController textEditingController = TextEditingController();
  String formattedDate = "";
  bool parseable = true;
  Color labelColor = Colors.grey;
  static int zeroDateTime = -62170003800000000;
  static DateTime parseDate(String s){
    DateTime d = DateTime(0,0,0,0,0,0,0,0);
    List<String> numstr= s.split('/');
    List<int> nums;
    try{
      nums=numstr.map((e) => int.parse(e)).toList();
      d = DateTime(nums[2],nums[1],nums[0]);
    }
    catch(e){
      // print(s);
      // print("parse failed");
      return d;
    }

    return d;
  }
  static String formatDate(DateTime d) {
    String s = "";
    Function pad = (String s) => s.length == 1 ? '0' + s : s;
    s = [pad(d.day.toString()), pad(d.month.toString()), pad(d.year.toString())]
        .join('/');
    return s;
  }

  @override
  void initState() {
    int yn = setDate.year;
    setState(() {
      initDate = DateTime.fromMillisecondsSinceEpoch(
          DateTime(yn - 1).millisecondsSinceEpoch);
      lastDate = DateTime.fromMillisecondsSinceEpoch(
          DateTime(yn + 1).millisecondsSinceEpoch);
      formattedDate = formatDate(setDate);
      textEditingController.text = formattedDate;
    });
    setDate = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: textEditingController,
        onChanged: (String s) {
          DateTime newDate = parseDate(s);
          // print(newDate.microsecondsSinceEpoch);
          if(newDate.microsecondsSinceEpoch!=zeroDateTime&&(newDate.isBefore(lastDate)&&newDate.isAfter(initDate))){
            setState(() {parseable=true;labelColor = Colors.grey;
            });
          }
          else{
            setState(() {parseable = false;labelColor = Colors.red;

            });
          }
        },
        validator: (String? s){
          if(s!=null){
            DateTime newDate = parseDate(s);
            if(newDate.microsecondsSinceEpoch!=zeroDateTime){
              return 'Date Not Parsed. Format: DD/MM/YYYY';
            }
            else if((newDate.isBefore(lastDate)&&newDate.isAfter(initDate))){
              return 'Date must be within a year of today.';
            }
          }

        },
        onSaved: (String? dateStr){
          if(dateStr!=null){
            widget.onSaved(dateStr);
          }
        },
        decoration: InputDecoration(
            label: Text(
              widget.labelText,
              style: TextStyle(
                  color:labelColor
              ),
            ),
            suffix: TextButton(
              child: Icon(
                Icons.calendar_today,
                color: Colors.grey,
              ),
              onPressed: () async {
                DateTime? newDate = await showDatePicker(
                  firstDate: initDate,
                  lastDate: lastDate,
                  initialDate: setDate
                  context: context,

                );
                if (newDate != null) {
                  setState(() {
                    setDate = newDate;
                    widget.onSaved(newDate);
                    formattedDate = formatDate(newDate);
                    textEditingController.text = formattedDate;
                  });
                }
                newDate?.millisecond;
                // showDateRangePicker()
              },
            )
        ),
      ),
    );
  }
}
class AchievementAdder extends StatefulWidget {
  const AchievementAdder({Key? key}) : super(key: key);

  @override
  _AchievementAdderState createState() => _AchievementAdderState();
}

class _AchievementAdderState extends State<AchievementAdder> {
  List<Achievement> acheves = [];
  List<String> acheveTypes = [
    'Unspecified',
    'Participation',
    'First',
    'Second',
    'Third',
    'Special'
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Offered Achievements',
                    style: TextStyle(
                        fontSize: 20
                    ),
                  ),
                  Text(
                    'Make your event stand out',
                    style: TextStyle(
                        fontSize: 15
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                child: Text('Add'),
                onPressed: (){
                  setState(() {
                    acheves.add(Achievement(
                    ));
                  });
                },
                style: TextButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Colors.amber,
                    onSurface: Colors.grey,
                    elevation: 5.0,
                ),
              ),
            )
          ],
        ),
        ...acheves.map((acheve) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(blurRadius: 1.0, spreadRadius: 3.0, color: Colors.grey[200]!)
              ],
            ),
            child: ExpansionTile(
              expandedCrossAxisAlignment: CrossAxisAlignment.end,
              title: Text((acheve.title=="s")?acheve.title!:'Untitled Achievement'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                            hintText: 'Title *'
                        ),
                      ),
                      TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 4,
                        decoration: InputDecoration(
                            hintText: 'Description'
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical:8),
                        width: double.infinity,
                        child: DropdownButton<String>(
                          onChanged: (String? v){},
                          hint: Text('Authority'),
                          items: [
                            'Devcom',
                            'Dead'
                          ].map((String s){
                            return DropdownMenuItem<String>(
                              value: s,
                              child: Text(s),
                            );
                          }).toList(),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical:8),
                        width: double.infinity,
                        child: DropdownButton<String>(
                          hint: Text('Type *'),
                          onChanged: (String? v){},
                          items: acheveTypes.map((String val){
                            return DropdownMenuItem<String>(
                              value: val,
                              child: Text(val),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    child: Text('Remove'),
                    onPressed: (){setState((){acheves.remove(acheve);});},
                  ),
                )
              ],
            ),
          ),
        )).toList()
      ],
    );
  }
}
class AudienceRestrictor extends StatefulWidget {
  const AudienceRestrictor({Key? key}) : super(key: key);

  @override
  _AudienceRestrictorState createState() => _AudienceRestrictorState();
}

class _AudienceRestrictorState extends State<AudienceRestrictor> {
  int reach=0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Restricted Audience',
            style: TextStyle(
                fontSize: 20
            ),
          ),
          Text(
            'Event will be visible only to selected audiences',
            style: TextStyle(
                fontSize: 15
            ),
          ),
          Text(
            'Do not select anything if the event is open for everyone',
            style: TextStyle(
                fontSize: 15
            ),
          ),
          Text(
            'Current estimated reach: ${reach}',
            style: TextStyle(
                fontSize: 15
            ),
          ),
          ExpansionTile(
            title: Text('Hostel'),
            children: [],
          )
        ],
      ),
    );
  }
}

class EventForm extends StatefulWidget {
  final String? entityID;
  final String cookie;
  final bool isBody;
  final User? creator;
  EventForm({required this.cookie, this.creator,this.entityID, this.isBody = false});

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {

  // Event eventToMake = Event();
  final String addEventStr = "add-event";
  final String editEventStr = "edit-event";
  final String editBodyStr = "edit-body";
  final String loginStr = "login";
  final String sandboxTrueQParam = "sandbox=true";
  List<TextEditingController> venues = [TextEditingController()];
  bool firstBuild = true;
  bool addedCookie = false;
  // final List<Body> bodies = [
  //   Body(name: 'Devcom', used: false),
  //   Body(name: 'Dead', used: false)
  // ];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Body> bodyOptions = [];
  List<Body> creatorBodies = [];

  //Form Fields
  late String eventID;
  late String StrID;
  late String eventName;
  late String eventDescription;
  late String eventImageURL;
  late String eventStartTime = DateTime.now().toString();
  late String eventEndTime = DateTime.now().toString();
  late String eventIsAllDay;
  late List<String> eventVenues = ['Venue'];
  late List<Body> eventBodies = [];
  List<User> eventBlankGoing = [];
  List<User> eventBlankInterested= [];
  late String eventWebsiteURL;
  late int eventUserUesInt;
  late User creator;
  // Storing for dispose
  ThemeData? theme;

  @override
  void initState() {
    if(widget.creator!=null){
      //must be non-null since event form has been accessed.
      creator = widget.creator!;
    }
    //TODO:Implemecnt code for loading an existing event into the form.
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? temp =  BlocProvider.of(context)!.bloc.currSession!.profile;
    if(temp!=null){
      creator = temp;
    }
    ()async{
      List<Body> tempBodies= await BlocProvider.of(context)!.bloc.client.getAllBodies(BlocProvider.of(context)!.bloc.currSession!.sessionid!);
      setState(() {
        bodyOptions = [tempBodies[0], tempBodies[1], tempBodies[2]];
        // creatorBodies=[];
      });
    }();
    theme = Theme.of(context);
    final _bodyList = creatorBodies.map((body) =>
        MultiSelectItem<Body?>(body, body.bodyName!)).toList();
    return Scaffold(bottomNavigationBar: MyBottomAppBar(
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          BackButton(),
          IconButton(
            tooltip: "Refresh",
            icon: Icon(
              Icons.refresh_outlined,
              semanticLabel: "Refresh",
            ),
            onPressed: () {

            },
          ),
        ],
      ),
    ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  color: Colors.blue,
                  height: 200,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Event Name"
                  ),
                  validator: (String? value){
                    if(value!.isEmpty||value.length>50){
                      return 'Event Name length must be 0-50';
                    }
                  },
                  onSaved: (String? evName){
                    if(evName!=null){
                      eventName = evName;
                    }
                  },
                ),
                Row(
                  children: [
                    Expanded(child: DatePickerField(
                      labelText: 'From *',
                      onSaved: (DateTime d){
                        DateTime temp = DateTime.parse(eventStartTime);
                        temp = DateTime(d.year, d.month, d.day,temp.hour, temp.minute);
                        eventStartTime = temp.toString();
                      },
                    )),
                    Expanded(child: DatePickerField(
                      labelText: 'To *',
                      onSaved: (DateTime d){
                        DateTime temp = DateTime.parse(eventEndTime);
                        temp = DateTime(d.year, d.month, d.day,temp.hour, temp.minute);
                        eventEndTime = temp.toString();
                      },
                    )),
                  ],
                ),
                Row(//row for time pickers
                  children: [],
                ),

                ...venues.map((venue)=>Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: venue,
                    onSaved: (String? venueval){
                      if(venueval!=null){
                        eventVenues[venues.indexOf(venue)] = venueval;
                      }
                    },
                    decoration: InputDecoration(
                      label: Text('Venue'),
                      //TODO:Make TextField with suggestions.
                      suffixIcon: IconButton(
                        icon: (venues.indexOf(venue)>0)?Icon(Icons.remove):Icon(Icons.add),
                        onPressed: (){
                          int index = venues.indexOf(venue);
                          if(venues.length>1&&(index!=0)){
                            setState(() {
                              eventVenues.removeAt(index);
                              venues.remove(venue);
                            });
                          }
                          else{
                            setState(() {
                              eventVenues.add('Venue');
                              venues.add(TextEditingController());
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
                ).toList(),
                MultiSelectDialogField(
                  items: [...bodyOptions].map((e) => MultiSelectItem<Body?>(e,e.bodyName!)).toList(),
                  onConfirm: (values){
                    setState(() {
                      eventBodies.clear();
                      for(int i=0;i<values.length;i++){
                        eventBodies.add(values[i] as Body);
                      }
                      values.clear();
                      print(eventBodies);
                      eventBodies.forEach((element) {print(element.bodyName!);});
                    });
                  },
                ),
                Text(
                  eventBodies.map((e) => e.bodyName).join(',')
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      label: Text('Website URL'),
                    ),
                    onSaved: (String? url){
                      eventWebsiteURL = url!;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    decoration: InputDecoration(
                      label: Text('Description'),
                    ),
                    style: TextStyle(
                    ),
                    onSaved: (String? desc){
                      eventDescription = desc!;
                    },
                  ),
                ),
                AchievementAdder(),
                AudienceRestrictor(),
                GestureDetector(
                  onTap: () {
                    //value = !=value
                  },
                  child: Row(
                    children: [
                      Switch(
                        activeColor: Colors.amber,
                        value: true,
                        onChanged: (v) {},
                      ),
                      Text('Notify followers on creation/updation')
                    ],
                  ),
                ),
                CreateEventBtn(formKey:_formKey, formPoster: (){
                  //TODO:replace by a function using private members of EventForm
                  //to make a post request to that url.
                },),
              ],
            ),
          ),
        )
    );
  }
}
