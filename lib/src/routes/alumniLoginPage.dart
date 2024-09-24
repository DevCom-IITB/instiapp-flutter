import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:flutter/material.dart';

class AlumniLoginPage extends StatefulWidget {
  const AlumniLoginPage({Key? key}) : super(key: key);

  @override
  _AlumniLoginPageState createState() => _AlumniLoginPageState();
}

class _AlumniLoginPageState extends State<AlumniLoginPage> {
  final _formKey = GlobalKey<FormState>();
  InstiAppBloc? _bloc;

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of(context)!.bloc;
    return Scaffold(
      drawer: NavDrawer(),
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text('Alumni Login'),
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
                if (valueEnt == null || valueEnt.isEmpty
                    // || !valueEnt.contains("@")
                    ) {
                  return "Please enter the correct LDAP";
                }
                return null;
              },
              initialValue: "",
              decoration: InputDecoration(labelText: "Enter your LDAP here."),
              onChanged: (value) => {
                setState(() {_bloc!.setAlumniID(value);})
              },
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              child: const Text('Send OTP'),
              onPressed: () async {
                await _bloc!.updateAlumni();

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(_bloc!.msg),
                ));

                if (_formKey.currentState!.validate() && _bloc!.isAlumni) {
                  Navigator.popAndPushNamed(context, '/alumni-OTP-Page',
                      arguments: {
                        "ldap": _bloc!.alumniID,
                        // "isAlumni": _bloc!.isAlumni,
                        // "msg": _bloc!.msg
                      });
                }

                // print(_bloc!.alumniID);
                // print(_bloc!.isAlumni);
              },
            ),
          ]),
        ),
      ),
    );
  }
}
