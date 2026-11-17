import 'package:flutter/material.dart';
import 'common.dart';
import 'models.dart';
import 'store.dart';
import 'strings.dart';
import 'ui_attendance.dart';
import 'ui_more.dart';
import 'ui_people.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, Widget? _) {
        return Scaffold(
          body: IndexedStack(
            index: tab,
            children: <Widget>[
              DashboardTab(onGoTo: (int i) => setState(() => tab = i)),
              const StudentsTab(),
              const TeachersTab(),
              const AttendanceTab(),
              const MoreTab(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: (int i) => setState(() => tab = i),
            destinations: <NavigationDestination>[
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: tr('nav_home'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.groups_outlined),
                selectedIcon: const Icon(Icons.groups),
                label: tr('nav_students'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: tr('nav_teachers'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.fact_check_outlined),
                selectedIcon: const Icon(Icons.fact_check),
                label: tr('nav_attendance'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu),
                selectedIcon: const Icon(Icons.menu_open),
                label: tr('nav_more'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DashboardTab extends StatelessWidget {
  final ValueChanged<int> onGoTo;
  const DashboardTab({super.key, required this.onGoTo});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, Widget? _) {
        final DateTime now = DateTime.now();
        final String today = dateKey(now);
        final List<String> sIds = store.students.map((Student s) => s.id).toList();
        final List<String> tIds = store.teachers.map((Teacher t) => t.id).toList();
        final List<int> sc = store.dayCounts(false, today, sIds);
        final List<int> tc = store.dayCounts(true, today, tIds);
        final String title = store.schoolName.isEmpty ? tr('app_name') : store.schoolName;

        return Scaffold(
          body: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 26),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFF42A5F5), Color(0xFF0D47A1)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.school, color: kDeepBlue, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${weekdayName(now.weekday)}  •  ${fmtDate(today)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.35,
                      children: <Widget>[
                        StatBox(
                          label: tr('total_students'),
                          value: '${store.students.length}',
                          icon: Icons.groups,
                          color: kBlue,
                        ),
                        StatBox(
                          label: tr('total_teachers'),
                          value: '${store.teachers.length}',
                          icon: Icons.person,
                          color: const Color(0xFF6A1B9A),
                        ),
                        StatBox(
                          label: tr('classes'),
                          value: '${store.classes.length}',
                          icon: Icons.class_,
                          color: const Color(0xFF00838F),
                        ),
                        StatBox(
                          label: tr('students_present_today'),
                          value: '${sc[0]}',
                          icon: Icons.check_circle,
                          color: kGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(tr('today_summary'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _SummaryCard(
                      title: tr('students'),
                      icon: Icons.groups,
                      counts: sc,
                      total: sIds.length,
                    ),
                    const SizedBox(height: 8),
                    _SummaryCard(
                      title: tr('teachers'),
                      icon: Icons.person,
                      counts: tc,
                      total: tIds.length,
                    ),
                    const SizedBox(height: 18),
                    Text(tr('quick_actions'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.fact_check,
                            label: tr('mark_students'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(builder: (BuildContext _) => const AttendanceTab(initialTeachers: false)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.how_to_reg,
                            label: tr('mark_teachers'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(builder: (BuildContext _) => const AttendanceTab(initialTeachers: true)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.person_add,
                            label: tr('add_student'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(builder: (BuildContext _) => const StudentForm()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.person_add_alt_1,
                            label: tr('add_teacher'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(builder: (BuildContext _) => const TeacherForm()),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<int> counts;
  final int total;
  const _SummaryCard({
    required this.title,
    required this.icon,
    required this.counts,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final int unmarked = total - counts[0] - counts[1] - counts[2];
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, color: kBlue),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                Text('${tr('total')}: $total', style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: <Widget>[
                Pill('${tr('present')}: ${counts[0]}', kGreen),
                Pill('${tr('absent')}: ${counts[1]}', kRed),
                Pill('${tr('leave')}: ${counts[2]}', kOrange),
                Pill('${tr('unmarked')}: ${unmarked < 0 ? 0 : unmarked}', Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: <Widget>[
              Icon(icon, color: kBlue, size: 28),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
