import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ticketonline/Config.dart';
import 'package:ticketonline/pages/DashboardPage.dart';
import 'package:ticketonline/services/DataService.dart';
import 'package:ticketonline/services/ToastHelper.dart';

class LoginPage extends StatefulWidget {
  static const ROUTE = "/login";
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Přihlášení"),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Config.appMaxWidth),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 200,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextFormField(
                        autofillHints: const [AutofillHints.email],
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'E-mail'),
                        validator: (String? value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'E-mail není validní';
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 15, bottom: 0),
                      //padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextFormField(
                        controller: _passwordController,
                        autofillHints: const [AutofillHints.password],
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Heslo'),
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return 'Špatné heslo';
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      height: 50,
                      width: 250,
                      decoration: BoxDecoration(
                          color: Config.color1,
                          borderRadius: BorderRadius.circular(20)),
                      child: TextButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            TextInput.finishAutofillContext();
                            await DataService.login(
                                _emailController.text, _passwordController.text)
                                .then(_showToast)
                                .then(_refreshSignedInStatus)
                                .catchError(_onError);
                          }
                        },
                        child: const Text(
                          'Přihlásit se',
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshSignedInStatus(value) async {
    var loggedIn = await DataService.tryAuthUser();
    if(loggedIn)
    {
      await DataService.loadCurrentUserData();
      context.go(DashboardPage.ROUTE);
    }
  }

  void _showToast(value) {
    ToastHelper.Show("Úspěšné přihlášení!");
  }

  void _onError(err) {
    ToastHelper.Show("Špatné přihlašovací údaje!", severity: ToastSeverity.NotOk);
  }
}