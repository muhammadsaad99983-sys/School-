import 'package:flutter/material.dart';
import 'common.dart';
import 'store.dart';
import 'strings.dart';
import 'ui_auth.dart';
import 'ui_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await store.load();
  runApp(const SchoolApp());
}

class SchoolApp extends StatelessWidget {
  const SchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, Widget? _) {
        setLang(store.lang);
        return MaterialApp(
          title: tr('app_name'),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: kBlue),
            scaffoldBackgroundColor: const Color(0xFFF3F7FC),
          ),
          builder: (BuildContext context, Widget? child) {
            return Directionality(
              textDirection: store.lang == 'ur' ? TextDirection.rtl : TextDirection.ltr,
              child: child ?? const SizedBox(),
            );
          },
          home: const Gate(),
        );
      },
    );
  }
}

class Gate extends StatefulWidget {
  const Gate({super.key});

  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  bool unlocked = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, Widget? _) {
        if (!store.setupDone) {
          return SetupScreen(onDone: () => setState(() => unlocked = true));
        }
        if (store.pin.isNotEmpty && !unlocked) {
          return LockScreen(onUnlocked: () => setState(() => unlocked = true));
        }
        return const HomeShell();
      },
    );
  }
}
