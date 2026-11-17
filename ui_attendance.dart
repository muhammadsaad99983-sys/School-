import 'package:flutter/material.dart';
import 'common.dart';
import 'models.dart';
import 'store.dart';
import 'strings.dart';

class AttendanceTab extends StatefulWidget {
  final bool initialTeachers;
  const AttendanceTab({super.key, this.initialTeachers = false});

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  late bool teachers;
  DateTime date = DateTime.now();
  String classId = '';

  @override
  void initState() {
    super.initState();
    teachers = widget.initialTeachers;
  }

  Future<void> _pickDate() async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => date = d);
  }

  void _shiftDay(int delta) {
    setState(() => date = DateTime(date.year, date.month, date.day + delta));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, Widget? _) {
        final String day = dateKey(date);

        // choose a valid class
        String activeClass = classId;
        if (!teachers) {
          final bool valid = store.classes.any((SchoolClass c) => c.id == activeClass);
          if (!valid) {
            activeClass = store.classes.isNotEmpty ? store.classes.first.id : '';
          }
        }

        final List<MapEntry<String, String>> people = <MapEntry<String, String>>[];
        if (teachers) {
          for (final Teacher t in store.teachers) {
            people.add(MapEntry<String, String>(t.id, t.name));
          }
        } else {
          for (final Student s in store.students) {
            if (s.classId == activeClass) {
              final String label = s.rollNo.isEmpty ? s.name : '${s.rollNo} - ${s.name}';
              people.add(MapEntry<String, String>(s.id, label));
            }
          }
        }
        people.sort((MapEntry<String, String> a, MapEntry<String, String> b) => a.value.compareTo(b.value));

        final List<String> ids = people.map((MapEntry<String, String> e) => e.key).toList();
        final List<int> c = store.dayCounts(teachers, day, ids);
        int unmarked = ids.length - c[0] - c[1] - c[2];
        if (unmarked < 0) unmarked = 0;

        final bool noClasses = !teachers && store.classes.isEmpty;

        return Scaffold(
          appBar: blueAppBar(tr('attendance')),
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
                  IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => _shiftDay(-1)),
                  TextButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      '${weekdayName(date.weekday)}  ${fmtDate(day)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 18), onPressed: () => _shiftDay(1)),
                ],
              ),
              if (!teachers && store.classes.isNotEmpty)
                ClassFilter(
                  items: store.classes.map((SchoolClass k) => MapEntry<String, String>(k.id, k.name)).toList(),
                  selected: activeClass,
                  onSelected: (String id) => setState(() => classId = id),
                ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: <Widget>[
                    Pill('${tr('present')}: ${c[0]}', kGreen),
                    Pill('${tr('absent')}: ${c[1]}', kRed),
                    Pill('${tr('leave')}: ${c[2]}', kOrange),
                    Pill('${tr('unmarked')}: $unmarked', Colors.grey),
                  ],
                ),
              ),
              if (ids.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () {
                        store.markAll(teachers, day, ids, 'P');
                      },
                      icon: const Icon(Icons.done_all),
                      label: Text(tr('mark_all_present')),
                    ),
                  ),
                ),
              Expanded(
                child: noClasses
                    ? EmptyState(Icons.class_, tr('no_classes_hint'))
                    : people.isEmpty
                        ? EmptyState(Icons.groups_outlined, teachers ? tr('no_teachers') : tr('no_students_in_class'))
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24, top: 4),
                            itemCount: people.length,
                            itemBuilder: (BuildContext context, int i) {
                              final MapEntry<String, String> p = people[i];
                              final String cur = store.statusOf(teachers, day, p.key);
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    children: <Widget>[
                                      Avatar(p.value, size: 38),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          p.value,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      _StatusButton(
                                        status: 'P',
                                        selected: cur == 'P',
                                        onTap: () => store.setStatus(teachers, day, p.key, cur == 'P' ? '' : 'P'),
                                      ),
                                      const SizedBox(width: 6),
                                      _StatusButton(
                                        status: 'A',
                                        selected: cur == 'A',
                                        onTap: () => store.setStatus(teachers, day, p.key, cur == 'A' ? '' : 'A'),
                                      ),
                                      const SizedBox(width: 6),
                                      _StatusButton(
                                        status: 'L',
                                        selected: cur == 'L',
                                        onTap: () => store.setStatus(teachers, day, p.key, cur == 'L' ? '' : 'L'),
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

class _StatusButton extends StatelessWidget {
  final String status;
  final bool selected;
  final VoidCallback onTap;
  const _StatusButton({required this.status, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color color = statusColor(status);
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? color : Colors.transparent,
          border: Border.all(color: color, width: 1.5),
        ),
        child: Text(
          statusShort(status),
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
