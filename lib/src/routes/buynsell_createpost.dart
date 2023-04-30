import 'dart:io';

import 'package:InstiApp/src/api/model/buynsellPost.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/response/image_upload_response.dart';
import 'package:InstiApp/src/routes/buynsell_categories.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';

import '../bloc_provider.dart';
import '../blocs/buynsell_post_block.dart';

class NavigateArguments {
  final BuynSellPost? post;

  NavigateArguments({this.post});
}

class BuyAndSellForm extends StatefulWidget {
  _BuyAndSellFormState createState() => _BuyAndSellFormState();
}

class _BuyAndSellFormState extends State<BuyAndSellForm> {
  BuynSellPost bnsPost = BuynSellPost();

  bool _withinWarranty = false;
  bool _originalPackaging = false;
  ActionChoices? _option;

  bool _itemStatus = true;

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  BuynSellPost currRequest = BuynSellPost();

  File? _imageFile;

  List<ActionChoices> actionChoices = [
    ActionChoices(value: "sell", text: "Sell"),
    ActionChoices(value: "giveaway", text: "Give Away")
  ];

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
  void initState() {
    super.initState();
    _option = actionChoices[0];
    bnsPost.action = _option!.value;
    bnsPost.warranty = false;
    bnsPost.negotiable = false;
    bnsPost.packaging = false;
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context)!.bloc;
    User? profile = bloc.currSession?.profile;

    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
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
                            padding: EdgeInsets.fromLTRB(0, 4, 15.0, 2),
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed("/buyandsell/category");
                              },
                              child: Icon(Icons.arrow_back_ios_outlined,
                                  color: Colors.black),
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
                                  DropdownButtonFormField<ActionChoices>(
                                    value: _option,
                                    onChanged: (value) {
                                      setState(() {
                                        _option = value!;
                                        print(value.value);
                                        bnsPost.action = value.value;
                                      });
                                    },
                                    items: actionChoices
                                        .map<DropdownMenuItem<ActionChoices>>(
                                            (ActionChoices value) {
                                      return DropdownMenuItem<ActionChoices>(
                                        value: value,
                                        child: Text(value.text),
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
                                    onChanged: (value) {
                                      bnsPost.name = value;
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
                                    onChanged: (value) {
                                      bnsPost.price = int.tryParse(value);
                                    },
                                    keyboardType: TextInputType.number,
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(
                                          flex: 1, child: SizedBox()),
                                      const Text('Negotiable'),
                                      Radio<bool>(
                                        value: true,
                                        groupValue: bnsPost.negotiable,
                                        onChanged: (value) {
                                          setState(() {
                                            print(value);
                                            bnsPost.negotiable = value;
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
                                        groupValue: bnsPost.negotiable,
                                        onChanged: (value) {
                                          setState(() {
                                            print(value);
                                            bnsPost.negotiable = value;
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
                                    onChanged: (value) {
                                      bnsPost.description = value;
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
                                        hintText: 'Enter brand name',
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 1, horizontal: 10),
                                        border: OutlineInputBorder()),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter Brand name';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      bnsPost.brand = value;
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
                                        groupValue: bnsPost.warranty,
                                        onChanged: (value) {
                                          setState(() {
                                            bnsPost.warranty = value;
                                          });
                                        },
                                      ),
                                      const Text('No'),
                                      Radio<bool>(
                                        value: false,
                                        groupValue: bnsPost.warranty,
                                        onChanged: (value) {
                                          setState(() {
                                            bnsPost.warranty = value;
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
                                        groupValue: bnsPost.packaging,
                                        onChanged: (value) {
                                          setState(() {
                                            bnsPost.packaging = value;
                                          });
                                        },
                                      ),
                                      const Text('No'),
                                      Radio<bool>(
                                        value: false,
                                        groupValue: bnsPost.packaging,
                                        onChanged: (value) {
                                          setState(() {
                                            bnsPost.packaging = value;
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
                              flex: 8,
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
                                      if (value == null ||
                                          value.isEmpty ||
                                          (int.tryParse(value) ?? -1) > 10 ||
                                          (int.tryParse(value) ?? -1) < 0) {
                                        return 'Please enter rating from 0-10';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      bnsPost.condition = value;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            // const Expanded(
                            //   flex: 4,
                            //   child: SizedBox(),
                            // ),
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
                                    onChanged: (value) {
                                      bnsPost.contactDetails = value;
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
                        // child: Row(
                        //   children: [
                        //     const Expanded(
                        //       flex: 2,
                        //       child: Text(
                        //         'Status',
                        //         style: TextStyle(
                        //           fontWeight: FontWeight.bold,
                        //           fontSize: 16.0,
                        //         ),
                        //       ),
                        //     ),
                        //     Expanded(
                        //       flex: 4,
                        //       child: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Row(
                        //             children: [
                        //               const Text('Open'),
                        //               Radio<bool>(
                        //                 value: true,
                        //                 groupValue: _itemStatus,
                        //                 onChanged: (value) {
                        //                   setState(() {
                        //                     bnsPost.status = value;
                        //                   });
                        //                 },
                        //               ),
                        //               const Text('Closed'),
                        //               Radio<bool>(
                        //                 value: false,
                        //                 groupValue: _itemStatus,
                        //                 onChanged: (value) {
                        //                   setState(() {
                        //                     bnsPost.status = value;
                        //                   });
                        //                 },
                        //               ),
                        //               // const Text('No'),
                        //             ],
                        //           )
                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        // ),
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
                                              onPressed: () => _pickImage(
                                                  ImageSource.camera),
                                              child: const Icon(Icons.camera)),
                                          const SizedBox(width: 16),
                                          ElevatedButton(
                                              onPressed: () => _pickImage(
                                                  ImageSource.gallery),
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
                            onPressed: () async {
                              bnsPost.user = profile;
                              if (_formKey.currentState!.validate()) {
                                if (_imageFile != null) {
                                  ImageUploadResponse resp = await bloc.client
                                      .uploadImage(bloc.getSessionIdHeader(),
                                          _imageFile!);
                                  bnsPost.imageUrl = resp.pictureURL;
                                }

                                bloc.buynSellPostBloc
                                    .createBuynSellPost(bnsPost);
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

  void _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pi = await _picker.pickImage(source: source);

    if (pi != null) {
      // ImageUploadResponse resp = await bloc.client
      //     .uploadImage(
      //         bloc.getSessionIdHeader(), File(pi.path));
      // print(resp.pictureURL);
      if (await pi.length() / 1000000 <= 10) {
        setState(() {
          _imageFile = File(pi.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Image size should be less than 10MB"),
        ));
      }
    }
  }

  Widget _buildImageUrl(String url, int index) {
    return Stack(
      children: [
        Image.network(
          url,
          height: MediaQuery.of(context).size.height / 7.5,
          width: MediaQuery.of(context).size.height / 7.5,
          fit: BoxFit.scaleDown,
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  currRequest.imageUrl!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageFile(File file, int index) {
    return Stack(
      children: [
        Image.file(
          file,
          height: MediaQuery.of(context).size.height / 7.5,
          width: MediaQuery.of(context).size.height / 7.5,
          fit: BoxFit.scaleDown,
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  //imageFile.remove;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ActionChoices {
  String value;
  String text;

  ActionChoices({required this.value, required this.text});
}
