import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/auth/models/user_model.dart';
import 'package:mediaplex/auth/service/user_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> with SingleTickerProviderStateMixin {
  late Profile _data;
  bool _isLoading = false;
  late TabController _tab;
  late Future<Profile> _profile;
  final UserService _service = UserService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _oldPassword = TextEditingController();

  void init() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _profile = _service.fetchProfile(context);
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void initState() { super.initState(); init(); }

  @override
  void dispose() {
    _tab.dispose();
    _email.dispose();
    _username.dispose();
    _newPassword.dispose();
    _oldPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MyTheme.appBar(
      context,
      screen: 'ProfileScreen',
      bottom: TabBar(
        controller: _tab,
        tabs: const [
          Tab(text: 'Profile',  icon: Icon(Icons.person, color: MyTheme.secondary)),
          Tab(text: 'Settings', icon: Icon(Icons.settings, color: MyTheme.secondary))
        ]
      ),
      child: Expanded(child: Text('My Profile', overflow: TextOverflow.ellipsis, style: MyTheme.appText()))
    ),
    body: TabBarView(
      controller: _tab,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: MyTheme.boxDecoration(),
          child: FutureBuilder<Profile>(
            future: _profile,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Something went wrong...\nPlease try again later.', textAlign: TextAlign.center, style: MyTheme.appText(size: 20)));

              if (snapshot.hasData) {
                _data = snapshot.data!;
                _email.text = _data.email!;
                _username.text = _data.username!;

                return _data.toJson().isEmpty
                  ? Center(child: Text('No profile found', style: MyTheme.appText(size: 25, weight: FontWeight.bold)))
                  : Align(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Profile', style: MyTheme.appText(size: 36, weight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Text('Update your information', style: MyTheme.appText(weight: FontWeight.w500)),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * .7,
                          child: Form(
                            key: _formKey,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            child: Column(children: [
                              TextFormField(
                                autofocus: true,
                                controller: _username,
                                autofillHints: const ['Username'],
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
                                autofillHints: const ['Email'],
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
                                controller: _oldPassword,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) => TextInputAction.next,
                                style: MyTheme.appText(weight: FontWeight.normal),
                                decoration: MyTheme.inputDecoration(fontSize: 15, hint: 'Old Password', prefixIcon: Icons.lock),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Old password is required.';
                                  if (value.length < 8) return 'Password should be at least 8 characters long.';
                                  if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(value)) return 'Old password should contain at least one uppercase letter, one lowercase letter, one number & one special character.';
                                  return null;
                                }
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                obscureText: true,
                                controller: _newPassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (value) => TextInputAction.done,
                                style: MyTheme.appText(weight: FontWeight.normal),
                                decoration: MyTheme.inputDecoration(fontSize: 15, hint: 'New Password (optional)', prefixIcon: Icons.lock),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (value.length < 8) return 'New password should be at least 8 characters long.';
                                    if (_oldPassword.text == value) return 'New password should be different from old password.';
                                    if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(value)) return 'New password should contain at least one uppercase letter, one lowercase letter, one number & one special character.';
                                  }

                                  return null;
                                }
                              ),
                              Text('New password must be 8 or more characters long and contain a mix of uppercase & lower case letters, numbers and symbols.',
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

                                      _service.updateProfile(context, model: ProfileUpdate(
                                        email: _email.text,
                                        username: _username.text,
                                        oldPassword: _oldPassword.text,
                                        newPassword: _newPassword.text
                                      )).then((value) {
                                        if (value is Profile) { _email.text = value.email!; _username.text = value.username!; }
                                        MyTheme.showSnackBar(context, text: 'Profile updated successfully.');
                                      }).catchError((error) {
                                        MyTheme.showSnackBar(context, text: error);
                                      }).whenComplete(() => setState(() => _isLoading = false));
                                    }
                                  },
                                  child: _isLoading
                                    ? Center(child: LoadingAnimationWidget.staggeredDotsWave(size: 20, color: Colors.white))
                                    : Text('Update', style: MyTheme.appText())
                                )
                              )
                            ])
                          )
                        )
                      ]
                    ))
                  );
              } else { return Center(child: MyTheme.loadingAnimation()); }
            }
          )
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: MyTheme.boxDecoration(),
          child: Center(child: Text('Coming soon...', style: MyTheme.appText(size: 25, weight: FontWeight.bold)))
        )
      ]
    )
  );
}