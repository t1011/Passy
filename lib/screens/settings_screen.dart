import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/screens/security_screen.dart';
import 'package:universal_io/io.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/common/assets.dart';

import 'backup_and_restore_screen.dart';
import 'main_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/settings';

  @override
  State<StatefulWidget> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          PassyPadding(ThreeWidgetButton(
            center: const Text('Backup & Restore'),
            left: const Icon(Icons.save_rounded),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => Navigator.pushNamed(
                context, BackupAndRestoreScreen.routeName,
                arguments: data.loadedAccount!.username),
          )),
          if (Platform.isAndroid || Platform.isIOS)
            PassyPadding(ThreeWidgetButton(
                center: const Text('Security'),
                left: const Icon(Icons.lock_rounded),
                right: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: () =>
                    Navigator.pushNamed(context, SecurityScreen.routeName))),
          PassyPadding(ThreeWidgetButton(
            center: const Text('About'),
            left: const Icon(Icons.info_outline_rounded),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 24),
                            Center(
                                child: SvgPicture.asset(
                              logoSvg,
                              color: Colors.purple,
                              width: 128,
                            )),
                            const SizedBox(height: 32),
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                text: 'Passy ',
                                style: TextStyle(fontFamily: 'FiraCode'),
                                children: [
                                  TextSpan(
                                    text: 'v$passyVersion',
                                    style: TextStyle(
                                      color:
                                          PassyTheme.lightContentSecondaryColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Account version: $accountVersion\nSync version: $syncVersion',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'FiraCode',
                                color: PassyTheme.lightContentSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Made with 💜 by Gleammer',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'FiraCode',
                              ),
                            ),
                            const SizedBox(height: 24),
                            PassyPadding(ThreeWidgetButton(
                              left: SvgPicture.asset(
                                'assets/images/github_icon.svg',
                                width: 26,
                                color: PassyTheme.lightContentColor,
                              ),
                              center: const Text('GitHub'),
                              right:
                                  const Icon(Icons.arrow_forward_ios_rounded),
                              onPressed: () => launch(
                                  'https://github.com/GleammerRay/Passy'),
                            )),
                          ],
                        ),
                      ));
            },
          )),
        ],
      ),
    );
  }
}
