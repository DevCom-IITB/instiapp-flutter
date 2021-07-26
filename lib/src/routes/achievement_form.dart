import 'package:InstiApp/src/api/apiclient.dart';
import 'package:InstiApp/src/api/request/achievement_create_request.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/blocs/achievementform_bloc.dart';
import 'package:InstiApp/src/api/request/achievement_create_request.dart';
import 'package:InstiApp/src/api/model/event.dart';

import '../bloc_provider.dart';

class Home extends StatefulWidget {
  Form createState() => Form();
}


class Verify {
  String club = '';
  String description = '';
  String image = 'devcom.png';

  Verify({String club = '', String description = '', String image = ''}) {
    this.club = club;
    this.description = description;
    this.image = image;
  }

  static List<Verify> getverauth() {
    return <Verify>[
      Verify(
          club: 'InstiApp',
          description: 'The one platform of IIT Bombay',
          image: 'Assets/instiapp.png'),
      Verify(
          club: 'sa',
          description: 'The asa platform of IIT Bombay',
          image: 'Assets/instiapp.png')
    ];
  }
}



class Form extends State<Home> {
  int number = 0;
  bool selected=false;
  List<Verify> _companies = Verify.getverauth();
  List<DropdownMenuItem<Verify>> _dropdownMenuItems;
  Verify _selectedCompany =
  Verify(club: 'ff', description: 'ff', image: 'Assets/instiapp.png');

  @override
  void initState() {
    _dropdownMenuItems = buildDropdownMenuItems(_companies);
  }

  List<DropdownMenuItem<Verify>> buildDropdownMenuItems(List companies) {
    List<DropdownMenuItem<Verify>> items = [];
    for (Verify company in companies) {
      items.add(
        DropdownMenuItem(
          value: company,
          child: Text(company.club),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    var bloca = BlocProvider.of(context).bloc;
    final bloc = bloca.achievementBloc;

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.menu),
        title: Text('Achievements'),
        //centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Icon(Icons.qr_code),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Icon(Icons.notifications),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(15.0, 15.0, 10.0, 5.0),
                  child: Text(
                    'Verification Request',
                    style: TextStyle(fontSize: 20),
                  )),
      StreamBuilder<String>(
            stream: bloc.title,
            builder: (context, snapshot) => Container(
                    margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                    child: TextField(
                      onChanged: bloc.titlechanged,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        hintText: 'Title*',
                      ),
                      maxLength: 50,
                    )),
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                  child: Text('Description', style: TextStyle(fontSize: 15))),
              StreamBuilder<String>(
                stream: bloc.description,
                builder: (context, snapshot) => Container(
                    margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                    child: TextField(
                      onChanged: bloc.descchanged,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        //errorText: snapshot.error
                      ),
                    )),
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                  child: Text(
                    'Admin Note',
                    style: TextStyle(fontSize: 15),
                  )),
              StreamBuilder<String>(
                stream: bloc.admin_note,
                builder: (context, snapshot) => Container(
                    margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                    child: TextField(
                      onChanged: bloc.adminchanged,
                      decoration: InputDecoration(),
                    )),
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 20.0,
                        ),
                        DropdownButtonFormField(
                            hint: Text("Event(Optional)"),
                            items: _dropdownMenuItems,
                            onChanged: (Verify selectedCompany) {
                              setState(() {
                                selected=true;
                                _selectedCompany = selectedCompany;

                              });
                            }),
                        SizedBox(
                          height: 20.0,
                        ),
                        verify_card(thing: this._selectedCompany, selected: this.selected),
                      ])),
              Container(
                  margin: EdgeInsets.fromLTRB(15.0, 1.0, 15.0, 5.0),
                  child: Text(
                    "Search for an InstiApp event",
                    style: TextStyle(fontSize: 12),
                  )),
              Container(
                  margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Verifying Authority',
                    ),
                  )),
              Container(
                  margin: EdgeInsets.fromLTRB(15.0, 1.0, 15.0, 5.0),
                  child: Text(
                    'Enter an Organisations name',
                    style: TextStyle(fontSize: 12),
                  )),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: Text('Request Verification'),
                  style: TextButton.styleFrom(
                      primary: Colors.black,
                      backgroundColor: Colors.amber,
                      onSurface: Colors.grey,
                      elevation: 5.0),
                ),
              ),
            ]),
      )
    );

  }
}
class verify_card extends StatefulWidget {
  final Verify thing;
  final bool selected;

  verify_card({this.thing, this.selected});

  card createState() => card();
}

class card extends State<verify_card> {


  Widget build(BuildContext context) {
    if(widget.selected){
      return Card(
          elevation: 0.0,
          color: Colors.transparent,
          margin: EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('${widget.thing.image}'),
                radius: 20.0,
              ),
              SizedBox(width: 15.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.thing.club}',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 3.0),
                  Text(
                    '${widget.thing.description}',
                    style: TextStyle(fontSize: 15.0, color: Colors.grey[500]),
                  )
                ],
              )
            ],
          ));
    }
    else{
      return SizedBox(height: 10);
    }
  }

}


    //     StreamBuilder<String>(
    //     stream: bloc.description,
    //     builder: (context, snapshot) => Container(
    //     margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
    //     child: TextField(
    //       onChanged: bloc.descchanged,
    //       keyboardType: TextInputType.text,
    //       decoration: InputDecoration(
    //         //errorText: snapshot.error
    //       ),
    //     )
    // ),
    // ),