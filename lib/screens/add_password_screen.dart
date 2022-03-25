import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/state.dart';
import 'package:passy/passy/account_data.dart';
import 'package:passy/passy/password.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/splash_screen.dart';

class AddPasswordScreen extends StatefulWidget {
  const AddPasswordScreen({Key? key}) : super(key: key);

  static const routeName = '/main/addPassword';

  @override
  State<StatefulWidget> createState() => _AddPasswordScreen();
}

class _AddPasswordScreen extends State<AddPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    Object? _args = ModalRoute.of(context)!.settings.arguments;
    bool _isNew = _args == null;
    final Password _password = _isNew ? Password() : _args as Password;

    return Scaffold(
      appBar: getAddScreenAppBar(
        context,
        title: 'Password',
        isNew: _isNew,
        onSave: () {
          AccountData _accountData = data.loadedAccount!.accountData;
          _accountData.passwords.add(_password);
          Navigator.pushReplacementNamed(context, SplashScreen.routeName);
          _accountData.save().whenComplete(() =>
              Navigator.pushNamedAndRemoveUntil(
                  context, MainScreen.routeName, ((route) => false)));
        },
      ),
      body: Column(children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Nickname'),
          onChanged: (value) => _password.nickname = value,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Username'),
          onChanged: (value) => _password.username = value,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Password'),
          onChanged: (value) => _password.password = value,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Website'),
          onChanged: (value) => _password.website = value,
        ),
        TextField(
          decoration: const InputDecoration(labelText: '2FA Secret'),
          onChanged: (value) => _password.tfaSecret = value,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Additional'),
          onChanged: (value) => _password.additionalInfo = value,
        ),
      ]),
    );
  }
}