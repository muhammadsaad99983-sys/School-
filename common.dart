import 'package:flutter/material.dart';
import 'strings.dart';

const Color kBlue = Color(0xFF1565C0);
const Color kDeepBlue = Color(0xFF0D47A1);
const Color kLightBlue = Color(0xFFE3F2FD);
const Color kGreen = Color(0xFF2E7D32);
const Color kRed = Color(0xFFC62828);
const Color kOrange = Color(0xFFEF6C00);

Color statusColor(String s) {
  if (s == 'P') return kGreen;
  if (s == 'A') return kRed;
  if (s == 'L') return kOrange;
  return Colors.grey;
}

String statusShort(String s) {
  if (s == 'P') return tr('p_short');
  if (s == 'A') return tr('a_short');
  if (s == 'L') return tr('l_short');
  return '-';
}

String statusName(String s) {
  if (s == 'P') return tr('present');
  if (s == 'A') return tr('absent');
  if (s == 'L') return tr('leave');
  return tr('unmarked');
}

String percentText(int p, int a, int l) {
  final int total = p + a + l;
  if (total == 0) return '-';
  return '${(p * 100 / total).round()}%';
}

void snack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

Future<bool> confirmDialog(BuildContext context, String title, String body) async {
  final bool? r = await showDialog<bool>(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('cancel'))),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('yes'))),
      ],
    ),
  );
  return r == true;
}

Future<String?> promptText(BuildContext context, String title, {String initial = ''}) async {
  final TextEditingController ctl = TextEditingController(text: initial);
  final String? r = await showDialog<String>(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      title: Text(title),
      content: TextField(controller: ctl, autofocus: true),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('cancel'))),
        FilledButton(onPressed: () => Navigator.pop(ctx, ctl.text.trim()), child: Text(tr('save'))),
      ],
    ),
  );
  return r;
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  const Pill(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final String name;
  final double size;
  const Avatar(this.name, {super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final String t = name.trim();
    final String ch = t.isEmpty ? '?' : t.substring(0, 1);
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: kLightBlue,
      child: Text(
        ch,
        style: TextStyle(color: kDeepBlue, fontWeight: FontWeight.bold, fontSize: size * 0.4),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const EmptyState(this.icon, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 64, color: Colors.black26),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const StatBox({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withAlpha(30), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const InfoRow(this.icon, this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: kBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

PreferredSizeWidget blueAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
    title: Text(title),
    backgroundColor: kBlue,
    foregroundColor: Colors.white,
    actions: actions,
  );
}

/// A horizontal row of choice chips for choosing one class.
class ClassFilter extends StatelessWidget {
  final List<MapEntry<String, String>> items; // id -> label
  final String selected;
  final ValueChanged<String> onSelected;
  const ClassFilter({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: items
            .map((MapEntry<String, String> e) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(e.value),
                    selected: selected == e.key,
                    onSelected: (bool _) => onSelected(e.key),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
