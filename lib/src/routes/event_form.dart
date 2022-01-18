
import 'dart:convert';
// import 'dart:html';
import 'package:InstiApp/src/api/model/UserTag.dart';
import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/model/venue.dart';
import 'package:InstiApp/src/api/request/event_create_request.dart';
import 'package:InstiApp/src/api/request/image_upload_request.dart';
import 'package:InstiApp/src/api/response/image_upload_response.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:analyzer/dart/ast/token.dart';

import 'package:flutter/material.dart';
// import 'package:flutter_html/shims/dart_ui_real.dart';
// import 'package:flutter_html/shims/dart_ui_real.dart';
// import 'package:flutter_html/flutter_html.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:jaguar/http/http.dart';
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
          widget.formPoster();
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
          // print('date validator');
          if(s!=null){
            DateTime newDate = parseDate(s);
            if(newDate.microsecondsSinceEpoch==zeroDateTime){
              return 'Date Not Parsed. Format: DD/MM/YYYY';
            }
            else if(!(newDate.isBefore(lastDate)&&newDate.isAfter(initDate))){
              return 'Date must be within a year of today.';
            }
          }
          return null;
        },
        onSaved: (String? dateStr){
          if(dateStr!=null){
            widget.onSaved(parseDate(dateStr));
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
  final Function postData;
  final List<Body> eventBodies;
  AchievementAdder({required this.postData, required this.eventBodies});

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
  void updateFormData(){
    widget.postData(acheves);
  }
  String getAchevTitle(Achievement achev){
    if(achev.title!=null && achev.title!.length>0){
      return achev.title!;
    }
    else{
      return 'Untitled Achievement';
    }
  }
  @override
  Widget build(BuildContext context) {
    // print(widget.eventBodies);
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
              title: Text(getAchevTitle(acheve)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'Title *'
                        ),
                        validator: (String? acheveTitle){
                          // print('ac. title. validator');
                          if(acheveTitle!.length==0||acheveTitle.length>50){
                            return 'Title length must be 0 to 50';
                          }
                          return null;
                        },
                        onChanged: (String? s){
                          setState(() {
                            acheve.title = s!;
                          });
                        },
                        onSaved: (String? acheveTitle){
                          acheves[acheves.indexOf(acheve)].title = acheveTitle!;
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 4,
                        decoration: InputDecoration(
                            hintText: 'Description'
                        ),
                        //Validator?
                        onSaved: (String? achevDesc){
                          acheves[acheves.indexOf(acheve)].description = achevDesc!;
                        },
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical:8),
                        width: double.infinity,
                        child: DropdownButtonFormField<String>(
                          value: (acheve.body!=null)?acheve.body!.bodyName!:null,
                          onChanged: (String? v){
                            setState(() {
                              acheve.body = widget.eventBodies.firstWhere((element) => element.bodyName==v);

                            });
                          },
                          decoration: InputDecoration(
                            label: Text('Authority'),
                          ),
                          items: widget.eventBodies.map((Body b){
                            return DropdownMenuItem<String>(
                              value: b.bodyName!,
                              child: Text(b.bodyName!),
                            );
                          }).toList(),
                          onSaved: (String? bodyName){
                            acheves[acheves.indexOf(acheve)].body = widget.eventBodies.firstWhere((element) => element.bodyName==bodyName);
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical:8),
                        width: double.infinity,
                        child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              label: Text('Type *')
                            ),
                            value: (acheve.offer!=null)?acheve.offer:null,
                            //TODO: What to do with Type?Is model choice correct?
                            onChanged: (String? v){
                              setState(() {
                                acheve.offer = v;
                              });
                            },
                            items: acheveTypes.map((String val){
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(val),
                              );
                            }).toList(),
                          onSaved: (String? type){
                            acheves[acheves.indexOf(acheve)].offer = type;
                            if(acheves.indexOf(acheve)==acheves.length-1){
                              //last acheve;
                              //last field saved;=>post data into form
                              widget.postData(acheves);
                            }
                          },
                          ),
                        ),
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
  final Function onSave;
  final client;
  final String cookie;
  AudienceRestrictor({required this.onSave, required this.client, required this.cookie});

  @override
  _AudienceRestrictorState createState() => _AudienceRestrictorState();
}

class _AudienceRestrictorState extends State<AudienceRestrictor> {
  String reach='...';
  List<UserTagHolder> restrictors = [];
  List<String> restrictables = [];
  List<UserTagHolder> selectedTags = [];
  List<int> selectedTagIds = [];
  @override
  void initState() {
    // print(widget.restrictors);
    updateReach();
    ()async{
      List<UserTagHolder> tempTags = await widget.client.getUserTags(widget.cookie);
      setState(() {
        restrictors = tempTags;
        // print('Heres: '+widget.cookie.toString());
        restrictables = restrictors.map((e) => e.holderName!).toList();
        selectedTags = restrictors.map((cat) => UserTagHolder(holderID:cat.holderID, holderName: cat.holderName, holderTags: [])).toList();
        // print(selectedTags);
      });

    }();


    // print(allowed);

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // print(restrictors);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                  'Current estimated reach: ',
                style: TextStyle(
                    fontSize: 15
                ),
              ),
              (reach.compareTo('...')!=0)?Text(
                reach,
                style: TextStyle(
                    fontSize: 15
                ),
              ):Container(
                height: 10,width: 10,
                child: CircularProgressIndicator(strokeWidth: 2,)
              ),
            ],
          ),
        ...selectedTags.map((cat) => ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(cat.holderName!),
            (cat.holderTags!.length==0)?Text(
              'All',
              style: TextStyle(
                  color: Colors.green
              ),
            ):Text(
              'Restricted',
              style: TextStyle(
                  color: Colors.red
              ),
            )
          ],
        ),
        children: [MultiSelectChipField<UserTag?>(
          chipColor: Colors.white,
          scroll: false,
          initialValue: [...selectedTags.firstWhere((element) => element.holderID==cat.holderID).holderTags!],
          showHeader: false,
          headerColor: Colors.white,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(blurRadius: 1.0, spreadRadius: 3.0, color: Colors.grey[200]!)
            ],
          ),
          textStyle: TextStyle(color: Colors.black),
          selectedChipColor: Colors.amber,
          items: restrictors.firstWhere((element) => element.holderID==cat.holderID).holderTags!.map((e) => MultiSelectItem<UserTag?>(e, e.tagName!)).toList(),
          onTap: (List<UserTag?> values){
            setState(() {
              reach = '...';
            });
            print('v: '+values.toString());
              int index = selectedTags.indexOf(cat);
              setState(() {
                selectedTags[index].holderTags!.clear();
                print(selectedTags[index].holderTags);
                for(int i=0;i<values.length;i++){
                  selectedTags[index].holderTags!.add(values[i]!);
                }
                updateSelectedTagIds();
                updateReach();
                print(selectedTags[index].holderTags);
              });
          },
        ),]
    )
        ).toList()
        ],
      ),
    );
  }

  void updateSelectedTagIds() {
    selectedTagIds.clear();
    for(int i=0;i<selectedTags.length;i++){
      selectedTagIds.addAll(selectedTags[i].holderTags!.map((e) => e.tagID!));
    }
  }

  void updateReach()async {
    int newReach = await widget.client.getUserTagsReach(widget.cookie, selectedTagIds);
    // print(newReach);
    setState(() {
    reach = newReach.toString();
    });
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
  static const String placeHolderImage = 'https://i.imgur.com/vxP6SFl.png';
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
  List<Venue> venueOptions = [];
  List<Body> creatorBodies = [];
  List<UserTagHolder> tags = [];
  //Form Fields
  late Future<String> eventID;
  late String StrID;
  late String eventName;
  late String eventDescription;
  late List<Achievement> eventAchievementsOffered = [];
  late String eventImageURL = placeHolderImage;
  late String eventStartTime = DateTime.now().toString();
  late String eventEndTime = DateTime.now().toString();
  late String eventIsAllDay = 'false';
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

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var bloc = BlocProvider.of(context)!.bloc;
    theme = Theme.of(context);
    // final eventBloc
    User? temp =  BlocProvider.of(context)!.bloc.currSession!.profile;
    if(temp!=null){
      creator = temp;
    }

    ()async{
      List<Body> tempBodies= await bloc.client.getAllBodies(widget.cookie);
      List<Venue> tempVenues = await bloc.client.getAllVenues();
      setState(() {
        // tags = tempTags;
        List<Role>? roles = creator.userRoles;
        if(roles!=null){
          List<Body> realOptions = roles.map((e){
            if(e.roleBodyDetails!=null){
              return e.roleBodyDetails!;
            }
            else if(e.roleBodies!=null){
              return e.roleBodies![0];
            }
            // else{
              return tempBodies[0];
            // }
          }).toList();
          bodyOptions = realOptions;
        }
        else{
          bodyOptions = [tempBodies[0], tempBodies[1], tempBodies[2]];
        }
        venueOptions = tempVenues;
        // creatorBodies=[];
      });
    }();

    // final _bodyList = creatorBodies.map((body) =>
    //     MultiSelectItem<Body?>(body, body.bodyName!)).toList();
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
                  // color: Colors.amber[200],
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(eventImageURL)
                    )
                  ),
                  child: TextButton(
                    onPressed: () async{
                      final ImagePicker _picker = ImagePicker();
                      final XFile? pi = await _picker.pickImage(source: ImageSource.gallery);
                      // print(pi!.name);
                      String img64 = base64Encode((await pi!.readAsBytes()).cast<int>());
                      // print(img64.substring(0, 10));
                      ImageUploadRequest IUReq = ImageUploadRequest(base64Image: img64);
                      ImageUploadResponse resp = await bloc.client.uploadImage(widget.cookie,IUReq);
                      // print(resp.toJson());
                      setState(() {
                        eventImageURL=resp.pictureURL!;
                      });
                    },
                    child: Text((eventImageURL.length==0)?'Pick an Image':''),
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Event Name"
                  ),
                  validator: (String? value){
                    // print('evnameval');
                    if(value!.isEmpty||value.length>50){
                      return 'Event Name length must be 0-50';
                    }
                    return null;
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
                    //TODO: Fix autofillhints for Venues
                    autofillHints:[...venueOptions].map((e) => e.venueName!).toList(),
                    // enableInteractiveSelection: true,
                    // autofillHints: ['sa', 'aa'],
                    decoration: InputDecoration(

                      label: Text('Venue'),
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
                  title: Text('Bodies'),
                  buttonText: eventBodies.isEmpty?Text('Bodies'):Text(eventBodies.map((e)=>e.bodyName!).toList().join(',')),
                  items: [...bodyOptions].map((e) => MultiSelectItem<Body?>(e,e.bodyName!)).toList(),
                  onConfirm: (values){
                    setState(() {
                      eventBodies.clear();
                      for(int i=0;i<values.length;i++){
                        eventBodies.add(values[i] as Body);
                      }
                      values.clear();
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
                AchievementAdder(
                  postData:(List<Achievement> achevs){
                    // setState(() {
                      eventAchievementsOffered = achevs;
                    // });
                    //Use eventID, filled after posting event.;
                    //TODO:API: call to post achevs
                  },
                  eventBodies: bodyOptions
                ),
                AudienceRestrictor(
                  cookie:widget.cookie,
                  client: bloc.client,
                  onSave: (List<dynamic> rest){

                  },
                ),
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
                CreateEventBtn(formKey:_formKey, formPoster: ()async{
                  if(!_formKey.currentState!.validate()){
                    // print('validation failed');
                    return;
                  }
                  _formKey.currentState!.save();
                  EventCreateRequest req = EventCreateRequest(
                    eventName: eventName,
                    eventDescription: eventDescription,
                    eventImageURL: eventImageURL,
                    eventStartTime: eventStartTime,
                    eventEndTime: eventEndTime,
                    allDayEvent: eventIsAllDay=='true',//TODO: add switch?
                    eventVenueNames: eventVenues,
                    eventBodiesID: eventBodies.map((e) => e.bodyID!).toList()
                  );
                  req;
                  // print(req.toJson());
                  eventID = Future<String>(
                      (){return 's';}
                  );
                  // final respo = await bloc.client.postEventForm(widget.cookie, req);
                  // print(respo!);
                  //update achevs in this widget
                  //call post requests on the updated achevs
                },),
              ],
            ),
          ),
        )
    );
  }
}
//TODO: Implement code for loading an existing event into the form.