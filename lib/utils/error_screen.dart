import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mediaplex/utils/theme.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({super.key, required this.text});

  final String text;

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.darkBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                LottieBuilder.asset('lottie/not_found.json', width: 250, height: 250),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * .8,
                  child: Text(widget.text, textAlign: TextAlign.center, style: MyTheme.appText(size: 20, weight: FontWeight.bold))
                )
              ]
            ),
            const SizedBox(height: 80),
            Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(colors: [MyTheme.logoDark, MyTheme.logoLight.withOpacity(.7)])
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: MyTheme.buttonStyle(bgColor: Colors.transparent, borderColor: Colors.transparent),
                child: Text('Go Back', style: MyTheme.appText(size: 16))
              )
            )
          ]
        )
      )
    );
  }
}