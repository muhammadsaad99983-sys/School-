import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common.dart';
import 'models.dart';
import 'store.dart';
import 'strings.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, Widget? _) {
        return Scaffold(
          appBar: blueAppBar(tr('nav_more')),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: <Widget>[
              _MenuTile(
                icon: Icons.class_,
                title: tr('classes'),
                subtitle: '${store.classes.length}',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (BuildContext _) => const ClassesScreen()),
                ),
              ),
              _MenuTile(
                icon: Icons.bar_chart,
                title: tr('reports'),
                subtitle: tr('reports_hint'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (BuildContext _) => const ReportsScreen()),
                ),
              ),
              _MenuTile(
                icon: Icons.settings,
                title: tr('settings'),
                subtitle: tr('settings_hint'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (BuildContext _) => const SettingsScreen()),
                ),
              ),
              _MenuTile(
                icon: Icons.info_outline,
                title: tr('about'),
                subtitle: tr('version'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: tr('app_name'),
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.school, color: kBlue, size: 40),
                    children: <Widget>[Text(tr('about_text'))],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kLightBlue,
          child: Icon(icon, color: kDeepBlue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}

// =====================================================================
//  Classes
// =====================================================================

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, Widget? _) {
        return Scaffold(
          appBar: blueAppBar(tr('classes')),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: Text(tr('new_class')),
            onPressed: () async {
              final String? n = await promptText(context, tr('new_class'));
              if (n != null && n.isNotEmpty) store.addClass(n);
            },
          ),
          body: store.classes.isEmpty
              ? EmptyState(Icons.class_, tr('no_classes_hint'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                  itemCount: store.classes.length,
                  itemBuilder: (BuildContext context, int i) {
                    final SchoolClass c = store.classes[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: kLightBlue,
                          child: Icon(Icons.class_, color: kDeepBlue),
                        ),
                        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${tr('students')}: ${store.studentCountInClass(c.id)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final String? n = await promptText(context, tr('rename_class'), initial: c.name);
                                if (n != null && n.isNotEmpty) store.renameClass(c.id, n);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: kRed),
                              onPressed: () async {
                                if (store.studentCountInClass(c.id) > 0) {
                                  snack(context, tr('err_class_not_empty'));
                                  return;
                                }
                                final bool ok = await confirmDialog(context, tr('delete'), tr('confirm_delete_class'));
                                if (ok) store.deleteClass(c.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

// =====================================================================
//  Reports
// =====================================================================

class _ReportRow {
  final String name;
  final int p;
  final int a;
  final int l;
  const _ReportRow(this.name, this.p, this.a, this.l);
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool teachers = false;
  int year = DateTime.now().year;
  int month = DateTime.now().month;
  String classId = '';

  void _shift(int delta) {
    setState(() {
      final DateTime d = DateTime(year, month + delta, 1);
      year = d.year;
      month = d.month;
    });
  }

  List<_ReportRow> _rows(String activeClass) {
    final List<_ReportRow> rows = <_ReportRow>[];
    if (teachers) {
      for (final Teacher t in store.teachers) {
        final List<int> s = store.monthStats(true, t.id, year, month);
        rows.add(_ReportRow(t.name, s[0], s[1], s[2]));
      }
    } else {
      for (final Student st in store.students) {
        if (st.classId != activeClass) continue;
        final List<int> s = store.monthStats(false, st.id, year, month);
        final String label = st.rollNo.isEmpty ? st.name : '${st.rollNo} - ${st.name}';
        rows.add(_ReportRow(label, s[0], s[1], s[2]));
      }
    }
    rows.sort((_ReportRow a, _ReportRow b) => a.name.compareTo(b.name));
    return rows;
  }

  String _asText(List<_ReportRow> rows, String activeClass) {
    final StringBuffer b = StringBuffer();
    if (store.schoolName.isNotEmpty) b.writeln(store.schoolName);
    b.writeln('${tr('reports')} - ${teachers ? tr('teachers') : tr('students')}');
    if (!teachers) b.writeln('${tr('class')}: ${store.className(activeClass)}');
    b.writeln('${monthName(month)} $year');
    b.writeln('------------------------');
    for (final _ReportRow r in rows) {
      b.writeln('${r.name}: ${tr('p_short')} ${r.p} | ${tr('a_short')} ${r.a} | ${tr('l_short')} ${r.l} | ${percentText(r.p, r.a, r.l)}');
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, Widget? _) {
        String activeClass = classId;
        if (!teachers) {
          final bool valid = store.classes.any((SchoolClass c) => c.id == activeClass);
          if (!valid) activeClass = store.classes.isNotEmpty ? store.classes.first.id : '';
        }
        final List<_ReportRow> rows = _rows(activeClass);

        return Scaffold(
          appBar: blueAppBar(
            tr('reports'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: tr('copy_report'),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _asText(rows, activeClass)));
                  if (context.mounted) snack(context, tr('copied'));
                },
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    segments: <ButtonSegment<bool>>[
                      ButtonSegment<bool>(value: false, label: Text(tr('students')), icon: const Icon(Icons.groups)),
                      ButtonSegment<bool>(value: true, label: Text(tr('teachers')), icon: const Icon(Icons.person)),
                    ],
                    selected: <bool>{teachers},
                    onSelectionChanged: (Set<bool> v) => setState(() => teachers = v.first),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => _shift(-1)),
                  Text('${monthName(month)} $year', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 18), onPressed: () => _shift(1)),
                ],
              ),
              if (!teachers && store.classes.isNotEmpty)
                ClassFilter(
                  items: store.classes.map((SchoolClass k) => MapEntry<String, String>(k.id, k.name)).toList(),
                  selected: activeClass,
                  onSelected: (String id) => setState(() => classId = id),
                ),
              const SizedBox(height: 6),
              Expanded(
                child: rows.isEmpty
                    ? EmptyState(Icons.bar_chart, tr('no_records'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: rows.length,
                        itemBuilder: (BuildContext context, int i) {
                          final _ReportRow r = rows[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      Pill(percentText(r.p, r.a, r.l), kBlue),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: <Widget>[
                                      Pill('${tr('present')}: ${r.p}', kGreen),
                                      Pill('${tr('absent')}: ${r.a}', kRed),
                                      Pill('${tr('leave')}: ${r.l}', kOrange),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =====================================================================
//  Settings
// =====================================================================

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _setPin(BuildContext context) async {
    final TextEditingController p1 = TextEditingController();
    final TextEditingController p2 = TextEditingController();
    String error = '';
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setSt) {
            return AlertDialog(
              title: Text(tr('set_pin')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: p1,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(labelText: tr('new_pin'), counterText: ''),
                  ),
                  TextField(
                    controller: p2,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(labelText: tr('pin_confirm'), counterText: ''),
                  ),
                  if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(error, style: const TextStyle(color: kRed)),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('cancel'))),
                FilledButton(
                  onPressed: () {
                    if (p1.text.length != 4) {
                      setSt(() => error = tr('err_pin_len'));
                    } else if (p1.text != p2.text) {
                      setSt(() => error = tr('err_pin_match'));
                    } else {
                      Navigator.pop(ctx, true);
                    }
                  },
                  child: Text(tr('save')),
                ),
              ],
            );
          },
        );
      },
    );
    if (ok == true) {
      store.setPin(p1.text);
      if (context.mounted) snack(context, tr('pin_saved'));
    }
  }

  Future<void> _restore(BuildContext context) async {
    final TextEditingController ctl = TextEditingController();
    final bool? go = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(tr('restore')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(tr('restore_hint')),
            const SizedBox(height: 8),
            TextField(controller: ctl, maxLines: 4),
            TextButton.icon(
              onPressed: () async {
                final ClipboardData? d = await Clipboard.getData('text/plain');
                if (d != null && d.text != null) ctl.text = d.text!;
              },
              icon: const Icon(Icons.paste),
              label: Text(tr('paste')),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('restore'))),
        ],
      ),
    );
    if (go == true) {
      final bool ok = store.importJson(ctl.text);
      if (context.mounted) snack(context, ok ? tr('restore_ok') : tr('restore_fail'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, Widget? _) {
        return Scaffold(
          appBar: blueAppBar(tr('settings')),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(tr('language'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: <Widget>[
                          ChoiceChip(
                            label: const Text('اردو'),
                            selected: store.lang == 'ur',
                            onSelected: (bool _) => store.setLang('ur'),
                          ),
                          ChoiceChip(
                            label: const Text('English'),
                            selected: store.lang == 'en',
                            onSelected: (bool _) => store.setLang('en'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.apartment, color: kBlue),
                  title: Text(tr('school_name')),
                  subtitle: Text(store.schoolName.isEmpty ? '-' : store.schoolName),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final String? n = await promptText(context, tr('school_name'), initial: store.schoolName);
                    if (n != null && n.isNotEmpty) store.setSchoolName(n);
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lock, color: kBlue),
                  title: Text(store.pin.isEmpty ? tr('set_pin') : tr('change_pin')),
                  subtitle: Text(store.pin.isEmpty ? tr('pin_off') : tr('pin_on')),
                  onTap: () => _setPin(context),
                ),
              ),
              if (store.pin.isNotEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.lock_open, color: kOrange),
                    title: Text(tr('remove_pin')),
                    onTap: () async {
                      final bool ok = await confirmDialog(context, tr('remove_pin'), tr('confirm_remove_pin'));
                      if (ok) store.setPin('');
                    },
                  ),
                ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.backup, color: kBlue),
                  title: Text(tr('backup')),
                  subtitle: Text(tr('backup_hint')),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: store.exportJson()));
                    if (context.mounted) snack(context, tr('backup_done'));
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.restore, color: kBlue),
                  title: Text(tr('restore')),
                  subtitle: Text(tr('restore_sub')),
                  onTap: () => _restore(context),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.delete_forever, color: kRed),
                  title: Text(tr('clear_all'), style: const TextStyle(color: kRed)),
                  subtitle: Text(tr('clear_all_hint')),
                  onTap: () async {
                    final bool ok = await confirmDialog(context, tr('clear_all'), tr('confirm_clear_all'));
                    if (ok) {
                      store.clearAll();
                      if (context.mounted) snack(context, tr('cleared'));
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
