import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/home/home_screen.dart';
import 'package:mediaplex/auth/service/auth_service.dart';
import 'package:mediaplex/auth/models/session_model.dart';
import 'package:mediaplex/auth/models/register_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isLoading = false;
  final AuthService _service = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _username = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: true,
    appBar: AppBar(
      flexibleSpace: Container(decoration: MyTheme.boxDecoration()),
      title: SvgPicture.asset('logo.svg', height: 20, placeholderBuilder: (context) => SizedBox(width: 154, child: MyTheme.loadingAnimation())),
    ),
    body: Container(
      padding: const EdgeInsets.all(30),
      decoration: MyTheme.boxDecoration(),
      child: Align(child: SingleChildScrollView(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Register', style: MyTheme.appText(size: 36, weight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text('Create an account to continue', style: MyTheme.appText(weight: FontWeight.w500)),
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.sizeOf(context).width * .7,
            child: Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  autofocus: true,
                  controller: _username,
                  autofillHints: const ['username'],
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) => TextInputAction.next,
                  style: MyTheme.appText(weight: FontWeight.normal),
                  decoration: MyTheme.inputDecoration(fontSize: 15, hint: 'Username', prefixIcon: Icons.person),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Username is required.';
                    if (value.length < 3) return 'Username should be at least 3 characters long.';
                    return null;
                  }
                ),
                const SizedBox(height: 12),
                TextFormField(
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
                    if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(value)) return 'Password should contain at least one uppercase letter, one lowercase letter, one number & one special character.';
                    return null;
                  }
                ),
                Text('Password must be 8 or more characters long and contain a mix of uppercase & lower case letters, numbers and symbols.',
                  textAlign: TextAlign.justify,
                  style: MyTheme.appText(size: 12 , weight: FontWeight.w400)
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

                        _service.register(context, model: Register(email: _email.text, password: _password.text, username: _username.text)).then((value) {
                          if (value is SessionModel) {
                            Navigator.of(context).pop();
                            MyTheme.push(context, replace: true, widget: const HomeScreen());
                          }
                        }).catchError((error) {
                          MyTheme.showSnackBar(context, text: 'Something went wrong... Please try again later.');
                        }).whenComplete(() => setState(() => _isLoading = false));
                      }
                    },
                    child: _isLoading
                      ? Center(child: LoadingAnimationWidget.staggeredDotsWave(size: 20, color: Colors.white))
                      : Text('Sign Up', style: MyTheme.appText())
                  )
                )
              ])
            )
          )
        ]
      )))
    )
  );
}