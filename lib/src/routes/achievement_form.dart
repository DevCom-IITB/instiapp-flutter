import 'package:InstiApp/src/api/request/achievement_create_request.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/blocs/achievementform_bloc.dart';
import 'package:InstiApp/src/api/request/achievement_create_request.dart';
import 'package:InstiApp/src/api/model/event.dart';

import '../bloc_provider.dart';

class Home extends StatelessWidget{


  final TextEditingController _controller = new TextEditingController();
  var items = ['Working a lot harder', 'Being a lot smarter', 'Being a self-starter', 'Placed in charge of trading charter'];

  final titlecontroller= TextEditingController();
  @override


  @override
  Widget build(BuildContext context) {
    var bloca = BlocProvider.of(context).bloc;
    final bloc = bloca.achievementBloc;

    return Scaffold(
      appBar: AppBar(
        leading: Icon(
            Icons.menu
        ),
        title: Text('Achievements'),
        //centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Icon(

                Icons.qr_code
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Icon(

                Icons.notifications
            ),
          ),
        ],
      ),
      body: Column(

          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Container(
                margin: EdgeInsets.fromLTRB(15.0, 15.0, 10.0, 5.0),
                child: Text(
                  'Verification Request',
                  style: TextStyle( fontSize: 20),
                )

            ),
            StreamBuilder<String>(
              stream: bloc.title,
              builder: (context, snapshot) => Container(
                  margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                  child: TextField(
                    onChanged: bloc.titlechanged,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Title*',
                    ),
                    maxLength: 50,
                  )
              ),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                child: Text('Description',style: TextStyle( fontSize: 15))
            ),
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
                  )
              ),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                child: Text('Admin Note',style: TextStyle( fontSize: 15),)
            ),
            StreamBuilder<String>(
              stream: bloc.admin_note,
              builder: (context, snapshot) => Container(
                  margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                  child: TextField(
                    decoration: InputDecoration(

                    ),
                  )
              ),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Event(Optional)',
                  ),
                )
            ),
            Container(
                margin: EdgeInsets.fromLTRB(15.0, 1.0, 15.0, 5.0),
                child: Text('Search for an InstiApp event',style: TextStyle( fontSize: 12),)
            ),
            Container(
                margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Verifying Authority',
                  ),
                )
            ),
            Container(
                margin: EdgeInsets.fromLTRB(15.0, 1.0, 15.0, 5.0),
                child: Text('Enter an Organisations name',style: TextStyle( fontSize: 12),)
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 15.0),
              child: TextButton(
                onPressed: (){
                  AchievementCreateRequest req = AchievementCreateRequest();

                  bloc.postForm(req);
                },
                child: Text('Request Verification'),
                style: TextButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Colors.amber,
                    onSurface: Colors.grey,
                    elevation: 5.0
                ),

              ),
            ),

          ]
      ),

      // body: Padding(
      //   padding: EdgeInsets.all(50.0),
      //   color: Colors.amber
      //
      // ),
      // body: Container(
      //   padding: EdgeInsets.symmetric(
      //     vertical: 50.0,
      //     horizontal: 50.0
      //   ),
      //    margin: Edge..
      //   child: Text('kk'),
      //   color: Colors.amber,
      // )
      // body: Center(
      //     child: ElevatedButton.icon(
      //         onPressed: (){
      //           print('pressed');
      //         },
      //         icon: Icon(
      //           Icons.mail
      //         ),
      //         label: Text('mail me'),
      //         //backgroundColor: Colors.amber,
      //
      //     )
      // ),
      // floatingActionButton: FloatingActionButton(
      //     onPressed: (){},
      //     child: Text('aa')
      // ),
    );
  }
}
