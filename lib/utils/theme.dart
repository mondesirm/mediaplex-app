import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'error_screen.dart';
import 'package:mediaplex/auth/login_screen.dart';
import 'package:mediaplex/home/screens/fav_screen.dart';

class MyTheme {
  static const Color darkBg = Color(0xff1A1726);
  static const Color primary = Color(0xff5938eb);
  static const Color surface = Color(0xff232031);
  static const Color lightBg = Color(0xff242230);
  static const Color logoDark = Color(0xff9744F6);
  static const Color logoLight = Color(0xffB16FF7);
  static const Color secondary = Color(0xff78cda1);

  static const String dbURL = 'http://127.0.0.1:8000/';
  static const String iptvURl = 'https://iptv-org.github.io/';

  static TextStyle appText({
    double size = 16,
    Color color = Colors.white,
    FontStyle style = FontStyle.normal,
    FontWeight weight = FontWeight.w600
  }) => GoogleFonts.poppins(
    color: color,
    fontSize: size,
    fontStyle: style,
    fontWeight: weight
  );

  static AppBar appBar(BuildContext context, {String screen = '', bool leading = true, Widget child = const SizedBox()}) => AppBar(
    elevation: 0,
    leadingWidth: 30,
    automaticallyImplyLeading: leading,
    backgroundColor: Colors.transparent,
    flexibleSpace: Container(decoration: boxDecoration()),
    title: Row(
      textBaseline: TextBaseline.ideographic,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (MediaQuery.of(context).size.width > 500) ...[
          SvgPicture.asset('logo.svg', height: 20),
          const SizedBox(width: 20),
          Center(child: Container(width: 1.5, height: 40, color: Colors.white.withOpacity(.5))),
          const SizedBox(width: 20)
        ],
        child,
        const Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (screen != 'FavScreen') ...[
              IconButton(
                splashRadius: 25,
                icon: const Icon(Icons.favorite, size: 25, color: Colors.red),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavScreen()))
              ),
              const SizedBox(width: 15)
            ],
            if (screen != 'ProfileScreen') ...[
              IconButton(
                splashRadius: 25,
                icon: const Icon(Icons.person, size: 25, color: secondary),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavScreen()))
              ),
              const SizedBox(width: 15)
            ],
            IconButton(
              splashRadius: 25,
              icon: const Icon(Icons.power_settings_new, size: 25, color: logoLight),
              onPressed: () async => showDialog(context: context, builder: (BuildContext context) => _buildLogoutDialog(context))
            )
          ]
        )
      ]
    )
  );

  static BoxDecoration boxDecoration({
    double radius = 0,
    List<Color> colors = const [darkBg, lightBg]
  }) => BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    gradient: LinearGradient(end: Alignment.centerRight, begin: Alignment.centerLeft, colors: colors)
  );

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
    counter: const Offstage(),
    fillColor: bgColor ?? surface,
    hintStyle: appText(size: fontSize, weight: FontWeight.normal),
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.white) : null,
    contentPadding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.withOpacity(.2))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor ?? Colors.white))
  );

  static ButtonStyle buttonStyle({
    double fontSize = 10,
    Color fontColor = darkBg,
    Color bgColor = logoLight,
    Color borderColor = surface,
    FontWeight weight = FontWeight.bold
  }) => ElevatedButton.styleFrom(
    backgroundColor: bgColor,
    textStyle: appText(size: fontSize, weight: weight, color: fontColor),
    shape: RoundedRectangleBorder(side: BorderSide(color: borderColor), borderRadius: BorderRadius.circular(20))
  );

  static push(BuildContext context, {required Widget widget}) => Navigator.push(context, MaterialPageRoute(builder: (context) => widget));

  static showError(BuildContext context, {required String text}) => push(context, widget: ErrorPage(text: text));

  static showSnackBar(BuildContext context, {required String text}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    showCloseIcon: true,
    closeIconColor: Colors.white,
    backgroundColor: MyTheme.lightBg,
    content: Text(text, style: MyTheme.appText(size: 12, weight: FontWeight.w500))
  ));

  static Widget _buildLogoutDialog(BuildContext context) => AlertDialog(
    backgroundColor: surface,
    actionsAlignment: MainAxisAlignment.spaceBetween,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    actionsPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Are you sure you want to log out?', style: appText(weight: FontWeight.w500))
      ]
    ),
    actions: <Widget>[
      SizedBox(
        width: 100,
        child: ElevatedButton(
          style: buttonStyle(),
          onPressed: () async {
            SharedPreferences preferences = await SharedPreferences.getInstance();
            preferences.remove('session').then((value) => push(context, widget: const LoginScreen()));
          },
          child: const Text('Yes')
        )
      ),
      SizedBox(
        width: 100,
        child: ElevatedButton(
          style: buttonStyle(),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('No')
        )
      )
    ]
  );
}