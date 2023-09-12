import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'error_page.dart';
import 'package:mediaplex/login/login.dart';
import 'package:mediaplex/home/screens/fav_screen.dart';

class MyTheme {
  static const Color darkBlue = Color(0xff1A1726);
  static const Color slightBlue = Color(0xff242230);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color logoDarkColor = Color(0xff9744F6);
  static const Color logoLightColor = Color(0xffB16FF7);
  static const Color slightDarkBlue = Color(0xff232031);

  static const String dbURL = 'http://127.0.0.1:8000/'; // 'https://web-7-ush.cloud.okteto.net/';
  static const String iptvURl = 'https://iptv-org.github.io/';

  static TextStyle appText({
    required double size,
    bool isShadow = false,
    Color color = whiteColor,
    required FontWeight weight,
    FontStyle style = FontStyle.normal
  }) {
    return GoogleFonts.poppins(
      color: color,
      fontSize: size,
      fontStyle: style,
      fontWeight: weight,
      shadows: isShadow
        ? [BoxShadow(blurRadius: 2, spreadRadius: 3, offset: const Offset(0.1, 0.4), color: Colors.black.withOpacity(0.4))]
        : null
    );
  }

  static AppBar appBar(BuildContext context, {Widget child = const SizedBox(), bool showSettings = false}) {
    return AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.transparent,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        textBaseline: TextBaseline.ideographic,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                stops: const [0.0, 1.0],
                tileMode: TileMode.clamp,
                end: const FractionalOffset(1.0, 0.0),
                begin: const FractionalOffset(0.0, 0.0),
                colors: [
                  MyTheme.logoDarkColor,
                  MyTheme.logoLightColor.withOpacity(0.6)
                ]
              )
            ),
            child: const Center(child: Icon(Icons.live_tv_rounded, color: MyTheme.darkBlue))
          ),
          const SizedBox(width: 10),
          Text('mediaplex', style: MyTheme.appText(size: 25, isShadow: true, weight: FontWeight.w600)),
          const SizedBox(width: 20),
          Center(child: Container(width: 1.5, height: 40, color: MyTheme.whiteColor.withOpacity(0.5))),
          const SizedBox(width: 10),
          child,
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: showSettings ? [
              IconButton(
                icon: const Icon(Icons.favorite, size: 25, color: MyTheme.logoLightColor),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavScreen()))
              ),
              const SizedBox(width: 15),
              IconButton(onPressed: () => {}, icon: const Icon(Icons.settings, size: 25, color: MyTheme.logoLightColor)),
              const SizedBox(width: 15),
              IconButton(
                onPressed: () async => showDialog(context: context, builder: (BuildContext context) => _buildLogoutDialog(context)),
                icon: const Icon(Icons.power_settings_new, size: 25, color: MyTheme.logoLightColor)
              )
            ] : [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, size: 25, color: MyTheme.logoLightColor)
              )
            ]
          )
        ]
      ),
      flexibleSpace: Container(decoration: const BoxDecoration(
        gradient: LinearGradient(
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
          end: FractionalOffset(1.0, 0.0),
          begin: FractionalOffset(0.0, 0.0),
          colors: [MyTheme.darkBlue, MyTheme.slightBlue]
        ))
      )
    );
  }

  static InputDecoration inputDecoration({
    String? hint,
    Color? bgColor,
    Color? borderColor,
    EdgeInsets? padding,
    IconData? prefixIcon,
    double fontSize = 20
  }) => InputDecoration(
    filled: true,
    hintText: hint,
    fillColor: bgColor ?? slightDarkBlue,
    hintStyle: appText(size: fontSize, weight: FontWeight.normal),
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: whiteColor) : null,
    contentPadding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    counter: const Offstage(),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: whiteColor)
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.redAccent)
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: borderColor ?? whiteColor)
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
    )
  );

  static ButtonStyle buttonStyle({
    double fontSize = 10,
    required Color backColor,
    Color fontColor = darkBlue,
    Color borderColor = slightDarkBlue,
    FontWeight weight = FontWeight.bold
  }) => ElevatedButton.styleFrom(
    backgroundColor: backColor,
    textStyle: appText(size: fontSize, weight: weight, color: fontColor),
    shape: RoundedRectangleBorder(side: BorderSide(color: borderColor), borderRadius: BorderRadius.circular(20))
  );

  static moveToErrorPage({required BuildContext context, required String text}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ErrorPage(text: text)));
  }

  static Widget _buildLogoutDialog(BuildContext context) => AlertDialog(
    backgroundColor: MyTheme.slightDarkBlue,
    actionsAlignment: MainAxisAlignment.spaceBetween,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    actionsPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Are you sure you want to log out?', style: MyTheme.appText(size: 15, weight: FontWeight.w500, color: MyTheme.whiteColor))
      ]
    ),
    actions: <Widget>[
      SizedBox(
        width: 100,
        child: ElevatedButton(
          style: MyTheme.buttonStyle(backColor: MyTheme.logoLightColor),
          onPressed: () async {
            SharedPreferences preferences = await SharedPreferences.getInstance();
            preferences.remove('session').then((value) => Navigator.push(context, MaterialPageRoute(builder: (_) => const Login())));
          },
          child: const Text('Yes')
        )
      ),
      SizedBox(
        width: 100,
        child: ElevatedButton(
          style: MyTheme.buttonStyle(backColor: MyTheme.logoLightColor),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('No')
        )
      )
    ]
  );
}