import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import 'error_screen.dart';
import 'package:mediaplex/auth/screens/login_screen.dart';
import 'package:mediaplex/player/models/media_model.dart';
import 'package:mediaplex/home/screens/account_screen.dart';
import 'package:mediaplex/home/screens/library_screen.dart';
import 'package:mediaplex/livestream_agora/main.dart';

class MyTheme {
  static const Color darkBg = Color(0xff1A1726);
  static const Color primary = Color(0xff5938eb);
  static const Color surface = Color(0xff232031);
  static const Color lightBg = Color(0xff242230);
  static const Color logoDark = Color(0xff9744F6);
  static const Color logoLight = Color(0xffB16FF7);
  static const Color secondary = Color(0xff78cda1);

  static TextStyle appText(
          {double size = 16,
          Color color = Colors.white,
          FontStyle style = FontStyle.normal,
          FontWeight weight = FontWeight.w600}) =>
      GoogleFonts.poppins(
          color: color, fontSize: size, fontStyle: style, fontWeight: weight);

  static AppBar appBar(BuildContext context,
          {String? screen,
          bool leading = true,
          PreferredSizeWidget? bottom,
          List<Widget> actions = const [],
          Widget child = const SizedBox()}) =>
      AppBar(
          elevation: 0,
          bottom: bottom,
          leadingWidth: 30,
          automaticallyImplyLeading: leading,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(decoration: boxDecoration()),
          title: Row(
              textBaseline: TextBaseline.ideographic,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (MediaQuery.sizeOf(context).width > 500) ...[
                  SvgPicture.asset('logo.svg',
                      height: 20,
                      placeholderBuilder: (context) =>
                          SizedBox(width: 154, child: loadingAnimation())),
                  const SizedBox(width: 20),
                  Center(
                      child: Container(
                          width: 1.5,
                          height: 40,
                          color: Colors.white.withOpacity(.5))),
                  const SizedBox(width: 20)
                ],
                child,
                const Spacer(),
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  // Add a SizedBox after every element to add spacing between them
                  ...actions
                      .map((_) => Row(children: [_, const SizedBox(width: 15)]))
                      .toList(),
                  if (screen != 'HomeScreen')
                    Row(children: [
                      IconButton(
                          splashRadius: 25,
                          tooltip: 'Go Home',
                          icon: const Icon(Icons.home_filled, size: 25),
                          onPressed: () => Navigator.popUntil(
                              context, (route) => route.isFirst)),
                      const SizedBox(width: 15)
                    ]),
                  if (screen != 'HomeScreen' || actions.isNotEmpty) ...[
                    Center(
                        child: Container(
                            width: 1.5,
                            height: 40,
                            color: Colors.white.withOpacity(.5))),
                    const SizedBox(width: 15)
                  ],
                  if (!Navigator.canPop(context))
                    Row(children: [
                      IconButton(
                          splashRadius: 25,
                          tooltip: 'My stream',
                          icon: const Icon(Icons.live_tv,
                              size: 25, color: secondary),
                          onPressed: () => push(context,
                              name: 'stream', widget: const StreamPage())),
                      const SizedBox(width: 15)
                    ]),
                  if (!Navigator.canPop(context))
                    Row(children: [
                      IconButton(
                          splashRadius: 25,
                          tooltip: 'My Library',
                          icon: const Icon(Icons.video_library,
                              size: 25, color: secondary),
                          onPressed: () => push(context,
                              name: 'library', widget: const LibraryScreen())),
                      const SizedBox(width: 15)
                    ]),
                  if (!Navigator.canPop(context))
                    Row(children: [
                      IconButton(
                          splashRadius: 25,
                          tooltip: 'My Account',
                          icon: const Icon(Icons.account_circle,
                              size: 25, color: secondary),
                          onPressed: () => push(context,
                              name: 'account', widget: const AccountScreen())),
                      const SizedBox(width: 15)
                    ]),
                  IconButton(
                      splashRadius: 25,
                      tooltip: 'Log Out',
                      icon: const Icon(Icons.power_settings_new, size: 25),
                      onPressed: () async => showAlertDialog(context,
                              title: 'Log Out',
                              text: 'Are you sure you want to log out?',
                              onConfirm: () async {
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            preferences.remove('token').then((value) {
                              // Go back to the first screen and replace it with LoginScreen
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                              push(context,
                                  replace: true, widget: const LoginScreen());
                              showSnackBar(context,
                                  text:
                                      'You have been logged out successfully.');
                            });
                          }))
                ])
              ]));

  static BoxDecoration boxDecoration(
          {double radius = 0, List<Color> colors = const [darkBg, lightBg]}) =>
      BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(radius));

  static InputDecoration inputDecoration(
          {String? hint,
          Color? bgColor,
          Color? borderColor,
          EdgeInsets? padding,
          IconData? prefixIcon,
          double fontSize = 20}) =>
      InputDecoration(
          filled: true,
          hintText: hint,
          counter: const Offstage(),
          fillColor: bgColor ?? surface,
          hintStyle: appText(size: fontSize, weight: FontWeight.normal),
          prefixIcon:
              prefixIcon != null ? Icon(prefixIcon, color: Colors.white) : null,
          contentPadding: padding ??
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.white)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withOpacity(.2))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor ?? Colors.white)));

  static ButtonStyle buttonStyle(
          {double fontSize = 10,
          Color fontColor = darkBg,
          Color bgColor = logoLight,
          Color borderColor = surface,
          FontWeight weight = FontWeight.bold}) =>
      ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          textStyle: appText(size: fontSize, weight: weight, color: fontColor),
          shape: RoundedRectangleBorder(
              side: BorderSide(color: borderColor),
              borderRadius: BorderRadius.circular(20)));

  static Future push(BuildContext context,
          {required Widget widget, String? name, bool replace = false}) =>
      (replace ? Navigator.pushReplacement : Navigator.push)(
          context,
          MaterialPageRoute(
              builder: (context) => widget,
              settings: RouteSettings(name: name)));

  static Future showError(BuildContext context, {required String text}) =>
      push(context, widget: ErrorPage(text: text));

  static Widget loadingAnimation() => LoadingAnimationWidget.fourRotatingDots(
      size: 30, color: MyTheme.logoLight);

  static showSnackBar(BuildContext context, {required String text}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          showCloseIcon: true,
          closeIconColor: Colors.white,
          backgroundColor: MyTheme.lightBg,
          content: Text(text,
              style: MyTheme.appText(size: 12, weight: FontWeight.w500))));

  static Future showAlertDialog(BuildContext context,
          {required String text,
          required String title,
          String cancel = 'Cancel',
          String confirm = 'Confirm',
          required Function() onConfirm}) =>
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                  backgroundColor: surface,
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  title: Text(title, style: appText(weight: FontWeight.w600)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  actionsPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(text, style: appText(weight: FontWeight.w500))
                      ]),
                  actions: [
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: buttonStyle(bgColor: Colors.redAccent),
                        child: Text(cancel,
                            style: appText(
                                color: surface, weight: FontWeight.w500))),
                    ElevatedButton(
                        style: buttonStyle(bgColor: Colors.greenAccent),
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        child: Text(confirm,
                            style: appText(
                                color: surface, weight: FontWeight.w500)))
                  ]));

  static Future showImageDialog(BuildContext context, {required Media image}) =>
      showDialog(
          context: context,
          builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(image.url!, fit: BoxFit.cover))));

  static Future showInputDialog(BuildContext context,
          {String label = 'Search',
          IconData icon = Icons.search,
          required TextEditingController controller,
          List<String> autofillHints = const ['search'],
          TextInputAction textInputAction = TextInputAction.search}) =>
      showDialog(
          context: context,
          builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: TextFormField(
                  autofocus: true,
                  controller: controller,
                  autofillHints: autofillHints,
                  textInputAction: textInputAction,
                  keyboardType: TextInputType.emailAddress,
                  onFieldSubmitted: (value) => textInputAction,
                  style: MyTheme.appText(weight: FontWeight.normal),
                  decoration: MyTheme.inputDecoration(
                      fontSize: 15, hint: label, prefixIcon: icon))));

  static Future<void> showVideoDialog(BuildContext context,
      {required Media video}) {
    String test =
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
    VideoPlayerController videoController = VideoPlayerController.network(test);

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: videoController.value.aspectRatio,
                child: VideoPlayer(videoController),
              ),
              ElevatedButton(
                onPressed: () {
                  if (videoController.value.isPlaying) {
                    videoController.pause();
                  } else {
                    videoController.play();
                  }
                },
                child: Icon(
                  videoController.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      videoController
          .dispose(); // Dispose of the video controller when the dialog is closed.
    });
  }

  static Future<void> showVideoPlayerDialog(BuildContext context,
      {required Media video}) async {
    VideoPlayerController _controller =
        VideoPlayerController.network(video.url!);

    await _controller.initialize();

    ChewieController chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true, // Lecture automatique
      looping: false, // Lecture en boucle
      showControls: true, // Afficher les contrôles du lecteur
      //aspectRatio: 16 / 9, // Ratio de l'aspect de la vidéo (peut être ajusté)
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height *
                  0.7, // Ajustez cette valeur selon vos besoins
            ),
            child: Chewie(controller: chewieController),
          ),
          actions: <Widget>[
            Container(
                height: 50,
                decoration: MyTheme.boxDecoration(radius: 30, colors: [
                  MyTheme.logoDark,
                  MyTheme.logoLight.withOpacity(0.7)
                ]),
                child: ElevatedButton(
                    style: MyTheme.buttonStyle(
                        bgColor: Colors.transparent,
                        borderColor: Colors.transparent),
                    onPressed: () async {
                      chewieController
                          .dispose(); // Libérer les ressources du lecteur vidéo
                      Navigator.of(context).pop();
                    },
                    child: Text('Close', style: MyTheme.appText())))
          ],
        );
      },
    );
  }
}
