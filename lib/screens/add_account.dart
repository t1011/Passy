import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:passy/common/state.dart';
import 'package:passy/common/theme.dart';

class AddAccount extends StatefulWidget {
  const AddAccount({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddAccount();
}

class _AddAccount extends State<StatefulWidget> {
  String _username = '';
  String _password = '';
  String _confirmPassword = '';
  final String _icon = 'assets/images/logo_circle.svg';
  final Color _color = Colors.purple;
  Widget? _backButton;

  void addAccount() {
    if (data.hasAccount(_username)) {
      throw Exception('Cannot have two accounts with the same login');
    }
    data.passy.lastUsername = _username;
    data.passy.save();
    data.createAccount(_username, _password, _icon, _color);
  }

  @override
  Widget build(BuildContext context) {
    _backButton = data.noAccounts
        ? null
        : Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ));
    return Scaffold(
      floatingActionButton: _backButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: CustomScrollView(slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: [
              const Spacer(),
              purpleLogo,
              const Spacer(),
              const Text(
                'Add an account',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              const Spacer(),
              Expanded(
                child: Row(
                  children: [
                    const Spacer(),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (a) => _username = a,
                                  decoration: InputDecoration(
                                    border: outlineInputBorder,
                                    hintText: 'Username',
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(' ')
                                  ],
                                  autofocus: true,
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  obscureText: true,
                                  onChanged: (a) => _password = a,
                                  decoration: InputDecoration(
                                    border: outlineInputBorder,
                                    hintText: 'Password',
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(' '),
                                    LengthLimitingTextInputFormatter(32),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    border: outlineInputBorder,
                                    hintText: 'Confirm password',
                                  ),
                                  onChanged: (a) => _confirmPassword = a,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(' ')
                                  ],
                                ),
                              ),
                              FloatingActionButton(
                                onPressed: () async {
                                  if (_username.isEmpty) return;
                                  if (_password.isEmpty) return;
                                  if (_password != _confirmPassword) return;
                                  addAccount();
                                  loadApp(context);
                                },
                                child: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                ),
                                heroTag: 'addAccountBtn',
                              ),
                            ],
                          ),
                          const Spacer(flex: 2),
                        ],
                      ),
                      flex: 10,
                    ),
                    const Spacer(),
                  ],
                ),
                flex: 4,
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
