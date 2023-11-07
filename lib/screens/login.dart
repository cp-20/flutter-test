import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart' as provider;
import 'package:google_fonts/google_fonts.dart';

import 'package:test_flutter_project/supabase/auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user =
        provider.Provider.of<SupabaseAuthState>(context).state.currentUser;

    if (user != null) {
      Future.microtask(
          () => Navigator.of(context).pushReplacementNamed('/home'));
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
              direction: Axis.vertical,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              children: [
                SvgPicture.asset(
                  'assets/logo.svg',
                  semanticsLabel: 'Logo',
                  width: 128,
                  height: 128,
                ),
                Text(
                  'ReadStack',
                  style: GoogleFonts.raleway(
                    textStyle:
                        Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '技術記事の未読消化をサポート',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // minimumSize: const Size.fromHeight(48),
                    fixedSize: const Size(double.infinity, 48),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: Wrap(
                    spacing: 8,
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(MdiIcons.github),
                      const Text('GtiHubでログイン')
                    ],
                  ),
                  onPressed: () {
                    signIn();
                  },
                ),
              ]),
        ),
      ),
    );
  }
}
