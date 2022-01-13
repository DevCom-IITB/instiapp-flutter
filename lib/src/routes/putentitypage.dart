import 'dart:async';
// import 'dart:html';

import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';

// import 'package:InstiApp/src/utils/safe_webview_scaffold.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_html/shims/dart_ui_real.dart';
// import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Body extends Object {
  late String name;
  late bool used;

  Body({required this.name, required this.used});
}

class PutEntityPage extends StatefulWidget {
  final String? entityID;
  final String cookie;
  final bool isBody;

  PutEntityPage({required this.cookie, this.entityID, this.isBody = false});

  @override
  _PutEntityPageState createState() => _PutEntityPageState();
}

class CreateEventBtn extends StatefulWidget {
  const CreateEventBtn({Key? key}) : super(key: key);

  @override
  _CreateEventBtnState createState() => _CreateEventBtnState();
}

class _CreateEventBtnState extends State<CreateEventBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 15.0
      ),
      child: TextButton(
        onPressed: () {},
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
  final Function onChange;
  DatePickerField({required this.labelText, required this.onChange});

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
      child: TextField(
        controller: textEditingController,
        onChanged: (String s) {
          DateTime newDate = parseDate(s);
          // print(newDate.microsecondsSinceEpoch);
          if(newDate.microsecondsSinceEpoch!=zeroDateTime&&(newDate.isBefore(lastDate)&&newDate.isAfter(initDate))){
            setState(() {parseable=true;labelColor = Colors.grey;
            widget.onChange(newDate);
            });
          }
          else{
            setState(() {parseable = false;labelColor = Colors.red;
            
            });
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
                    widget.onChange(newDate);
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
                    elevation: 5.0
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
                BoxShadow(blurRadius: 5.0, spreadRadius: 1.0, color: Colors.grey.shade400)
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

class _PutEntityPageState extends State<PutEntityPage> {
  Event eventToMake = Event();
  final String hostUrl = "https://insti.app/";
  final String addEventStr = "add-event";
  final String editEventStr = "edit-event";
  final String editBodyStr = "edit-body";
  final String loginStr = "login";
  final String sandboxTrueQParam = "sandbox=true";
  List<TextEditingController> venues = [TextEditingController()];
  bool firstBuild = true;
  bool addedCookie = false;
  final List<Body> bodies = [
    Body(name: 'Devcom', used: false),
    Body(name: 'Dead', used: false)
  ];

  StreamSubscription<String>? onUrlChangedSub;
  WebViewController? webViewController;

  // Storing for dispose
  ThemeData? theme;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    onUrlChangedSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    // var url =
    //     "$hostUrl${widget.entityID == null ? addEventStr : ((widget.isBody ? editBodyStr : editEventStr) + "/" + widget.entityID!)}?${widget.cookie}&$sandboxTrueQParam";
    final List<MultiSelectItem> msi = bodies.map((e) =>
        MultiSelectItem(e, e.name)).toList();
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
              webViewController?.reload();
            },
          ),
        ],
      ),
    ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                color: Colors.blue,
                height: 200,
              ),
              TextField(
                decoration: InputDecoration(
                    label: Text('Event Name')
                ),
                onChanged: (String v){

                },
              ),
              Row(
                children: [
                  Expanded(child: DatePickerField(
                    labelText: 'From *',
                    onChange: (DateTime d){
                      //update field in json object for form.
                    },
                  )),
                  Expanded(child: DatePickerField(
                      labelText: 'To *',
                      onChange: (DateTime d){
                        //update field in json object for form.
                      },
                  )),
                ],
              ),
              Row(//row for time pickers
                children: [],
              ),

              ...venues.map((venue)=>Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: venue,
                  decoration: InputDecoration(
                    label: Text('Venue'),
                    suffixIcon: IconButton(
                    icon: (venues.indexOf(venue)>0)?Icon(Icons.remove):Icon(Icons.add),
                    onPressed: (){
                      int index = venues.indexOf(venue);
                      if(venues.length>1&&(index!=0)){
                        setState(() {
                          venues.remove(venue);
                        });
                      }
                      else{
                        setState(() {
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
                  listType: MultiSelectListType.LIST,
                  items: msi,
                  buttonText: Text(
                    'Bodies *',
                    style: TextStyle(
                      fontSize: 15
                    ),
                  ),
                  onConfirm: (values) {
                    //TODO:Implement onConfirm bodies
                    // print(values[0]?.name);
                  }
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    label: Text('Website URL'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  decoration: InputDecoration(
                    label: Text('Description'),
                  ),
                  style: TextStyle(
                  ),
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
              CreateEventBtn(),
            ],
          ),
        )
    );
  }
}
