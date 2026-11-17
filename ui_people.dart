import 'package:flutter/material.dart';
import 'common.dart';
import 'models.dart';
import 'store.dart';
import 'strings.dart';

// =====================================================================
//  Students
// =====================================================================

class StudentsTab extends StatefulWidget {
  const StudentsTab({super.key});

  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  String query = '';
  String classId = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, Widget? _) {
        final String q = query.trim().toLowerCase();
        final List<Student> list = store.students.where((Student s) {
          if (classId.isNotEmpty && s.classId != classId) return false;
          if (q.isEmpty) return true;
          return s.name.toLowerCase().contains(q) ||
              s.fatherName.toLowerCase().contains(q) ||
              s.rollNo.toLowerCase().contains(q) ||
              s.phone.contains(q);
        }).toList();
        list.sort((Student a, Student b) => a.name.compareTo(b.name));

        final List<MapEntry<String, String>> filters = <MapEntry<String, String>>[
          MapEntry<String, String>('', tr('all')),
          ...store.classes.map((SchoolClass c) => MapEntry<String, String>(c.id, c.name)),
        ];

        return Scaffold(
          appBar: blueAppBar('${tr('students')} (${store.students.length})'),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (BuildContext _) => const StudentForm()),
            ),
            icon: const Icon(Icons.person_add),
            label: Text(tr('add_student')),
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: TextField(
                  onChanged: (String v) => setState(() => query = v),
                  decoration: InputDecoration(
                    hintText: tr('search'),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              ClassFilter(
                items: filters,
                selected: classId,
                onSelected: (String id) => setState(() => classId = id),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: list.isEmpty
                    ? EmptyState(Icons.groups_outlined, store.students.isEmpty ? tr('no_students') : tr('no_results'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: list.length,
                        itemBuilder: (BuildContext context, int i) {
                          final Student s = list[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: ListTile(
                              leading: Avatar(s.name),
                              title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${tr('father')}: ${s.fatherName.isEmpty ? '-' : s.fatherName}\n'
                                '${store.className(s.classId)}  •  ${tr('roll')}: ${s.rollNo.isEmpty ? '-' : s.rollNo}',
                              ),
                              isThreeLine: true,
                              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(builder: (BuildContext _) => StudentDetail(id: s.id)),
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

class StudentForm extends StatefulWidget {
  final Student? student;
  const StudentForm({super.key, this.student});

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController father;
  late final TextEditingController mother;
  late final TextEditingController phone;
  late final TextEditingController address;
  late final TextEditingController roll;
  String classId = '';
  String gender = 'M';
  String admission = '';

  @override
  void initState() {
    super.initState();
    final Student? s = widget.student;
    name = TextEditingController(text: s?.name ?? '');
    father = TextEditingController(text: s?.fatherName ?? '');
    mother = TextEditingController(text: s?.motherName ?? '');
    phone = TextEditingController(text: s?.phone ?? '');
    address = TextEditingController(text: s?.address ?? '');
    roll = TextEditingController(text: s?.rollNo ?? '');
    classId = s?.classId ?? (store.classes.isNotEmpty ? store.classes.first.id : '');
    gender = s?.gender ?? 'M';
    admission = (s != null && s.admissionDate.isNotEmpty) ? s.admissionDate : dateKey(DateTime.now());
  }

  @override
  void dispose() {
    name.dispose();
    father.dispose();
    mother.dispose();
    phone.dispose();
    address.dispose();
    roll.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime initial = parseKey(admission) ?? DateTime.now();
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => admission = dateKey(d));
  }

  Future<void> _addClass() async {
    final String? n = await promptText(context, tr('new_class'));
    if (n != null && n.isNotEmpty) {
      final String id = store.addClass(n);
      setState(() => classId = id);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (store.classes.isEmpty || classId.isEmpty) {
      snack(context, tr('err_choose_class'));
      return;
    }
    final Student? existing = widget.student;
    if (existing == null) {
      store.addStudent(Student(
        id: store.newId(),
        name: name.text.trim(),
        fatherName: father.text.trim(),
        motherName: mother.text.trim(),
        phone: phone.text.trim(),
        address: address.text.trim(),
        classId: classId,
        rollNo: roll.text.trim(),
        gender: gender,
        admissionDate: admission,
      ));
    } else {
      existing.name = name.text.trim();
      existing.fatherName = father.text.trim();
      existing.motherName = mother.text.trim();
      existing.phone = phone.text.trim();
      existing.address = address.text.trim();
      existing.classId = classId;
      existing.rollNo = roll.text.trim();
      existing.gender = gender;
      existing.admissionDate = admission;
      store.updateStudent(existing);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool editing = widget.student != null;
    return Scaffold(
      appBar: blueAppBar(editing ? tr('edit_student') : tr('add_student')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: tr('student_name'),
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
              ),
              validator: (String? v) => (v == null || v.trim().isEmpty) ? tr('err_required') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: father,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: tr('father_name'),
                prefixIcon: const Icon(Icons.man),
                border: const OutlineInputBorder(),
              ),
              validator: (String? v) => (v == null || v.trim().isEmpty) ? tr('err_required') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: mother,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: tr('mother_name'),
                prefixIcon: const Icon(Icons.woman),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: tr('parent_phone'),
                prefixIcon: const Icon(Icons.phone),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: roll,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: tr('roll_no'),
                prefixIcon: const Icon(Icons.numbers),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: address,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: tr('address'),
                prefixIcon: const Icon(Icons.home),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(tr('class'), style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: <Widget>[
                ...store.classes.map((SchoolClass c) => ChoiceChip(
                      label: Text(c.name),
                      selected: classId == c.id,
                      onSelected: (bool _) => setState(() => classId = c.id),
                    )),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(tr('new_class')),
                  onPressed: _addClass,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(tr('gender'), style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: <Widget>[
                ChoiceChip(
                  label: Text(tr('male')),
                  selected: gender == 'M',
                  onSelected: (bool _) => setState(() => gender = 'M'),
                ),
                ChoiceChip(
                  label: Text(tr('female')),
                  selected: gender == 'F',
                  onSelected: (bool _) => setState(() => gender = 'F'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text('${tr('admission_date')}: ${fmtDate(admission)}'),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(tr('save'), style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class StudentDetail extends StatelessWidget {
  final String id;
  const StudentDetail({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, Widget? _) {
        final Student? s = store.studentById(id);
        if (s == null) return const Scaffold();
        return Scaffold(
          appBar: blueAppBar(
            tr('student_details'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: tr('edit'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (BuildContext _) => StudentForm(student: s)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: tr('delete'),
                onPressed: () async {
                  final bool ok = await confirmDialog(context, tr('delete'), tr('confirm_delete_student'));
                  if (ok) {
                    store.deleteStudent(s.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(14),
            children: <Widget>[
              _HeaderCard(name: s.name, line: '${store.className(s.classId)}  •  ${tr('roll')}: ${s.rollNo.isEmpty ? '-' : s.rollNo}'),
              const SizedBox(height: 10),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: <Widget>[
                      InfoRow(Icons.man, tr('father_name'), s.fatherName),
                      InfoRow(Icons.woman, tr('mother_name'), s.motherName),
                      InfoRow(Icons.phone, tr('parent_phone'), s.phone),
                      InfoRow(Icons.home, tr('address'), s.address),
                      InfoRow(Icons.wc, tr('gender'), s.gender == 'F' ? tr('female') : tr('male')),
                      InfoRow(Icons.calendar_today, tr('admission_date'), fmtDate(s.admissionDate)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MonthAttendanceCard(isTeacher: false, personId: s.id),
            ],
          ),
        );
      },
    );
  }
}

// =====================================================================
//  Teachers
// =====================================================================

class TeachersTab extends StatefulWidget {
  const TeachersTab({super.key});

  @override
  State<TeachersTab> createState() => _TeachersTabState();
}

class _TeachersTabState extends State<TeachersTab> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, Widget? _) {
        final String q = query.trim().toLowerCase();
        final List<Teacher> list = store.teachers.where((Teacher t) {
          if (q.isEmpty) return true;
          return t.name.toLowerCase().contains(q) ||
              t.subject.toLowerCase().contains(q) ||
              t.phone.contains(q);
        }).toList();
        list.sort((Teacher a, Teacher b) => a.name.compareTo(b.name));

        return Scaffold(
          appBar: blueAppBar('${tr('teachers')} (${store.teachers.length})'),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (BuildContext _) => const TeacherForm()),
            ),
            icon: const Icon(Icons.person_add),
            label: Text(tr('add_teacher')),
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: TextField(
                  onChanged: (String v) => setState(() => query = v),
                  decoration: InputDecoration(
                    hintText: tr('search'),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? EmptyState(Icons.person_outline, store.teachers.isEmpty ? tr('no_teachers') : tr('no_results'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: list.length,
                        itemBuilder: (BuildContext context, int i) {
                          final Teacher t = list[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: ListTile(
                              leading: Avatar(t.name),
                              title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${tr('subject')}: ${t.subject.isEmpty ? '-' : t.subject}\n'
                                '${tr('phone')}: ${t.phone.isEmpty ? '-' : t.phone}',
                              ),
                              isThreeLine: true,
                              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(builder: (BuildContext _) => TeacherDetail(id: t.id)),
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

class TeacherForm extends StatefulWidget {
  final Teacher? teacher;
  const TeacherForm({super.key, this.teacher});

  @override
  State<TeacherForm> createState() => _TeacherFormState();
}

class _TeacherFormState extends State<TeacherForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController subject;
  late final TextEditingController phone;
  late final TextEditingController qualification;
  late final TextEditingController address;
  String gender = 'M';
  String joinDate = '';

  @override
  void initState() {
    super.initState();
    final Teacher? t = widget.teacher;
    name = TextEditingController(text: t?.name ?? '');
    subject = TextEditingController(text: t?.subject ?? '');
    phone = TextEditingController(text: t?.phone ?? '');
    qualification = TextEditingController(text: t?.qualification ?? '');
    address = TextEditingController(text: t?.address ?? '');
    gender = t?.gender ?? 'M';
    joinDate = (t != null && t.joinDate.isNotEmpty) ? t.joinDate : dateKey(DateTime.now());
  }

  @override
  void dispose() {
    name.dispose();
    subject.dispose();
    phone.dispose();
    qualification.dispose();
    address.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime initial = parseKey(joinDate) ?? DateTime.now();
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => joinDate = dateKey(d));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final Teacher? existing = widget.teacher;
    if (existing == null) {
      store.addTeacher(Teacher(
        id: store.newId(),
        name: name.text.trim(),
        subject: subject.text.trim(),
        phone: phone.text.trim(),
        qualification: qualification.text.trim(),
        address: address.text.trim(),
        gender: gender,
        joinDate: joinDate,
      ));
    } else {
      existing.name = name.text.trim();
      existing.subject = subject.text.trim();
      existing.phone = phone.text.trim();
      existing.qualification = qualification.text.trim();
      existing.address = address.text.trim();
      existing.gender = gender;
      existing.joinDate = joinDate;
      store.updateTeacher(existing);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool editing = widget.teacher != null;
    return Scaffold(
      appBar: blueAppBar(editing ? tr('edit_teacher') : tr('add_teacher')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: tr('teacher_name'),
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
              ),
              validator: (String? v) => (v == null || v.trim().isEmpty) ? tr('err_required') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: subject,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: tr('subject'),
                prefixIcon: const Icon(Icons.menu_book),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: qualification,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: tr('qualification'),
                prefixIcon: const Icon(Icons.workspace_premium),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: tr('phone'),
                prefixIcon: const Icon(Icons.phone),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: address,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: tr('address'),
                prefixIcon: const Icon(Icons.home),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(tr('gender'), style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: <Widget>[
                ChoiceChip(
                  label: Text(tr('male')),
                  selected: gender == 'M',
                  onSelected: (bool _) => setState(() => gender = 'M'),
                ),
                ChoiceChip(
                  label: Text(tr('female')),
                  selected: gender == 'F',
                  onSelected: (bool _) => setState(() => gender = 'F'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text('${tr('join_date')}: ${fmtDate(joinDate)}'),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(tr('save'), style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class TeacherDetail extends StatelessWidget {
  final String id;
  const TeacherDetail({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, Widget? _) {
        final Teacher? t = store.teacherById(id);
        if (t == null) return const Scaffold();
        return Scaffold(
          appBar: blueAppBar(
            tr('teacher_details'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: tr('edit'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (BuildContext _) => TeacherForm(teacher: t)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: tr('delete'),
                onPressed: () async {
                  final bool ok = await confirmDialog(context, tr('delete'), tr('confirm_delete_teacher'));
                  if (ok) {
                    store.deleteTeacher(t.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(14),
            children: <Widget>[
              _HeaderCard(name: t.name, line: t.subject.isEmpty ? tr('teachers') : t.subject),
              const SizedBox(height: 10),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: <Widget>[
                      InfoRow(Icons.menu_book, tr('subject'), t.subject),
                      InfoRow(Icons.workspace_premium, tr('qualification'), t.qualification),
                      InfoRow(Icons.phone, tr('phone'), t.phone),
                      InfoRow(Icons.home, tr('address'), t.address),
                      InfoRow(Icons.wc, tr('gender'), t.gender == 'F' ? tr('female') : tr('male')),
                      InfoRow(Icons.calendar_today, tr('join_date'), fmtDate(t.joinDate)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MonthAttendanceCard(isTeacher: true, personId: t.id),
            ],
          ),
        );
      },
    );
  }
}

// =====================================================================
//  Shared pieces
// =====================================================================

class _HeaderCard extends StatelessWidget {
  final String name;
  final String line;
  const _HeaderCard({required this.name, required this.line});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF42A5F5), Color(0xFF0D47A1)],
        ),
      ),
      child: Row(
        children: <Widget>[
          Avatar(name, size: 60),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(line, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Month-by-month attendance summary for one person.
class MonthAttendanceCard extends StatefulWidget {
  final bool isTeacher;
  final String personId;
  const MonthAttendanceCard({super.key, required this.isTeacher, required this.personId});

  @override
  State<MonthAttendanceCard> createState() => _MonthAttendanceCardState();
}

class _MonthAttendanceCardState extends State<MonthAttendanceCard> {
  int year = DateTime.now().year;
  int month = DateTime.now().month;

  void _shift(int delta) {
    setState(() {
      final DateTime d = DateTime(year, month + delta, 1);
      year = d.year;
      month = d.month;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<int> st = store.monthStats(widget.isTeacher, widget.personId, year, month);
    final int days = daysInMonth(year, month);
    final List<Widget> rows = <Widget>[];
    for (int d = days; d >= 1; d--) {
      final String key = '$year-${two(month)}-${two(d)}';
      final String s = store.statusOf(widget.isTeacher, key, widget.personId);
      if (s.isEmpty) continue;
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            Text(fmtDate(key)),
            const Spacer(),
            Pill(statusName(s), statusColor(s)),
          ],
        ),
      ));
    }
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(tr('attendance'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => _shift(-1)),
                Text('${monthName(month)} $year', style: const TextStyle(fontWeight: FontWeight.w600)),
                IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 18), onPressed: () => _shift(1)),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: <Widget>[
                Pill('${tr('present')}: ${st[0]}', kGreen),
                Pill('${tr('absent')}: ${st[1]}', kRed),
                Pill('${tr('leave')}: ${st[2]}', kOrange),
                Pill('${tr('percent')}: ${percentText(st[0], st[1], st[2])}', kBlue),
              ],
            ),
            const SizedBox(height: 10),
            if (rows.isEmpty)
              Text(tr('no_records'), style: const TextStyle(color: Colors.black54))
            else
              ...rows,
          ],
        ),
      ),
    );
  }
}
