import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'models.dart';
import 'storage.dart';

class SchoolStore extends ChangeNotifier {
  String schoolName = '';
  String lang = 'ur';
  String pin = '';
  bool setupDone = false;

  List<SchoolClass> classes = <SchoolClass>[];
  List<Student> students = <Student>[];
  List<Teacher> teachers = <Teacher>[];

  // day key -> (person id -> 'P' | 'A' | 'L')
  Map<String, Map<String, String>> studentAtt = <String, Map<String, String>>{};
  Map<String, Map<String, String>> teacherAtt = <String, Map<String, String>>{};

  int _seq = 0;
  Future<void> _chain = Future<void>.value();

  String newId() {
    _seq++;
    return '${DateTime.now().microsecondsSinceEpoch}_$_seq';
  }

  // ---------- load / save ----------

  Future<void> load() async {
    final String? text = await Storage.read();
    if (text != null && text.isNotEmpty) {
      try {
        applyJson(jsonDecode(text));
      } catch (_) {}
    }
  }

  void _save() {
    final String text = jsonEncode(toJson());
    _chain = _chain.then((_) => Storage.write(text));
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'version': 1,
        'schoolName': schoolName,
        'lang': lang,
        'pin': pin,
        'setupDone': setupDone,
        'classes': classes.map((SchoolClass e) => e.toJson()).toList(),
        'students': students.map((Student e) => e.toJson()).toList(),
        'teachers': teachers.map((Teacher e) => e.toJson()).toList(),
        'studentAtt': studentAtt,
        'teacherAtt': teacherAtt,
      };

  Map<String, Map<String, String>> _decodeAtt(dynamic raw) {
    final Map<String, Map<String, String>> out = <String, Map<String, String>>{};
    if (raw is Map) {
      raw.forEach((dynamic k, dynamic v) {
        if (v is Map) {
          final Map<String, String> inner = <String, String>{};
          v.forEach((dynamic a, dynamic b) {
            inner[a.toString()] = b.toString();
          });
          out[k.toString()] = inner;
        }
      });
    }
    return out;
  }

  bool applyJson(dynamic data) {
    if (data is! Map) return false;
    try {
      final List<dynamic> rawC = (data['classes'] as List<dynamic>?) ?? <dynamic>[];
      final List<dynamic> rawS = (data['students'] as List<dynamic>?) ?? <dynamic>[];
      final List<dynamic> rawT = (data['teachers'] as List<dynamic>?) ?? <dynamic>[];

      final List<SchoolClass> c = <SchoolClass>[];
      for (final dynamic e in rawC) {
        c.add(SchoolClass.fromJson(Map<String, dynamic>.from(e as Map)));
      }
      final List<Student> s = <Student>[];
      for (final dynamic e in rawS) {
        s.add(Student.fromJson(Map<String, dynamic>.from(e as Map)));
      }
      final List<Teacher> t = <Teacher>[];
      for (final dynamic e in rawT) {
        t.add(Teacher.fromJson(Map<String, dynamic>.from(e as Map)));
      }
      final Map<String, Map<String, String>> sa = _decodeAtt(data['studentAtt']);
      final Map<String, Map<String, String>> ta = _decodeAtt(data['teacherAtt']);

      classes = c;
      students = s;
      teachers = t;
      studentAtt = sa;
      teacherAtt = ta;
      schoolName = (data['schoolName'] ?? '').toString();
      final String l = (data['lang'] ?? 'ur').toString();
      lang = (l == 'en') ? 'en' : 'ur';
      pin = (data['pin'] ?? '').toString();
      setupDone = data['setupDone'] == true;
      return true;
    } catch (_) {
      return false;
    }
  }

  String exportJson() => jsonEncode(toJson());

  bool importJson(String text) {
    try {
      final dynamic data = jsonDecode(text.trim());
      final bool ok = applyJson(data);
      if (ok) {
        setupDone = true;
        _save();
        notifyListeners();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  void clearAll() {
    classes = <SchoolClass>[];
    students = <Student>[];
    teachers = <Teacher>[];
    studentAtt = <String, Map<String, String>>{};
    teacherAtt = <String, Map<String, String>>{};
    _save();
    notifyListeners();
  }

  // ---------- settings ----------

  void completeSetup(String name, String newPin, String language) {
    schoolName = name.trim();
    pin = newPin;
    lang = language;
    setupDone = true;
    _save();
    notifyListeners();
  }

  void setLang(String l) {
    lang = l;
    _save();
    notifyListeners();
  }

  void setSchoolName(String n) {
    schoolName = n.trim();
    _save();
    notifyListeners();
  }

  void setPin(String p) {
    pin = p;
    _save();
    notifyListeners();
  }

  // ---------- classes ----------

  String addClass(String name) {
    final String id = newId();
    classes.add(SchoolClass(id: id, name: name.trim()));
    _save();
    notifyListeners();
    return id;
  }

  void renameClass(String id, String name) {
    for (final SchoolClass c in classes) {
      if (c.id == id) c.name = name.trim();
    }
    _save();
    notifyListeners();
  }

  int studentCountInClass(String id) =>
      students.where((Student s) => s.classId == id).length;

  /// Returns false when the class still has students.
  bool deleteClass(String id) {
    if (studentCountInClass(id) > 0) return false;
    classes.removeWhere((SchoolClass c) => c.id == id);
    _save();
    notifyListeners();
    return true;
  }

  String className(String id) {
    for (final SchoolClass c in classes) {
      if (c.id == id) return c.name;
    }
    return '-';
  }

  // ---------- students ----------

  Student? studentById(String id) {
    for (final Student s in students) {
      if (s.id == id) return s;
    }
    return null;
  }

  void addStudent(Student s) {
    students.add(s);
    _save();
    notifyListeners();
  }

  void updateStudent(Student s) {
    _save();
    notifyListeners();
  }

  void deleteStudent(String id) {
    students.removeWhere((Student s) => s.id == id);
    _removeFromAtt(studentAtt, id);
    _save();
    notifyListeners();
  }

  // ---------- teachers ----------

  Teacher? teacherById(String id) {
    for (final Teacher t in teachers) {
      if (t.id == id) return t;
    }
    return null;
  }

  void addTeacher(Teacher t) {
    teachers.add(t);
    _save();
    notifyListeners();
  }

  void updateTeacher(Teacher t) {
    _save();
    notifyListeners();
  }

  void deleteTeacher(String id) {
    teachers.removeWhere((Teacher t) => t.id == id);
    _removeFromAtt(teacherAtt, id);
    _save();
    notifyListeners();
  }

  void _removeFromAtt(Map<String, Map<String, String>> att, String id) {
    final List<String> emptyDays = <String>[];
    att.forEach((String day, Map<String, String> m) {
      m.remove(id);
      if (m.isEmpty) emptyDays.add(day);
    });
    for (final String d in emptyDays) {
      att.remove(d);
    }
  }

  // ---------- attendance ----------

  String statusOf(bool teacher, String day, String id) {
    final Map<String, Map<String, String>> att = teacher ? teacherAtt : studentAtt;
    final Map<String, String>? m = att[day];
    if (m == null) return '';
    return m[id] ?? '';
  }

  void setStatus(bool teacher, String day, String id, String status) {
    final Map<String, Map<String, String>> att = teacher ? teacherAtt : studentAtt;
    final Map<String, String> m = att.putIfAbsent(day, () => <String, String>{});
    if (status.isEmpty) {
      m.remove(id);
      if (m.isEmpty) att.remove(day);
    } else {
      m[id] = status;
    }
    _save();
    notifyListeners();
  }

  void markAll(bool teacher, String day, List<String> ids, String status) {
    final Map<String, Map<String, String>> att = teacher ? teacherAtt : studentAtt;
    final Map<String, String> m = att.putIfAbsent(day, () => <String, String>{});
    for (final String id in ids) {
      m[id] = status;
    }
    _save();
    notifyListeners();
  }

  /// [present, absent, leave] for one person in one month.
  List<int> monthStats(bool teacher, String id, int year, int month) {
    final Map<String, Map<String, String>> att = teacher ? teacherAtt : studentAtt;
    final String prefix = '$year-${two(month)}-';
    int p = 0;
    int a = 0;
    int l = 0;
    att.forEach((String day, Map<String, String> m) {
      if (day.startsWith(prefix)) {
        final String? s = m[id];
        if (s == 'P') {
          p++;
        } else if (s == 'A') {
          a++;
        } else if (s == 'L') {
          l++;
        }
      }
    });
    return <int>[p, a, l];
  }

  /// [present, absent, leave] for a whole day over the given people.
  List<int> dayCounts(bool teacher, String day, List<String> ids) {
    int p = 0;
    int a = 0;
    int l = 0;
    for (final String id in ids) {
      final String s = statusOf(teacher, day, id);
      if (s == 'P') {
        p++;
      } else if (s == 'A') {
        a++;
      } else if (s == 'L') {
        l++;
      }
    }
    return <int>[p, a, l];
  }
}

final SchoolStore store = SchoolStore();
