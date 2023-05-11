import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:resolute_project_01/home2.dart';
import 'package:resolute_project_01/utils/internet_check.dart';
import 'package:resolute_project_01/utils/no_internet.dart';
import 'package:resolute_project_01/utils/toast.dart';

class MobileNumber extends StatefulWidget {
  const MobileNumber({Key? key}) : super(key: key);

  @override
  State<MobileNumber> createState() => _MobileNumberState();
}

class _MobileNumberState extends State<MobileNumber> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController controller = TextEditingController();
  String phoneNumber = '';
  PhoneNumber number = PhoneNumber(isoCode: 'IN');

  @override
  Widget build(BuildContext context) {
    double widthThis = MediaQuery.of(context).size.width;
    double heightThis = MediaQuery.of(context).size.height;

    double heightTopThis = MediaQuery.of(context).padding.top;
    double heightBottomThis = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children:  <Widget>[
                SizedBox(
                  height: heightThis - heightTopThis - heightBottomThis - 216,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          GestureDetector(
                            onTap: (){
                              Navigator.of(context).pop();
                            },
                            child: const Icon(
                              Icons.close,
                              size: 30,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      SvgPicture.asset(
                        width: 56,
                        height: 56,
                        "assets/svg/img.svg",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Please enter your mobile number",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "You’ll receive a 6 digit code\nto verify next..",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: widthThis - 100,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF2E3B62),
                              width: 2.0,
                            )),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: InternationalPhoneNumberInput(
                            onInputChanged: (PhoneNumber number) {
                              setState(() {
                                phoneNumber = number.phoneNumber.toString();
                              });
                            },
                            selectorConfig: const SelectorConfig(
                              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            ),
                            ignoreBlank: false,
                            autoValidateMode: AutovalidateMode.disabled,
                            selectorTextStyle:
                            const TextStyle(color: Colors.black),
                            initialValue: number,
                            textFieldController: controller,
                            formatInput: true,
                            keyboardType: const TextInputType.numberWithOptions(
                                signed: true, decimal: false),
                            inputBorder: const OutlineInputBorder(),
                            onSaved: (PhoneNumber number) {
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (phoneNumber != "" && phoneNumber.length > 8) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MobileNumberOTP(
                                    phoneNumber: phoneNumber,
                                  )),
                            );
                          }else{
                            warningToast("Warning...", "Enter valid phone number", context);
                          }
                        },
                        child: Container(
                          color: const Color(0xFF2E3B62),
                          width: widthThis - 100,
                          height: 70,
                          child: const Center(
                            child: Text(
                              "CONTINUE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // const Spacer(),

                    ],
                  ),
                ),
                SizedBox(
                  height: 216.0,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SizedBox(
                        height: 216,
                        width: widthThis,
                        // color: const Color(0xFF93D2F3),
                        child: SvgPicture.asset(
                          width: widthThis,
                          "assets/svg/2_b.svg",
                          fit: BoxFit.fill,
                        ),
                      ),
                      Column(
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          SizedBox(
                            width: widthThis,
                            height: 200,
                            // color: const Color(0xFF2E3B62),
                            child: SvgPicture.asset(
                              width: widthThis,
                              "assets/svg/2_a.svg",
                              fit: BoxFit.fill,
                            ),
                          ),
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

class MobileNumberOTP extends StatefulWidget {
  final String phoneNumber;

  const MobileNumberOTP({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  State<MobileNumberOTP> createState() => _MobileNumberOTPState(phoneNumber);
}

class _MobileNumberOTPState extends State<MobileNumberOTP> {
  // 4 text editing controllers that associate with the 4 input fields
  final TextEditingController _fieldOne = TextEditingController();
  final TextEditingController _fieldTwo = TextEditingController();
  final TextEditingController _fieldThree = TextEditingController();
  final TextEditingController _fieldFour = TextEditingController();
  final TextEditingController _fieldFive = TextEditingController();
  final TextEditingController _fieldSix = TextEditingController();

  String phoneNumber = "";

  _MobileNumberOTPState(this.phoneNumber);

  String? _otp;

  bool resendOTP = false;

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String verificationID = "";

  void startTimer(int seconds) {
    const oneSec = Duration(seconds: 1);
    Timer.periodic(
      oneSec,
          (Timer myTimer) {
        if (seconds == 0) {
          setState(() {
            resendOTP = true;
            myTimer.cancel();
          });
        } else {
          setState(() {
            seconds--;
          });
        }
      },
    );
  }

  void loginWithPhone() async {

    // check internet connection...
    bool checkMyInternet =
    await checkInternet();
    if (checkMyInternet == false) {
      if (context.mounted) {
        failureToast(
            " 😭  😭 ",
            "No Internet Connection.",
            context);
        Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) =>
              const NoInternetConnScreen()),
        );}
      return;
    }
    auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) {});
      },
      verificationFailed: (FirebaseAuthException e) {
        log(e.message.toString());
      },
      codeSent: (String verificationId, int? resendToken) {
        startTimer(60);
        setState(() {
          resendOTP = false;
          verificationID = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void verifyOTP() async {

    // check internet connection...
    bool checkMyInternet =
    await checkInternet();
    if (checkMyInternet == false) {
      if (context.mounted) {
        failureToast(
            " 😭  😭 ",
            "No Internet Connection.",
            context);
        Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) =>
              const NoInternetConnScreen()),
        );}
      return;
    }

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: _otp!);

    await auth.signInWithCredential(credential).then(
          (value) {
        setState(() {
          user = FirebaseAuth.instance.currentUser;
        });
      },
    ).whenComplete(
          () async {
        if (user != null) {
          successToast("Success...", "Valid login...", context);
Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const Home()),
          );
        } else {
          failureToast("Error...", "OTP not valid.", context);
        }
      },
    );
  }

  @override
  void initState() {



    loginWithPhone();

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
        child: Container(
          color: Colors.white,
          height: heightThis,
          child: SingleChildScrollView(
            child: Column(
              children:  <Widget>[
                SizedBox(
                  height: heightThis - heightTopThis - heightBottomThis - 216,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          GestureDetector(
                            onTap: (){
                              Navigator.of(context).pop();
                            },
                            child: const Icon(
                              Icons.arrow_back,
                              size: 30,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      SvgPicture.asset(
                        width: 56,
                        height: 56,
                        "assets/svg/img.svg",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Please enter your mobile number",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Code is sent to $phoneNumber",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OtpInput(_fieldOne, true), // auto focus
                          OtpInput(_fieldTwo, false),
                          OtpInput(_fieldThree, false),
                          OtpInput(_fieldFour, false),
                          OtpInput(_fieldFive, false),
                          OtpInput(_fieldSix, false)
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      resendOTP
                      ? RichText(
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        text: TextSpan(
                          text: 'Didn’t receive the code?',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                                text: 'Request Again',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    loginWithPhone();
                                  }
                                  ),
                          ],
                        ),
                      )
                      : const SizedBox(
                        height: 0,
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {


                          setState(() {
                            _otp = _fieldOne.text +
                                _fieldTwo.text +
                                _fieldThree.text +
                                _fieldFour.text +
                                _fieldFive.text +
                                _fieldSix.text;
                          });

                          if(_otp!.length==6){
                            verifyOTP();
                          }else{
                            warningToast("Warning...", "Enter OTP", context);
                          }
                        },
                        child: Container(
                          color: const Color(0xFF2E3B62),
                          width: widthThis - 100,
                          height: 70,
                          child: const Center(
                            child: Text(
                              "VERIFY AND CONTINUE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        _otp?.length != 0 ? "" : 'Please enter OTP',
                        style: const TextStyle(fontSize: 30),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 216.0,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SizedBox(
                        height: 216,
                        width: widthThis,
                        // color: const Color(0xFF93D2F3),
                        child: SvgPicture.asset(
                          width: widthThis,
                          "assets/svg/2_b.svg",
                          fit: BoxFit.fill,
                        ),
                      ),
                      Column(
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          SizedBox(
                            width: widthThis,
                            height: 200,
                            // color: const Color(0xFF2E3B62),
                            child: SvgPicture.asset(
                              width: widthThis,
                              "assets/svg/2_a.svg",
                              fit: BoxFit.fill,
                            ),
                          ),
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

class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final bool autoFocus;

  const OtpInput(this.controller, this.autoFocus, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      width: 45,
      child: TextField(
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        controller: controller,
        maxLength: 1,
        cursorColor: Theme.of(context).primaryColor,
        decoration: const InputDecoration(
            fillColor: Color(0xFF93D2F3),
            filled: true,
            border: OutlineInputBorder(),
            counterText: '',
            hintStyle: TextStyle(color: Colors.black, fontSize: 20.0)),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}
