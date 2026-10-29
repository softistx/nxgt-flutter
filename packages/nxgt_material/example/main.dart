// An adaptive sign-up screen (shell, page body, form section, fields,
// validators, a submit button) and a team page (status indicators, a
// responsive table, a select field and a confirmation), themed from a preset.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nxgt_material/collections.dart';
import 'package:nxgt_material/display.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:nxgt_material/fields.dart';
import 'package:nxgt_material/forms.dart';
import 'package:nxgt_material/l10n.dart';
import 'package:nxgt_material/layout.dart';
import 'package:nxgt_material/overlays.dart';
import 'package:nxgt_material/selection.dart';
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
        ShellDestination(icon: Icon(Icons.group_outlined), label: 'Team'),
      ],
      selectedIndex: _index,
      onSelected: (i) => setState(() => _index = i),
      body: _index == 1
          ? const TeamScreen()
          : SingleChildScrollView(
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
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                ),
                                validator: v.compose([
                                  v.required(),
                                  v.minLength(2),
                                ]),
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

class Member {
  const new({required this.name, required this.role, this.active = true});

  final String name;
  final String role;
  final bool active;
}

class TeamScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  var _members = const [
    Member(name: 'Ada Lovelace', role: 'Admin'),
    Member(name: 'Grace Hopper', role: 'Editor'),
    Member(name: 'Alan Turing', role: 'Viewer', active: false),
  ];
  var _ascending = true;
  String? _role;

  Future<void> _remove(Member member) async {
    final removed = await context.confirm(
      title: 'Remove ${member.name}?',
      message: 'They lose access to the team at once.',
      confirmLabel: 'Remove',
      destructive: true,
      onConfirm: () async {},
    );
    if (removed && mounted) {
      setState(
        () => _members = [
          for (final m in _members)
            if (m != member) m,
        ],
      );
      context.showToast('${member.name} removed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final roles = {for (final m in _members) m.role}
        .map((role) => ChoiceOption(value: role, label: role))
        .toList();
    return SingleChildScrollView(
      child: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            SelectField<String>(
              label: 'Role',
              options: roles,
              onChanged: (role) => setState(() => _role = role),
            ),
            ResponsiveTable<Member>(
              columns: [
                TableColumn(
                  label: 'Name',
                  value: (m) => m.name,
                  sortable: true,
                ),
                TableColumn(label: 'Role', value: (m) => m.role),
                TableColumn(
                  label: 'Status',
                  value: (m) => m.active ? 'Active' : 'Away',
                  cell: (context, m) => StatusIndicator(
                    label: m.active ? 'Active' : 'Away',
                    tone: m.active
                        ? FeedbackTone.success
                        : FeedbackTone.warning,
                  ),
                ),
              ],
              rows: [
                for (final m in _members)
                  if (_role == null || m.role == _role) m,
              ],
              sortColumnIndex: 0,
              sortAscending: _ascending,
              onSort: (column, {required ascending}) => setState(() {
                _ascending = ascending;
                _members = [..._members]
                  ..sort(
                    (a, b) => ascending
                        ? a.name.compareTo(b.name)
                        : b.name.compareTo(a.name),
                  );
              }),
              onRowTap: _remove,
            ),
          ],
        ),
      ),
    );
  }
}
