import 'dart:async';
// import 'dart:html';

import 'package:InstiApp/src/utils/common_widgets.dart';
// import 'package:InstiApp/src/utils/safe_webview_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
    return ElevatedButton(
      onPressed: (){},
      child: Text('Create'),
      style: ButtonStyle(

        // minimumSize: MaterialStateProperty.all(Size.fromWidth(double.infinity))
      ),
    );
  }
}
class DatePickerField extends StatefulWidget {
  const DatePickerField({Key? key}) : super(key: key);

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
  static String formatDate(DateTime d){
    String s = "";
    Function pad = (String s)=>s.length==1?'0'+s:s;
    s = [pad(d.day.toString()),pad(d.month.toString()),pad(d.year.toString())].join('/');
    return s;
  }
  @override
  void initState() {
    int yn = setDate.year;
    setState(() {
      initDate = DateTime.fromMillisecondsSinceEpoch(DateTime(yn-1).millisecondsSinceEpoch);
      lastDate = DateTime.fromMillisecondsSinceEpoch(DateTime(yn+1).millisecondsSinceEpoch);
      formattedDate = formatDate(setDate);
      textEditingController.text = formattedDate;
    });
    setDate = DateTime.now();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          Container(
            width: 200,
            child: TextField(
              controller: textEditingController,
              onChanged: (String s){
                try{
                  //TODO:check parseability of s
                }
                catch(e){}
              },
              decoration: InputDecoration(
                label: Text(
                  'From *',
                  style: TextStyle(
                    color: parseable?Colors.grey:Colors.red
                  ),
                ),
                suffix: TextButton(
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.grey,
                  ),
                  onPressed: ()async{
                    DateTime? newDate = await showDatePicker(
                      firstDate: initDate,
                      lastDate: lastDate,
                      initialDate: setDate
                      context: context,

                    );
                    if(newDate!=null){
                      setState(() {
                        setDate = newDate;
                        formattedDate = formatDate(setDate);
                        textEditingController.text = formattedDate;
                      });
                    }
                    newDate?.millisecond;
                    // showDateRangePicker()
                  },
                )
              ),
            ),
          ),
          // TextButton(
          //   child: Icon(Icons.calendar_today),
          //   onPressed: ()async{
          //     DateTime? newDate = await showDatePicker(
          //       firstDate: initDate,
          //       lastDate: lastDate,
          //       initialDate: setDate
          //       context: context,
          //
          //     );
          //     if(newDate!=null){
          //       setState(() {
          //         setDate = newDate;
          //         formattedDate = formatDate(setDate);
          //
          //       });
          //     }
          //     newDate?.millisecond;
          //     // showDateRangePicker()
          //   },
          // )
        ],
    );
  }
}

class _PutEntityPageState extends State<PutEntityPage> {

  final String hostUrl = "https://insti.app/";
  final String addEventStr = "add-event";
  final String editEventStr = "edit-event";
  final String editBodyStr = "edit-body";
  final String loginStr = "login";
  final String sandboxTrueQParam = "sandbox=true";

  bool firstBuild = true;
  bool addedCookie = false;
  List<Map<String,Object>> bodies = [
    {'body':'Devcom','use':false},
    {'body':'Dead','use':false}];
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
            ),
            Row(
              children: [
                Expanded(child: DatePickerField())
              ],
            ),
            Row(
              children: [],
            ),
            TextField(
              decoration: InputDecoration(
                label: Text('Venue'),
                suffixIcon: Icon(Icons.add),
              ),
            ),
            DropdownButton<bool>(
              hint: Text('Bodies'),
              items: bodies.map((Map<String,Object> value){
                return DropdownMenuItem<bool>(
                  value: value['use']==true?true:false,
                  child: Row(
                    children: [
                      Checkbox(
                        value: value['use']==true?true:false,
                        onChanged: (bool? v){
                          setState(() {
                            bodies.firstWhere((element){
                              return element['body']==value['body'];
                            })['use'] = !v!;
                          });
                          //TODO:implement body list
                        },
                      ),
                      Text('Body 1')
                    ],
                  ),
                );
              }).toList(),
              onChanged: (_) {},
            ),
            GestureDetector(
              onTap: (){
                //value = !=value
              },
              child: Row(
                children: [
                  Switch(
                    value: true,
                    onChanged: (v){},
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
