
import 'dart:convert';
import 'package:InstiApp/src/api/model/UserTag.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/offeredAchievements.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/model/venue.dart';
import 'package:InstiApp/src/api/request/event_create_request.dart';
import 'package:InstiApp/src/api/request/image_upload_request.dart';
import 'package:InstiApp/src/api/response/event_create_response.dart';
import 'package:InstiApp/src/api/response/image_upload_response.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/event_form_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/src/widgets/form.dart' as flut;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
//TODO:remove autofocus on Event Name?
class CreateEventBtn extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Function formPoster;
  final bool isEditing;
  CreateEventBtn({required this.formKey, required this.isEditing, required this.formPoster});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 15.0
      ),
      child: TextButton(
        onPressed: () {
          formPoster();
        },
        child: Text(isEditing?'Update':'Create'),
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
class DeleteEventBtn extends StatelessWidget {
  final Function delete;
  DeleteEventBtn({required this.delete});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 15.0
      ),
      child: TextButton(
        onPressed: () {
          delete();
        },
        child: Text(
          'Delete',
          style: TextStyle(color: Colors.white),
        ),
        style: TextButton.styleFrom(
            primary: Colors.black,
            backgroundColor: Colors.red,
            onSurface: Colors.grey,
            elevation: 5.0
        ),
      ),
    );
  }
}

class AchievementAdder extends StatefulWidget {
  final Function postData;
  final List<Body> eventBodies;
  final Future<List<OfferedAchievements>>? loadableOffers;
  final Function deleter;
  AchievementAdder({required this.postData, required this.deleter,required this.loadableOffers,required this.eventBodies});

  @override
  _AchievementAdderState createState() => _AchievementAdderState();
}
class _AchievementAdderState extends State<AchievementAdder> {
  List<OfferedAchievements> acheves = [];
  List<Body> authOptions = [];
  List<Map<String,String>> acheveTypes = [
        //ng code loads it from local json file.
        {"code": "generic","name": "Unspecified"},
        {"code": "participation","name": "Participation"},
        {"code": "gold-medal","name": "First"},
        {"code": "silver-medal","name": "Second"},
        {"code": "bronze-medal","name": "Third"},
        {"code": "medal","name": "Special"}
  ];
  void updateFormData(){
    widget.postData(acheves);
  }
  String getAchevTitle(OfferedAchievements achev){
    if(achev.title!=null && achev.title!.length>0){
      return achev.title!;
    }
    else{
      return 'Untitled Achievement';
    }
  }
  @override
  void initState() {
    if(widget.loadableOffers!=null){
      widget.loadableOffers!.then((offers){
        setState(() {
          acheves = offers;
        });
      });
    }
    authOptions = widget.eventBodies;
    super.initState();
  }
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
                    acheves.add(OfferedAchievements(

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
          child: Card(
            elevation: 10,
            borderOnForeground: true,
            child:  ExpansionTile(
                expandedCrossAxisAlignment: CrossAxisAlignment.end,
                title: Text(getAchevTitle(acheve)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: acheve.title,
                          decoration: InputDecoration(
                              hintText: 'Title *'
                          ),
                          validator: (String? acheveTitle){
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
                          initialValue: (acheve.desc!=null?acheve.desc:''),
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          decoration: InputDecoration(
                              hintText: 'Description'
                          ),
                          //Validator?
                          onSaved: (String? achevDesc){
                            acheves[acheves.indexOf(acheve)].desc = achevDesc!;
                          },
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical:8),
                          width: double.infinity,
                          child: DropdownButtonFormField<Body>(
                            value: (acheve.body!=null && authOptions.where((element) => element.bodyID==acheve.body).length>0)?authOptions.firstWhere((element) => acheve.body==element.bodyID):authOptions[0],
                            onChanged: (Body? selectedBody){
                              setState(() {
                                acheve.body = selectedBody!.bodyID;
                              });
                            },
                            decoration: InputDecoration(
                              label: Text('Authority'),
                            ),
                            items: authOptions.map((Body b){
                              return DropdownMenuItem<Body>(
                                value: b,
                                child: Text(b.bodyName!),
                              );
                            }).toList(),
                            onSaved: (Body? body){
                              acheves[acheves.indexOf(acheve)].body = body!.bodyID;
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical:8),
                          width: double.infinity,
                          child: DropdownButtonFormField<Map<String,String>>(
                              decoration: InputDecoration(
                                label: Text('Type *')
                              ),
                              value: (acheve.generic!=null)?acheveTypes.firstWhere((element) => element['code']==acheve.generic):null,
                              onChanged: (Map<String,String>? v){
                                setState(() {
                                  acheve.generic = v!['code'];
                                });
                              },
                              items: acheveTypes.map((Map<String,String> offerType){
                                return DropdownMenuItem<Map<String,String>>(
                                  value: offerType,
                                  child: Text(offerType['name']!),
                                );
                              }).toList(),
                            onSaved: (Map<String,String>? type){
                              acheves[acheves.indexOf(acheve)].generic = type!['code'];
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
                      onPressed: (){
                        if(acheve.achievementID!=null &&acheve.achievementID!=''){
                          showDialog(
                            builder: (ctx)=>(AlertDialog(
                              title: Text('Delete Achievement?'),
                              content: Text('Remove this achievement? This action is irreversible!'),
                              actions: [
                                TextButton(
                                  child: Text('Yes'),
                                  onPressed: (){
                                    widget.deleter(acheve.achievementID);
                                    setState((){acheves.remove(acheve);});
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('No'),
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            )), context: context
                          );
                        }
                        else{
                          setState((){acheves.remove(acheve);});
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ).toList()
      ],
    );
  }
}
class AudienceRestrictor extends StatefulWidget {
  final Function onSave;
  final client;
  final Future<List<int>>? loadableTags;
  final String cookie;
  AudienceRestrictor({required this.onSave,required this.loadableTags, required this.client, required this.cookie});

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
    ()async{
      List<UserTagHolder> tempTags = await widget.client.getUserTags(widget.cookie);
      setState(() {
        restrictors = tempTags;
        restrictables = restrictors.map((e) => e.holderName!).toList();
        if(widget.loadableTags!=null){
          widget.loadableTags!.then((value){
            setState(() {
              selectedTagIds = value;
              selectedTags = [...restrictors.map((cat) => UserTagHolder(
                  holderID:cat.holderID,
                  holderName: cat.holderName,
                  holderTags: cat.holderTags!.where((element) => selectedTagIds.contains(element.tagID)).toList()
              )//UserTagHolder
              )//map
              ];
            });
          });
        }
        else{
          selectedTagIds = [];

          selectedTags = [...restrictors.map((cat) => UserTagHolder(
              holderID:cat.holderID,
              holderName: cat.holderName,
              holderTags: []
          )//UserTagHolder
          )//map
          ];
        }
      });
      updateReach();
    }();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: flut.FormField(
        onSaved: (_){
          widget.onSave(this.selectedTagIds);
        },
        builder:(ctx)=>Column(
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
          ...selectedTags.map((cat) => Card(
            elevation: 10,
            child: ExpansionTile(
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
              initialValue: selectedTags.firstWhere((element) => element.holderID==cat.holderID).holderTags!,
              showHeader: false,
              headerColor: Colors.white,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(blurRadius: 1.0, spreadRadius: 3.0, color: Colors.white)
                ],
              ),
              textStyle: TextStyle(color: Colors.black),
              selectedChipColor: Colors.amber,
              items: restrictors.firstWhere((element) => element.holderID==cat.holderID).holderTags!.map((e) => MultiSelectItem<UserTag?>(e, e.tagName!)).toList(),
              onTap: (List<UserTag?> values){
                setState(() {
                  reach = '...';
                });
                  int index = selectedTags.indexOf(cat);
                  setState(() {
                    selectedTags[index].holderTags!.clear();
                    for(int i=0;i<values.length;i++){
                      selectedTags[index].holderTags!.add(values[i]!);
                    }
                    updateSelectedTagIds();
                    updateReach();
                  });
              },
            ),]
    ),
          )
          ).toList()
          ],
        ),
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
  late String eventID;
  late String StrID;
  TextEditingController eventNameController = TextEditingController();
  TextEditingController eventDescController = TextEditingController();
  late List<OfferedAchievements> eventAchievementsOffered = [];
  late String eventImageURL = placeHolderImage;
  // TextEditingController eventImageURLController = TextEditingController();
  late String eventStartTime = DateTime.now().toString();
  late String eventEndTime = DateTime.now().toString();
  late bool eventIsAllDay = false;
  late List<Venue> eventVenues = [Venue()];
  late List<Body> eventBodies = [];
  List<User> eventBlankGoing = [];
  List<User> eventBlankInterested= [];
  TextEditingController eventWesbiteURLController = TextEditingController();
  late int eventUserUesInt=-1;
  late User creator;
  bool eventNotifications = true;
  List<int> eventUserTags = [];
  // Storing for dispose
  ThemeData? theme;
  bool editingEvent = false;
  bool editingTitle = false;

  String dataLastLoadedFor = '';

  Future<DateTime>? loadableEndTime = null;

  Future<DateTime>? loadableStartTime = null;

  Future<List<int>>? loadableUserTags;

  Future<List<OfferedAchievements>>? loadableOfferedAchevs = null;

  Event? loadedEvent;

  @override
  void initState() {
    if(widget.entityID!=null){
      eventID = widget.entityID!;
      // setState(() {
        editingEvent = true;
      // });
    }
    // if(widget.creator!=null){
    //   //must be non-null since event form has been accessed.
    //   creator = widget.creator!;
    // }

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
    if(editingEvent&&(dataLastLoadedFor!=eventID)){
      try{
        loadData(eventID, bloc.client, widget.cookie);
      }
      catch(e){}
    }
    List<Body> tempbodyOptions = [];
    if(bloc.currSession!.profile!.userRoles!=null){
      for(Role role in bloc.currSession!.profile!.userRoles!){
        (role.roleBodies!=null)?tempbodyOptions.addAll(role.roleBodies!):(){}();
        //TODO:Confirm if this will work
        // (role.roleBodyDetails!=null)?tempbodyOptions.add(role.roleBodyDetails!):(){}();
      }
    }
    bodyOptions = tempbodyOptions;
    ()async{
      // Future<List<Body>> tempBodies= await bloc.client.getAllBodies(widget.cookie);
      List<Venue> tempVenues = await bloc.client.getAllVenues();
        venueOptions = tempVenues;
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
                      String img64 = base64Encode((await pi!.readAsBytes()).cast<int>());
                      ImageUploadRequest IUReq = ImageUploadRequest(base64Image: img64);
                      ImageUploadResponse resp = await bloc.client.uploadImage(widget.cookie,IUReq);
                      setState(() {
                        eventImageURL=resp.pictureURL!;
                      });
                    },
                    child: Text((eventImageURL.length==0)?'Pick an Image':''),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: eventNameController,
                    onTap: (){setState((){editingTitle=true;});},
                    decoration: InputDecoration(
                        label: Text(
                          "Event Name",
                          style:TextStyle(
                            color: editingTitle?Colors.amberAccent:Colors.white,
                          )
                        ),
                      suffixText: '${eventNameController.text.length}/50',
                      suffixStyle: TextStyle(
                        color: Colors.amberAccent
                      ),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent, width: 3)),
                      focusColor: Colors.amberAccent,
                      border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent, width: 3))
                    ),
                    validator: (String? value){
                      if(value!.isEmpty||value.length>50){
                        return 'Event Name length must be 0-50';
                      }
                      return null;
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: DatePickerField(
                      labelText: 'From *',
                      loadDate: loadableStartTime,
                      onSaved: (DateTime d){
                        DateTime temp = DateTime.parse(eventStartTime);
                        temp = DateTime(d.year, d.month, d.day,temp.hour, temp.minute);
                        eventStartTime = temp.toString();

                      },
                    )),
                    Expanded(child: DatePickerField(
                      labelText: 'To *',
                      // key: UniqueKey(),
                      loadDate: loadableEndTime,
                      onSaved: (DateTime d){
                        DateTime temp = DateTime.parse(eventEndTime);
                        temp = DateTime(d.year, d.month, d.day,temp.hour, temp.minute);
                        eventEndTime = temp.toString();
                      },
                    )),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      eventIsAllDay = !eventIsAllDay;
                    });
                  },
                  child: Row(
                    children: [
                      Switch(
                        activeColor: Colors.amber,
                        value: eventIsAllDay,
                        onChanged: (bool v) {
                          eventIsAllDay = v;
                        },
                      ),
                      Text('All day.')
                    ],
                  ),
                ),
                Row(
                  children: (!eventIsAllDay)?[
                    Expanded(child: TimePickerField(
                      labelText: 'From *',
                      loadTime: loadableStartTime,
                      onSaved: (TimeOfDay d){
                        DateTime temp = DateTime.parse(eventStartTime);
                        eventStartTime = DateTime(temp.year, temp.month, temp.day, d.hour, d.minute).toString();
                    },)),
                    Expanded(child: TimePickerField(
                      loadTime: loadableEndTime,
                      labelText: 'To *', onSaved:(TimeOfDay d){
                      DateTime temp = DateTime.parse(eventEndTime);
                      eventEndTime = DateTime(temp.year, temp.month, temp.day, d.hour, d.minute).toString();
                    }))
                  ]:[],
                ),
                ...venues.map((venue)=>Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TypeAheadFormField<Venue>(
                    noItemsFoundBuilder: (ctx)=>Text("No Venue Found."),
                    // initialValue: eventVenues[venues.indexOf(venue)].venueShortName!,
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: venue,
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
                                        eventVenues.add(Venue());
                                        venues.add(TextEditingController());
                                      });
                                    }
                                  },
                                ),
                      )
                    ),
                    suggestionsCallback: (String q)=>venueOptions.where((element) =>
                    (element.venueName!+element.venueShortName!).toLowerCase().contains(q.toLowerCase())),

                    onSuggestionSelected: (Venue v){
                      int venueIndex = venues.indexOf(venue);
                      setState(() {
                        // venues[venueIndex].clear();
                        venues[venueIndex].text = v.venueShortName!;
                        eventVenues[venues.indexOf(venue)] = v;
                      });

                    },
                    itemBuilder: (BuildContext ctx, Venue item)=>Container(
                      padding: EdgeInsets.all(4),
                        child: Text(
                          item.venueShortName!,
                          style: TextStyle(
                            fontSize: 20
                          ),
                        )
                    ),
                  )
                ),
                ).toList(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MultiSelectDialogField(
                    title: Text('Bodies *'),
                    initialValue: eventBodies,
                    buttonText: eventBodies.isEmpty?Text('Bodies *'):Text(eventBodies.map((e)=>e.bodyName!).toList().join(',')),
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
                    validator: (List<Body?>? values){
                      if(eventBodies.isEmpty){
                        return "Select at least one body.";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: eventWesbiteURLController,
                    decoration: InputDecoration(
                      label: Text('Website URL'),
                    ),
                    validator: (String? s){
                      if(s==null||s==''){return null;}
                      if(!s.startsWith('http')){
                        return "URLs must start with 'https://'";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    controller: eventDescController,
                    decoration: InputDecoration(
                      label: Text('Description'),
                    ),
                    style: TextStyle(
                    ),
                  ),
                ),
                AchievementAdder(
                  postData:(List<OfferedAchievements> achevs){
                      eventAchievementsOffered = achevs;
                      //called when form.save() is ran. updates local var with widget's data.
                  },
                  deleter: (String id){
                    bloc.client.deleteAchievement(widget.cookie, id);
                  },
                  loadableOffers: loadableOfferedAchevs,
                  eventBodies: bodyOptions
                ),
                AudienceRestrictor(
                  cookie:widget.cookie,
                  client: bloc.client,
                  loadableTags: loadableUserTags,
                  onSave: (List<int> userTags){
                    eventUserTags = userTags;
                  },
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      eventNotifications = !eventNotifications;
                    });
                  },
                  child: Row(
                    children: [
                      Switch(
                        activeColor: Colors.amber,
                        value: eventNotifications,
                        onChanged: (bool v) {
                          eventNotifications = v;
                        },
                      ),
                      Text('Notify followers on creation/updation')
                    ],
                  ),
                ),
                CreateEventBtn(formKey:_formKey, isEditing: editingEvent,formPoster: ()async{
                  if(!_formKey.currentState!.validate()){
                    return;
                  }

                  _formKey.currentState!.save();
                  //transfers data from1 formfields into respective parameters
                  //collects data from AudieceRestrictor, AchievementAdder too.
                  //validation after saving:
                  if(DateTime.parse(eventStartTime).millisecondsSinceEpoch>DateTime.parse(eventEndTime).millisecondsSinceEpoch){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Event can't start after it ends!"),
                      ),
                    );
                    return;
                  }
                  EventCreateRequest req = EventCreateRequest(
                    eventName: eventNameController.text,
                    eventDescription: eventDescController.text,
                    eventImageURL: eventImageURL,
                    eventStartTime: eventStartTime,
                    eventEndTime: eventEndTime,
                    allDayEvent: eventIsAllDay,
                    eventWebsiteURL: eventWesbiteURLController.text,
                    eventVenueNames: eventVenues.where((element) => element.venueShortName!=null).map((e) => e.venueShortName!).toList(),
                    eventBodiesID: eventBodies.map((e) => e.bodyID!).toList(),
                    eventUserTags: eventUserTags,
                    notify: eventNotifications
                  );
                  if(!editingEvent){
                    //assuming all validators are written right, try-catch is unnecessary.
                    final EventCreateResponse? respo = await bloc.client.createEvent(widget.cookie, req);
                    eventID = respo!.eventId!;
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Event created!"),
                      ),
                    );
                    Navigator.of(context).popAndPushNamed('/event/'+eventID);
                  }
                  else{
                    await bloc.client.updateEvent(widget.cookie,req,eventID);
                  }
                  postOffers(eventID, widget.cookie,bloc.client);
                  //update achevs in this widget
                  //call post requests on the updated achevs
                },),
                (editingEvent&&(loadedEvent!=null?bloc.deleteEventAccess(loadedEvent!):false))?DeleteEventBtn(
                  delete: (){
                    showDialog(
                        builder: (ctx)=>(AlertDialog(
                          title: Text('Delete Event?'),
                          content: Text('Remove this event? This action is irreversible!'),
                          actions: [
                            TextButton(
                              child: Text('Yes'),
                              onPressed: ()async{
                                Navigator.of(context).pop();
                                Navigator.popAndPushNamed(context, '/feed');
                                await bloc.client.deleteEvent(widget.cookie, eventID);
                              },
                            ),
                            TextButton(
                              child: Text('No'),
                              onPressed: (){

                              Navigator.of(context).pop();

                              },
                            )
                          ],
                        )), context: context
                    );
                    // bloc.client
                  },
                ):Container()
              ],
            ),
          ),
        )
    );
  }

  void postOffers(String eventId, String cookie,client)async{
    int index = 0;
    for (OfferedAchievements offer in eventAchievementsOffered){
      offer.event = eventId;
      offer.priority = index;
      bool noErrors = false;
      if(offer.achievementID!=null && offer.achievementID!=''){
        //put
        await client.updateAchievement(widget.cookie, offer,offer.achievementID);
      }
      else{
        //post
          OfferedAchievements ans = await client.createAchievement(cookie, offer);
          if(ans.toJson()['id']!=null){
            noErrors = true;
          }
        if(!noErrors){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Achievement ${offer.title} failed. The event was updated."),
            ),
          );
        }
      }
      index++;
    }
  }

  void loadData(String eventID, client, String sessionID){
    Future<Event> eventOnItsWay = client.getEvent(sessionID, eventID);
    eventOnItsWay.then((prevEv){
      setState(() {
        loadedEvent = prevEv;
        eventNameController.text = prevEv.eventName!;
        if(prevEv.eventDescription!=null){eventDescController.text = prevEv.description!;}
        if(prevEv.eventWebsiteURL!=null){eventWesbiteURLController.text = prevEv.eventWebsiteURL!;}
        eventIsAllDay = prevEv.allDayEvent!;
        eventVenues = prevEv.eventVenues!;
        venues = eventVenues.map((e) => TextEditingController(text: e.venueShortName!)).toList();
        eventBodies = prevEv.eventBodies!;
        eventImageURL = prevEv.eventImageURL!;
      });
    });
    loadableUserTags = eventOnItsWay.then((value){
      return value.eventUserTags!;
    });
    loadableOfferedAchevs = eventOnItsWay.then((value){
        return value.eventOfferedAchievements!;
    });
    loadableStartTime = eventOnItsWay.then((value){
      DateTime d = DateTime.parse(value.eventStartTime!).toLocal();
      eventStartTime = d.toString();
      return d;
    });
    loadableEndTime = eventOnItsWay.then((value){
      DateTime d = DateTime.parse(value.eventEndTime!).toLocal();
      eventEndTime = d.toString();
      return d;
    });

  }
}