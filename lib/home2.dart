import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resolute_project_01/call/outgoing_call.dart';
import 'package:resolute_project_01/select_photo_options_screen.dart';
import 'package:resolute_project_01/utils/internet_check.dart';
import 'package:resolute_project_01/utils/my_fcm.dart';
import 'package:resolute_project_01/utils/no_internet.dart';
import 'package:resolute_project_01/utils/services/call_details.dart';
import 'package:resolute_project_01/utils/services/global.dart';
import 'package:resolute_project_01/utils/sharedPref.dart';
import 'package:resolute_project_01/utils/toast.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:uuid/uuid.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;

class StorageService {
  static Future<String?> uploadFile(String path, File file) async {
    try {
      firebase_storage.Reference storageReference =
          firebase_storage.FirebaseStorage.instance.ref(path);
      await storageReference.putFile(file);

      String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      return null;
    }
  }
}

class _HomeState extends State<Home> {
  String acType = "", myDpLink = "", myNumber = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  int _selectedPageIndex = 0;
  PageController pageController = PageController(initialPage: 0);

  bool editData = false, _onlineImage = true;

  TextEditingController emailTC = TextEditingController(),
      userNameTC = TextEditingController(),
      phoneNumberTC = TextEditingController();

  File? _image;

  late DatabaseReference databaseReference;
  late Query databaseReferenceQuery;

  // final databaseReference = FirebaseDatabase.instance.reference();

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      File? img = File(image.path);
      img = await _cropImage(imageFile: img);
      setState(() {
        _image = img;
        _onlineImage = false;
        Navigator.of(context).pop();
      });
      _updateProfileImg();
    } on PlatformException catch (e) {
      _onlineImage = true;
      Navigator.of(context).pop();
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      // maxWidth: 1080, // Todo: Set max image width
      // maxHeight: 1080, // Todo: Set max image height
      aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    );
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  void _showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.deepPurpleAccent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.28,
          maxChildSize: 0.4,
          minChildSize: 0.28,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SelectPhotoOptionsScreen(
                onTap: _pickImage,
              ),
            );
          }),
    );
  }

  Future<void> _updateProfileImg() async {
    // check internet connection...
    bool checkMyInternet = await checkInternet();
    if (checkMyInternet == false) {
      if (context.mounted) {
        failureToast(" 😭  😭 ", "No Internet Connection.", context);
        Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => const NoInternetConnScreen()),
        );
      }
      if (context.mounted) Navigator.of(context).pop();
      return;
    }

    if (!_onlineImage || _image != null) {
      String? imgUrl = await StorageService.uploadFile(
          "profile/${phoneNumberTC.text}", _image!);

      databaseReference.child("userData/${user!.phoneNumber}").update({
        "dp": imgUrl,
      }).asStream();
    } else {
      setState(() {
        // _numberCheck = false;
      });
    }
  }

  Widget listItem({required String key, required String value}) {
    timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    if ((int.parse(timestamp) < (int.parse(value) + (1000 * 10))) &&
        myNumber != key) {
      //   if (int.parse(timestamp)+10 >0) {
      return Card(
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          height: 110,
          color: Colors.black12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                key,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => UpdateRecord(studentKey: student['key'])));
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.call,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  GestureDetector(
                    onTap: () async {
                      // reference.child(student['key']).remove();
                      String receiverTo = "";
                      String receiverFrom = "";
                      String nameTo = "";
                      String nameFrom = "";
                      String imgTo = "";
                      String imgFrom = "";

                      String numberTo = key.toString();
                      String numberFrom = user!.phoneNumber.toString();

                      String thisTime = DateTime.now().millisecondsSinceEpoch.toString();

                      var uuid = const Uuid();
                      String roomKey = "$thisTime/${uuid.v4()}";

                      databaseReference.child("videoCall/$roomKey").update({
                        "connecting": thisTime,
                        "sender": numberFrom,
                        "receiver": numberTo,
                        "roomId": "0",
                        "end": "0",
                        "receive": "0",
                        "status": "creating",
                      }).asStream();

                      databaseReference
                          .child("userData/$key/fcmToken")
                          .onValue
                          .listen((DatabaseEvent event) async {
                        receiverTo = event.snapshot.value.toString();
                        databaseReference
                            .child("userData/$key/dp")
                            .onValue
                            .listen((DatabaseEvent event) async {
                          imgTo = event.snapshot.value.toString();
                          databaseReference
                              .child("userData/$key/name")
                              .onValue
                              .listen((DatabaseEvent event) async {
                            nameTo = event.snapshot.value.toString();
                            databaseReference
                                .child("userData/${user!.phoneNumber.toString()}/fcmToken")
                                .onValue
                                .listen((DatabaseEvent event) async {
                              receiverFrom = event.snapshot.value.toString();
                              databaseReference
                                  .child("userData/${user!.phoneNumber.toString()}/dp")
                                  .onValue
                                  .listen((DatabaseEvent event) async {
                                imgFrom = event.snapshot.value.toString();
                                databaseReference
                                    .child("userData/${user!.phoneNumber.toString()}/name")
                                    .onValue
                                    .listen((DatabaseEvent event) async {
                                  nameFrom = event.snapshot.value.toString();

                                  final data = {
                                    "roomKey": roomKey,
                                    "type": "vc",
                                    "fcmFrom": receiverFrom,
                                    "fcmTo": receiverTo,

                                    "nameTo": nameTo,
                                    "nameFrom": nameFrom,

                                    "imgTo": imgTo,
                                    "imgFrom": imgFrom,

                                    "numberTo": numberTo,
                                    "numberFrom": numberFrom,
                                  };
                                  MyFCM.sendNotification(receiverTo, data);

                                  VC.data = data;
                                  VC.ringing = false;
                                  VC.pickup = false;

                                  Navigator.push(
                                    GlobalVariable.navState.currentContext!,
                                    MaterialPageRoute(
                                        builder: (context) => const OutgoingCall()),
                                  );


                                });
                              });
                            });
                          });
                        });
                      });

                    },
                    child: Row(
                      children: const [
                        Icon(
                          Icons.video_call,
                          color: Colors.green,
                          size: 30.0,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }

    return const SizedBox(
      height: 0,
    );
  }

  @override
  void initState() {
    // checkUser();
    databaseReference = FirebaseDatabase.instance.reference();
    databaseReferenceQuery =
        FirebaseDatabase.instance.ref().child("OnlineCheck");
    checkUser();

    onlineCheck();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double widthThis = MediaQuery.of(context).size.width;
    double heightThis = MediaQuery.of(context).size.height;

    double heightTopThis = MediaQuery.of(context).padding.top;
    double heightBottomThis = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
            width: widthThis,
            height: heightThis - heightTopThis - heightBottomThis,
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedPageIndex = index;
                });
              },
              // physics: const NeverScrollableScrollPhysics(),
              children: [
                SingleChildScrollView(
                  child: SizedBox(
                    width: widthThis,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 100,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (editData) {
                              _showSelectPhotoOptions(context);
                            }
                          },
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration:
                                const ShapeDecoration(shape: CircleBorder()),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundImage: CachedNetworkImageProvider(
                                myDpLink.isNotEmpty
                                    ? myDpLink
                                    : "https://dp.sayantankar.com",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          leading: const Icon(Icons.email),
                          title: const Text("Email"),
                          subtitle: TextFormField(
                            enabled: editData,
                            controller: emailTC,
                            keyboardType: TextInputType.emailAddress,
                            maxLines: 1,
                            textAlign: TextAlign.left,
                            maxLength: 1000,
                          ),
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          leading: const Icon(Icons.person),
                          title: const Text("Name"),
                          subtitle: TextFormField(
                            enabled: editData,
                            controller: userNameTC,
                            keyboardType: TextInputType.name,
                            maxLines: 1,
                            textAlign: TextAlign.left,
                            maxLength: 1000,
                          ),
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          leading: const Icon(Icons.phone_android),
                          title: const Text("Phone Number"),
                          subtitle: TextFormField(
                            enabled: false,
                            controller: phoneNumberTC,
                            keyboardType: TextInputType.url,
                            maxLines: 1,
                            textAlign: TextAlign.left,
                            maxLength: 1000,
                          ),
                        ),
                        editData
                            ? GestureDetector(
                                onTap: () async {
                                  bool isValid = EmailValidator.validate(
                                      emailTC.text.toString().trim());
                                  if (isValid) {
                                    if (userNameTC.text
                                            .toString()
                                            .trim()
                                            .length >
                                        3) {
                                      if (user != null) {
                                        user!.updateDisplayName(
                                            userNameTC.text.toString().trim());
                                        await Future.delayed(
                                            const Duration(seconds: 2));
                                        user!.updateEmail(
                                            emailTC.text.toString().trim());

                                        databaseReference
                                            .child(
                                                "userData/${user!.phoneNumber}")
                                            .update({
                                          "email":
                                              emailTC.text.toString().trim(),
                                          "name":
                                              userNameTC.text.toString().trim(),
                                        }).asStream();

                                        editData = false;
                                        successToast(
                                            "Success", "Updated", context);
                                        setState(() {});
                                      }
                                    } else {
                                      warningToast(
                                          "Name error",
                                          "Length must be minimum 3 char",
                                          context);
                                    }
                                  } else {
                                    warningToast("Email error",
                                        "Email is not valid type", context);
                                  }
                                },
                                child: Container(
                                  color: const Color(0xFF2E3B62),
                                  width: widthThis - 100,
                                  height: 70,
                                  child: const Center(
                                    child: Text(
                                      "UPDATE",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    editData = true;
                                  });
                                },
                                child: Container(
                                  color: const Color(0xFF2E3B62),
                                  width: widthThis - 100,
                                  height: 70,
                                  child: const Center(
                                    child: Text(
                                      "EDIT",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  child: FirebaseAnimatedList(
                    query: databaseReferenceQuery,
                    itemBuilder: (BuildContext context, DataSnapshot snapshot,
                        Animation<double> animation, int index) {
                      return listItem(
                        key: snapshot.key.toString(),
                        value: snapshot.value.toString(),
                      );
                    },
                  ),
                ),
              ],
            )),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF5036D5),
        shape: const CircularNotchedRectangle(),
        notchMargin: 0.01,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: kBottomNavigationBarHeight * 1.08,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF5036D5),
              border: Border(
                top: BorderSide(
                  color: Colors.grey,
                  width: 0.7,
                ),
              ),
            ),
            child: BottomNavigationBar(
              onTap: (index) {
                pageController.animateToPage(index,
                    duration: const Duration(microseconds: 500),
                    curve: Curves.ease);
                setState(() {
                  _selectedPageIndex = index;
                });
              },
              backgroundColor: const Color(0xFF5036D5),
              unselectedItemColor: Colors.green,
              selectedItemColor: Colors.purple,
              currentIndex: _selectedPageIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: ('Profile'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.call),
                  label: ('Call'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> checkUser() async {
    databaseReference = FirebaseDatabase.instance.reference();

    acType = await readText("ac_type");
      user = FirebaseAuth.instance.currentUser;
      if (user != null) {


        setState(() {
          phoneNumberTC.text = user!.phoneNumber.toString();
          myNumber = phoneNumberTC.text;
          databaseReference
              .child("userData/${user!.phoneNumber}/name")
              .onValue
              .listen((DatabaseEvent event) {
            userNameTC.text = event.snapshot.value.toString();
          });

          databaseReference
              .child("userData/${user!.phoneNumber}/email")
              .onValue
              .listen((DatabaseEvent event) {
            emailTC.text = event.snapshot.value.toString();
          });

          databaseReference
              .child("userData/${user!.phoneNumber}/dp")
              .onValue
              .listen((DatabaseEvent event) {
            myDpLink = event.snapshot.value.toString();
          });
          FirebaseMessaging.instance.getToken().then((value) {
            databaseReference.child("userData/${user!.phoneNumber}").update({
              "fcmToken": value,
            }).asStream();
          });
        });
      }
  }

  String timestamp = "";

  Future<void> onlineCheck() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        myNumber = user!.phoneNumber.toString();
      });
      while (true) {
        timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        databaseReference
            .child("OnlineCheck")
            .update({user!.phoneNumber.toString(): timestamp}).asStream();

        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }


}
