import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:resolute_project_01/first_page.dart';
import 'package:resolute_project_01/home2.dart';
import 'package:url_launcher/url_launcher.dart';

class MySplash extends StatefulWidget {
  const MySplash({Key? key}) : super(key: key);

  @override
  State<MySplash> createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  String myLanguage = "English";

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  Future<void> checkUser() async {
    await Future.delayed(const Duration(seconds: 0));

    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });

    if (user != null) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    }
    else {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FirstPage()),
        );
      }
    }

  }

  @override
  void initState() {
    checkUser();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double heightThis = MediaQuery.of(context).size.height;

    double heightTopThis = MediaQuery.of(context).padding.top;
    double heightBottomThis = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            height: heightThis - heightTopThis - heightBottomThis,
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                children: [
                  SizedBox(
                    height: heightThis - heightTopThis - heightBottomThis-100,
                    child: Column(
                      children: [
                        const Spacer(),

                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Use for demo purposes",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'This application is used for only education and project purpose. Developed by by Sayantan Kar. Available at github: ',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                  text: 'iamsayantankar',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(Uri.parse(
                                          'https://github.com/iamsayantankar/resolute_project_01'));
                                    }
                              ),
                              TextSpan(
                                  text: '\nYou can read my updated CV here',
                                  style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(Uri.parse(
                                          'https://sayantankar.com'));
                                    }
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
