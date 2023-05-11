import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resolute_project_01/utils/internet_check.dart';
import 'package:resolute_project_01/utils/toast.dart';

class NoInternetConnScreen extends StatefulWidget {
  const NoInternetConnScreen({Key? key}) : super(key: key);

  @override
  State<NoInternetConnScreen> createState() => _NoInternetConnScreenState();
}

class _NoInternetConnScreenState extends State<NoInternetConnScreen> {

  @override
  Widget build(BuildContext context) {

    double widthThis = MediaQuery.of(context).size.width; // Gives the width
    double heightThis = MediaQuery.of(context).size.height; // Gives the height
    double widthPortfolio = 390;
    double heightPortfolio = 844;

    double widthP = widthThis / widthPortfolio;
    double heightP = heightThis / heightPortfolio;


    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: const Color(0xFF26063F),
        systemNavigationBarDividerColor: const Color(0xFF1A2A6C),
        systemNavigationBarContrastEnforced: true,

        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        statusBarColor: const Color(0xFF26063F),

        systemStatusBarContrastEnforced: true,
      ),
    );
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            alignment: Alignment.center,
            height: ((250.0 * heightP) + 98.0+45.0),
            child: Column(
              children: [
                // SizedBox(
                //   height: ((250.0 * heightP) + 70.0),
                // ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "No Internet...",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                Image.asset(
                  'assets/gif/no_internet.gif',
                  height: 250.0 * heightP,
                  width: 250.0 * widthP,
                  fit: BoxFit.fill,
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        bool checkMyInternet = await checkInternet();
                        if(checkMyInternet == true){
                          if (context.mounted) Navigator.of(context).pop();
                        }else{
                          if (context.mounted) failureToast(" 😭  😭 ", "No Internet Connection.", context);
                        }
                      },
                      style: ButtonStyle(
                        foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
                        shape:
                        MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(14.0),
                        child: Text(
                          'Check Internet',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
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
