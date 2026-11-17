import 'package:flutter/material.dart';
import 'common.dart';
import 'store.dart';
import 'strings.dart';

BoxDecoration _blueGradient() {
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[Color(0xFF42A5F5), Color(0xFF1565C0), Color(0xFF0D47A1)],
    ),
  );
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: const Icon(Icons.school, size: 56, color: kDeepBlue),
    );
  }
}

class SetupScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SetupScreen({super.key, required this.onDone});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController name = TextEditingController();
  final TextEditingController pin1 = TextEditingController();
  final TextEditingController pin2 = TextEditingController();
  String language = store.lang;
  String error = '';

  @override
  void dispose() {
    name.dispose();
    pin1.dispose();
    pin2.dispose();
    super.dispose();
  }

  void _start() {
    final String p1 = pin1.text.trim();
    final String p2 = pin2.text.trim();
    if (name.text.trim().isEmpty) {
      setState(() => error = tr('err_school_name'));
      return;
    }
    if (p1.isNotEmpty || p2.isNotEmpty) {
      if (p1.length != 4) {
        setState(() => error = tr('err_pin_len'));
        return;
      }
      if (p1 != p2) {
        setState(() => error = tr('err_pin_match'));
        return;
      }
    }
    widget.onDone();
    store.completeSetup(name.text, p1, language);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _blueGradient(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  const _LogoBadge(),
                  const SizedBox(height: 14),
                  Text(
                    tr('welcome'),
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tr('setup_hint'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(tr('language'), style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: <Widget>[
                              ChoiceChip(
                                label: const Text('اردو'),
                                selected: language == 'ur',
                                onSelected: (bool _) {
                                  setState(() => language = 'ur');
                                  store.setLang('ur');
                                },
                              ),
                              ChoiceChip(
                                label: const Text('English'),
                                selected: language == 'en',
                                onSelected: (bool _) {
                                  setState(() => language = 'en');
                                  store.setLang('en');
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: name,
                            decoration: InputDecoration(
                              labelText: tr('school_name'),
                              prefixIcon: const Icon(Icons.apartment),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: pin1,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            decoration: InputDecoration(
                              labelText: tr('pin_optional'),
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: pin2,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            decoration: InputDecoration(
                              labelText: tr('pin_confirm'),
                              prefixIcon: const Icon(Icons.lock),
                              border: const OutlineInputBorder(),
                              counterText: '',
                            ),
                          ),
                          if (error.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(error, style: const TextStyle(color: kRed)),
                            ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _start,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(tr('start'), style: const TextStyle(fontSize: 16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String entered = '';
  bool wrong = false;

  void _tap(String d) {
    if (entered.length >= store.pin.length) return;
    final String next = entered + d;
    if (next.length == store.pin.length) {
      if (next == store.pin) {
        widget.onUnlocked();
      } else {
        setState(() {
          entered = '';
          wrong = true;
        });
      }
    } else {
      setState(() {
        entered = next;
        wrong = false;
      });
    }
  }

  void _del() {
    if (entered.isNotEmpty) {
      setState(() => entered = entered.substring(0, entered.length - 1));
    }
  }

  Widget _key(String label, VoidCallback? onTap, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 70,
          height: 70,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onTap == null ? Colors.transparent : Colors.white24,
          ),
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 26)
              : Text(label, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int len = store.pin.length;
    final List<Widget> dots = <Widget>[];
    for (int i = 0; i < len; i++) {
      dots.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: i < entered.length ? Colors.white : Colors.white24,
          border: Border.all(color: Colors.white54),
        ),
      ));
    }
    return Scaffold(
      body: Container(
        decoration: _blueGradient(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const _LogoBadge(),
                  const SizedBox(height: 14),
                  Text(
                    store.schoolName.isEmpty ? tr('app_name') : store.schoolName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(tr('enter_pin'), style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 18),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: dots),
                  SizedBox(
                    height: 32,
                    child: Center(
                      child: wrong
                          ? Text(tr('wrong_pin'), style: const TextStyle(color: Color(0xFFFFCDD2)))
                          : const SizedBox(),
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Column(
                      children: <Widget>[
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          _key('1', () => _tap('1')),
                          _key('2', () => _tap('2')),
                          _key('3', () => _tap('3')),
                        ]),
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          _key('4', () => _tap('4')),
                          _key('5', () => _tap('5')),
                          _key('6', () => _tap('6')),
                        ]),
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          _key('7', () => _tap('7')),
                          _key('8', () => _tap('8')),
                          _key('9', () => _tap('9')),
                        ]),
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          _key('', null),
                          _key('0', () => _tap('0')),
                          _key('', _del, icon: Icons.backspace_outlined),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
