import 'package:InstiApp/src/api/model/venter.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:flutter/material.dart';

class ComplaintPage extends StatefulWidget {
  final Future<Complaint> _complaintFuture;

  ComplaintPage(this._complaintFuture);

  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  Complaint complaint;

  @override
  void initState() {
    complaint = null;
    super.initState();
    widget._complaintFuture.then((c) {
      setState(() {
        complaint = c;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context).bloc;
    var theme = Theme.of(context);

    var footerButtons = <Widget>[];

    return Container();
  }
}
