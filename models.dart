String _s(Map<String, dynamic> j, String k) => (j[k] ?? '').toString();

String two(int n) => n < 10 ? '0$n' : '$n';

String dateKey(DateTime d) => '${d.year}-${two(d.month)}-${two(d.day)}';

DateTime? parseKey(String s) {
  try {
    final List<String> p = s.split('-');
    if (p.length != 3) return null;
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  } catch (_) {
    return null;
  }
}

String fmtDate(String key) {
  final DateTime? d = parseKey(key);
  if (d == null) return key;
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

class SchoolClass {
  String id;
  String name;

  SchoolClass({required this.id, required this.name});

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'name': name};

  factory SchoolClass.fromJson(Map<String, dynamic> j) =>
      SchoolClass(id: _s(j, 'id'), name: _s(j, 'name'));
}

class Student {
  String id;
  String name;
  String fatherName;
  String motherName;
  String phone;
  String address;
  String classId;
  String rollNo;
  String gender;
  String admissionDate;

  Student({
    required this.id,
    required this.name,
    this.fatherName = '',
    this.motherName = '',
    this.phone = '',
    this.address = '',
    this.classId = '',
    this.rollNo = '',
    this.gender = 'M',
    this.admissionDate = '',
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'fatherName': fatherName,
        'motherName': motherName,
        'phone': phone,
        'address': address,
        'classId': classId,
        'rollNo': rollNo,
        'gender': gender,
        'admissionDate': admissionDate,
      };

  factory Student.fromJson(Map<String, dynamic> j) => Student(
        id: _s(j, 'id'),
        name: _s(j, 'name'),
        fatherName: _s(j, 'fatherName'),
        motherName: _s(j, 'motherName'),
        phone: _s(j, 'phone'),
        address: _s(j, 'address'),
        classId: _s(j, 'classId'),
        rollNo: _s(j, 'rollNo'),
        gender: _s(j, 'gender').isEmpty ? 'M' : _s(j, 'gender'),
        admissionDate: _s(j, 'admissionDate'),
      );
}

class Teacher {
  String id;
  String name;
  String subject;
  String phone;
  String qualification;
  String address;
  String gender;
  String joinDate;

  Teacher({
    required this.id,
    required this.name,
    this.subject = '',
    this.phone = '',
    this.qualification = '',
    this.address = '',
    this.gender = 'M',
    this.joinDate = '',
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'subject': subject,
        'phone': phone,
        'qualification': qualification,
        'address': address,
        'gender': gender,
        'joinDate': joinDate,
      };

  factory Teacher.fromJson(Map<String, dynamic> j) => Teacher(
        id: _s(j, 'id'),
        name: _s(j, 'name'),
        subject: _s(j, 'subject'),
        phone: _s(j, 'phone'),
        qualification: _s(j, 'qualification'),
        address: _s(j, 'address'),
        gender: _s(j, 'gender').isEmpty ? 'M' : _s(j, 'gender'),
        joinDate: _s(j, 'joinDate'),
      );
}
