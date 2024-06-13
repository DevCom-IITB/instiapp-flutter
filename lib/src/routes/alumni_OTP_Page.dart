import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:flutter/material.dart';

class AlumniOTPPage extends StatefulWidget {
  const AlumniOTPPage({Key? key}) : super(key: key);

  @override
  _AlumniOTPPageState createState() => _AlumniOTPPageState();
}

class _AlumniOTPPageState extends State<AlumniOTPPage> {
  InstiAppBloc? _bloc;
  final _formKey = GlobalKey<FormState>();
  dynamic routedData = {};

  @override
  Widget build(BuildContext context) {
    routedData = ModalRoute.of(context)!.settings.arguments;
    // print(routedData);
    _bloc = BlocProvider.of(context)!.bloc;
    _bloc!.setAlumniID(routedData["ldap"]);
    // print(_bloc!.alumniID);

    return Scaffold(
      drawer: NavDrawer(),
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text('Alumni Login -OTP'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            TextFormField(
              validator: (valueEnt) {
                /*||_bloc!.alumniKey.length != _bloc!.alumniPassword.length*/

                if (valueEnt == null ||
                    valueEnt.isEmpty ||
                    _bloc!.alumniOTP.isEmpty) {
                  return "Please enter the correct OTP";
                }
                return null;
              },
              initialValue: "",
              decoration: InputDecoration(labelText: "Enter the OTP here."),
              onChanged: (value) => {
                setState(() {_bloc!.setAlumniOTP(value);})
              },
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              child: const Text('Verify OTP'),
              onPressed: () async {
                await _bloc!.logAlumniIn(false);

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(_bloc!.msg),
                ));

                if (_formKey.currentState!.validate() && _bloc!.isAlumni) {
                  // await _bloc!.reloadCurrentUser();
                  Navigator.pushNamedAndRemoveUntil(
                      context, _bloc!.homepageName, (r) => false);
                }

                // print(_bloc!.alumniOTP.length);
              },
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              child: const Text('Resend OTP'),
              onPressed: () async {
                await _bloc!.logAlumniIn(true);

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(_bloc!.msg),
                ));
              },
            ),
          ]),
        ),
      ),
    );
  }
}
