import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:resolute_project_01/phone_auth.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  String myLanguage = "English";


  @override
  Widget build(BuildContext context) {
    double widthThis = MediaQuery.of(context).size.width;
    double heightThis = MediaQuery.of(context).size.height;

    double heightTopThis = MediaQuery.of(context).padding.top;
    double heightBottomThis = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            height: heightThis - heightTopThis - heightBottomThis,
            child: Column(
              children: [
                SizedBox(
                  height: heightThis - heightTopThis - heightBottomThis - 100,
                  child: Column(
                    children: [
                      const Spacer(),
                      SvgPicture.asset(
                        width: 56,
                        height: 56,
                        "assets/svg/img.svg",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Please select your Language",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "You can change the language\nat any time.",
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
                      SizedBox(
                        width: widthThis - 100,
                        child: DropdownButtonFormField<String>(
                          items: <String>[
                            'English',
                            'Hindi',
                            'Bengali',
                            'Marathi'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (thisValue) {
                            setState(() {
                              myLanguage = thisValue!;
                            });
                          },
                          value: myLanguage,
                          decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF2E3B62),
                                width: 2.0,
                              ),
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MobileNumber()),
                          );
                        },
                        child: Container(
                          color: const Color(0xFF2E3B62),
                          width: widthThis - 100,
                          height: 70,
                          child: const Center(
                            child: Text(
                              "NEXT",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 100.0,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SizedBox(
                        height: 100,
                        width: widthThis,
                        // color: const Color(0xFF93D2F3),
                        child: SvgPicture.asset(
                          width: widthThis,
                          "assets/svg/1_b.svg",
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(
                        width: widthThis,
                        height: 100,
                        // color: const Color(0xFF2E3B62),
                        child: SvgPicture.asset(
                          width: widthThis,
                          "assets/svg/1_a.svg",
                          fit: BoxFit.fill,
                        ),
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
