import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'register_screen.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/home/home_screen.dart';
import 'package:mediaplex/auth/models/login_model.dart';
import 'package:mediaplex/auth/models/session_model.dart';
import 'package:mediaplex/auth/service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final AuthService _service = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: false,
    body: Container(
      padding: const EdgeInsets.all(30),
      decoration: MyTheme.boxDecoration(),
      child: Stack(children: [
        Align(child: SingleChildScrollView(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'logo.svg',
              placeholderBuilder: (context) => SizedBox(height: 55, child: MyTheme.loadingAnimation()),
              height: MediaQuery.sizeOf(context).width > 500 ? 50 : MediaQuery.sizeOf(context).width * .1
            ),
            const SizedBox(height: 20),
            Text('Enter your credentials to continue', style: MyTheme.appText(weight: FontWeight.w500)),
            const SizedBox(height: 40),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * .7,
              child: Form(
                key: _formKey,
                child: Column(children: [
                  TextFormField(
                    autofocus: true,
                    controller: _email,
                    autofillHints: const ['email'],
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    onFieldSubmitted: (value) => TextInputAction.next,
                    style: MyTheme.appText(weight: FontWeight.normal),
                    decoration: MyTheme.inputDecoration(fontSize: 15, hint: 'Email Address', prefixIcon: Icons.mail),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email address is required.';
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Email address is invalid.';
                      return null;
                    }
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    obscureText: true,
                    controller: _password,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (value) => TextInputAction.done,
                    style: MyTheme.appText(weight: FontWeight.normal),
                    decoration: MyTheme.inputDecoration(fontSize: 15, hint: 'Password', prefixIcon: Icons.lock),
                    validator: (value) {
                    if (value == null || value.isEmpty) return 'Password is required.';
                    if (value.length < 8) return 'Password should be at least 8 characters long.';
                    return null;
                  }
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 50,
                    width: MediaQuery.sizeOf(context).width,
                    decoration: MyTheme.boxDecoration(radius: 30, colors: [MyTheme.logoDark, MyTheme.logoLight.withOpacity(0.7)]),
                    child: ElevatedButton(
                      style: MyTheme.buttonStyle(bgColor: Colors.transparent, borderColor: Colors.transparent),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);

                          _service.login(context, model: Login(email: _email.text, password: _password.text)).then((value) {
                            if (value is SessionModel) MyTheme.push(context, replace: true, widget: const HomeScreen());
                          }).catchError((error) {
                            MyTheme.showSnackBar(context, text: 'Something went wrong... Please try again later.');
                          }).whenComplete(() => setState(() => _isLoading = false));
                        }
                      },
                      child: _isLoading
                        ? Center(child: LoadingAnimationWidget.staggeredDotsWave(size: 20, color: Colors.white))
                        : Text('Sign In', style: MyTheme.appText())
                    )
                  )
                ])
              )
            )
          ]
        ))),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('No account yet? ', style: MyTheme.appText()),
              GestureDetector(
                onTap: () => MyTheme.push(context, widget: const RegisterScreen()),
                child: MouseRegion(cursor: SystemMouseCursors.click, child: Text('Register.', style: MyTheme.appText(color: MyTheme.logoDark)))
              )
            ]
          )
        )
      ])
    )
  );
}