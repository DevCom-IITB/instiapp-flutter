
import 'package:flutter/material.dart';

class DatePickerField extends StatefulWidget {
  final String labelText;
  final Function onSaved;
  final Future<DateTime>? loadDate;
  DatePickerField({required this.labelText,this.loadDate, required this.onSaved});

  @override
  _DatePickerFieldState createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  _DatePickerFieldState();
  DateTime setDate = DateTime.now();
  DateTime initDate = DateTime.now();
  DateTime lastDate = DateTime.now();
  TextEditingController textEditingController = TextEditingController();
  Color labelColor = Colors.grey;
  static int zeroDateTime = -62170003800000000;
  static DateTime parseDate(String s){
    DateTime d = DateTime(0,0,0,0,0,0,0,0);
    try{d = DateTime.parse(s);}
    catch(e){return d;}
    return d;
  }
  static String formatDate(DateTime d) {
    return d.toString().split(' ')[0];
  }

  @override
  void initState() {
    if(widget.loadDate!=null){
      widget.loadDate!.then((value){
        setState(() {
          setDate = value;
        });
        textEditingController.text = formatDate(setDate);
      });
    }
    else{
      setDate = DateTime.now();
    }
    int yn = setDate.year;
    setState(() {
      initDate = DateTime.fromMillisecondsSinceEpoch(
          DateTime(yn - 1).millisecondsSinceEpoch);
      lastDate = DateTime.fromMillisecondsSinceEpoch(
          DateTime(yn + 1).millisecondsSinceEpoch);
      textEditingController.text = formatDate(setDate);
    });

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
          if(newDate.microsecondsSinceEpoch!=zeroDateTime&&(newDate.isBefore(lastDate)&&newDate.isAfter(initDate))){
            setState(() {labelColor = Colors.grey;});
          }
          else{
            setState(() {labelColor = Colors.red;});
          }
        },
        validator: (String? s){
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
                    textEditingController.text = formatDate(newDate);

                  });
                }
                newDate?.millisecond;
              },
            )
        ),
      ),
    );
  }
}

class TimePickerField extends StatefulWidget {
  final String labelText;
  final Function onSaved;
  final Future<DateTime>? loadTime;
  TimePickerField({required this.labelText, this.loadTime,required this.onSaved});

  @override
  _TimePickerFieldState createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<TimePickerField> {
  TimeOfDay setTime = TimeOfDay.now();
  DateTime initDate = DateTime.now();
  DateTime lastDate = DateTime.now();
  TextEditingController textEditingController = TextEditingController();
  Color labelColor = Colors.grey;
  static TimeOfDay parseTime(String s){
    TimeOfDay d = TimeOfDay(hour:0,minute: 0);
    try{d = TimeOfDay(hour: int.parse(s.split(':')[0]),minute: int.parse(s.split(':')[1]));}
    catch(e){return d;}
    return d;
  }
  String formatTime(TimeOfDay d) {
    final Function pad = (int s)=>(s.toString().length)>1?s.toString():'0'+s.toString();
    return '${pad(d.hour)}:${pad(d.minute)}';
  }

  @override
  void initState() {
    if(widget.loadTime!=null){
      widget.loadTime!.then((value){
        setState(() {
          setTime = TimeOfDay.fromDateTime(value);
        });
        textEditingController.text = formatTime(setTime);
      });
    }
    else{
      setTime = TimeOfDay.now();
    }
    textEditingController.text = formatTime(setTime);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: textEditingController,
        onChanged: (String s) {
          try{
            List<int> nums = s.split(':').map((e) => int.parse(e)).toList();
            if(nums[0]>=0&&nums[0]<24&&nums[1]>=0&&nums[1]<60){
              setState(() {
                labelColor = Colors.grey;
              });
            }
            else{
              setState(() {
                labelColor = Colors.red;
              });
            }
            return;
          }catch(e){
            setState(() {
              labelColor = Colors.red;
            });
          }
        },
        validator: (String? s){
          if(s!=null){
            // TimeOfDay newTime = parseTime(s);
            // if(newDate.microsecondsSinceEpoch==zeroDateTime){
            //   return 'Date Not Parsed. Format: DD/MM/YYYY';
            // }
            // else if(!(newDate.isBefore(lastDate)&&newDate.isAfter(initDate))){
            //   return 'Date must be within a year of today.';
            // }
          }
          return null;
        },
        onSaved: (String? dateStr){
          if(dateStr!=null){
            widget.onSaved(parseTime(dateStr));
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
                Icons.watch_later_outlined,
                color: Colors.grey,
              ),
              onPressed: () async {
                TimeOfDay? newTime = await showTimePicker(
                  context: context,
                  initialTime: setTime,

                );
                if (newTime != null) {
                  setState(() {
                    setTime = newTime;
                    // print(setTime);
                    widget.onSaved(newTime);
                    textEditingController.text = formatTime(newTime);
                  });
                }
                // showDateRangePicker()
              },
            )
        ),
      ),
    );
  }
}