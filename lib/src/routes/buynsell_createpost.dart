import 'dart:io';
import 'package:InstiApp/src/routes/buynsell_categories.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';

class BuyAndSellForm extends StatefulWidget {
  BuyAndSellForm({Key? key}) : super(key: key);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  _BuyAndSellFormState createState() => _BuyAndSellFormState();
}

class _BuyAndSellFormState extends State<BuyAndSellForm> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late String _itemName;
  late String _description;
  late String _price;
  late String _rating;
  bool _isNegotiable = false;
  bool _withinWarranty = false;
  bool _originalPackaging = false;
  String? _option;
  late String _brandName;
  bool _itemStatus = true;
  late String _contactDetails;

  final picker = ImagePicker();
  File? _imageFile;

  Future<void> _takePicture() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _selectFile() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Widget _buildPreview() {
    if (_imageFile == null) {
      return Container();
    }
    return Image.file(
      _imageFile!,
      height: 200,
      width: 140,
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    print("create posts");
    print(args.title);
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      bottomNavigationBar: MyBottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.menu_outlined,
                semanticLabel: "Show navigation drawer",
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 10, 0, 30),
                        child: Container(
                            padding: EdgeInsets.fromLTRB(10.0, 4, 15.0, 2),
                            child: FloatingActionButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed("/buyandsell/category");
                              },
                              child: Icon(Icons.arrow_back_ios_outlined,
                                  color: Colors.black),
                              backgroundColor: Colors.white,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 16.0),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 3,
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
                                child: Text(
                                  'Choose the action you want to take*',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ),
                            const Expanded(flex: 1, child: SizedBox()),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: _option,
                                    onChanged: (value) {
                                      setState(() {
                                        _option = value!;
                                      });
                                    },
                                    items: <String>['Sell', 'Giveaway']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    decoration: const InputDecoration(
                                      labelText: "Sell/Giveaway",
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 1, horizontal: 10),
                                    ),
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Please select an option';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(flex: 1, child: SizedBox()),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                'Name of the item*',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        hintText: 'Enter item name',
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 1, horizontal: 10),
                                        border: OutlineInputBorder()),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter item name';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _itemName = value!;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                'Price of the item*',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        hintText: 'Enter Price',
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 1, horizontal: 10),
                                        border: OutlineInputBorder()),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter Price';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _price = value!;
                                    },
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(
                                          flex: 1, child: SizedBox()),
                                      const Text('Negotiable'),
                                      Radio<bool>(
                                        value: true,
                                        groupValue: _isNegotiable,
                                        onChanged: (value) {
                                          setState(() {
                                            _isNegotiable = value!;
                                          });
                                        },
                                      ),
                                      const Expanded(
                                          flex: 1, child: SizedBox()),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(
                                          flex: 1, child: SizedBox()),
                                      const Text('Non-Negotiable'),
                                      Radio<bool>(
                                        value: false,
                                        groupValue: _isNegotiable,
                                        onChanged: (value) {
                                          setState(() {
                                            _isNegotiable = value!;
                                          });
                                        },
                                      ),
                                      const Expanded(
                                          flex: 1, child: SizedBox()),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                'Description*',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        hintText: 'Enter item name',
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 30, horizontal: 10),
                                        border: OutlineInputBorder()),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter item name';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _description = value!;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                'Brand Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        hintText: 'Enter item name',
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 1, horizontal: 10),
                                        border: OutlineInputBorder()),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter Brand name';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _brandName = value!;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                'Within the Warranty?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('Yes'),
                                      Radio<bool>(
                                        value: true,
                                        groupValue: _withinWarranty,
                                        onChanged: (value) {
                                          setState(() {
                                            _withinWarranty = value!;
                                          });
                                        },
                                      ),
                                      const Text('No'),
                                      Radio<bool>(
                                        value: false,
                                        groupValue: _withinWarranty,
                                        onChanged: (value) {
                                          setState(() {
                                            _withinWarranty = value!;
                                          });
                                        },
                                      ),
                                      // const Text('No'),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                'Original Packaging?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('Yes'),
                                      Radio<bool>(
                                        value: true,
                                        groupValue: _originalPackaging,
                                        onChanged: (value) {
                                          setState(() {
                                            _originalPackaging = value!;
                                          });
                                        },
                                      ),
                                      const Text('No'),
                                      Radio<bool>(
                                        value: false,
                                        groupValue: _originalPackaging,
                                        onChanged: (value) {
                                          setState(() {
                                            _originalPackaging = value!;
                                          });
                                        },
                                      ),
                                      // const Text('No'),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 4.0, 16.0),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 4,
                              child: Text(
                                'Condition of the item',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        hintText: 'Rating/10.',
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 1, horizontal: 10),
                                        border: OutlineInputBorder()),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter Brand name';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _rating = value!;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              flex: 4,
                              child: SizedBox(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                'Contact Details*',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        hintText:
                                            'Enter contact no. / address, etc',
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 10),
                                        border: OutlineInputBorder()),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter item name';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _contactDetails = value!;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                'Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('Open'),
                                      Radio<bool>(
                                        value: true,
                                        groupValue: _itemStatus,
                                        onChanged: (value) {
                                          setState(() {
                                            _itemStatus = value!;
                                          });
                                        },
                                      ),
                                      const Text('Closed'),
                                      Radio<bool>(
                                        value: false,
                                        groupValue: _itemStatus,
                                        onChanged: (value) {
                                          setState(() {
                                            _itemStatus = value!;
                                          });
                                        },
                                      ),
                                      // const Text('No'),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 3,
                              child: Text(
                                'Attach Image*',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            const Expanded(flex: 1, child: SizedBox()),
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          ElevatedButton(
                                              onPressed: _takePicture,
                                              child: const Icon(Icons.camera)),
                                          const SizedBox(width: 16),
                                          ElevatedButton(
                                              onPressed: _selectFile,
                                              child: const Icon(
                                                  Icons.attach_file)),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                                      _buildPreview(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(flex: 1, child: SizedBox())
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            child: const DefaultTextStyle(
                              style: TextStyle(color: Colors.blue),
                              child: Text('Cancel'),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                              }
                            },
                            child: const Text('Submit'),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
