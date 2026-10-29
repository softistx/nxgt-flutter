// An adaptive sign-up screen: shell, page body, form section, fields,
// validators and a submit button, themed from a preset.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nxgt_material/fields.dart';
import 'package:nxgt_material/forms.dart';
import 'package:nxgt_material/l10n.dart';
import 'package:nxgt_material/layout.dart';
import 'package:nxgt_material/theme.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nxgt_material example',
      theme: ThemePresets.ocean.light(),
      darkTheme: ThemePresets.ocean.dark(),
      localizationsDelegates: const [
        NxgtMaterialLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: NxgtMaterialLocalizations.supportedLocales,
      home: const SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _index = 0;

  Future<void> _signUp() async {
    // Runs only when the form is valid; the button shows a spinner meanwhile.
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    // Bar on compact, rail on medium, standing drawer on expanded and up.
    return AdaptiveShell(
      destinations: const [
        ShellDestination(
          icon: Icon(Icons.person_add_outlined),
          label: 'Sign up',
        ),
        ShellDestination(icon: Icon(Icons.info_outline), label: 'About'),
      ],
      selectedIndex: _index,
      onSelected: (i) => setState(() => _index = i),
      body: SingleChildScrollView(
        child: PageBody(
          child: Form(
            child: Column(
              spacing: 16,
              children: [
                FormSection(
                  title: 'Account',
                  children: [
                    Builder(
                      builder: (context) {
                        // The same localized rules as the fields, on any
                        // TextFormField.
                        final v = Validators.of(context);
                        return TextFormField(
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: v.compose([v.required(), v.minLength(2)]),
                        );
                      },
                    ),
                    const EmailField(label: 'Email', required: true),
                    const PasswordField(
                      label: 'Password',
                      newPassword: true,
                      minLength: 8,
                    ),
                  ],
                ),
                SubmitButton(label: 'Create account', onSubmit: _signUp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
