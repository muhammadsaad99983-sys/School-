// Every piece of text in the app lives here: [urdu, english].

String _lang = 'ur';

void setLang(String l) {
  _lang = l;
}

String tr(String key) {
  final List<String>? v = _t[key];
  if (v == null) return key;
  return _lang == 'en' ? v[1] : v[0];
}

const List<String> _monthsUr = <String>[
  'جنوری', 'فروری', 'مارچ', 'اپریل', 'مئی', 'جون',
  'جولائی', 'اگست', 'ستمبر', 'اکتوبر', 'نومبر', 'دسمبر',
];
const List<String> _monthsEn = <String>[
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
// DateTime.weekday: Monday = 1 ... Sunday = 7
const List<String> _daysUr = <String>[
  'پیر', 'منگل', 'بدھ', 'جمعرات', 'جمعہ', 'ہفتہ', 'اتوار',
];
const List<String> _daysEn = <String>[
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

String monthName(int m) {
  final int i = (m - 1) % 12;
  return _lang == 'en' ? _monthsEn[i] : _monthsUr[i];
}

String weekdayName(int w) {
  final int i = (w - 1) % 7;
  return _lang == 'en' ? _daysEn[i] : _daysUr[i];
}

const Map<String, List<String>> _t = <String, List<String>>{
  // general
  'app_name': <String>['اسکول مینیجر', 'School Manager'],
  'yes': <String>['ہاں', 'Yes'],
  'cancel': <String>['منسوخ', 'Cancel'],
  'save': <String>['محفوظ کریں', 'Save'],
  'edit': <String>['ترمیم', 'Edit'],
  'delete': <String>['حذف کریں', 'Delete'],
  'search': <String>['تلاش کریں', 'Search'],
  'all': <String>['سب', 'All'],
  'total': <String>['کل', 'Total'],
  'percent': <String>['فیصد', 'Percent'],
  'start': <String>['شروع کریں', 'Get started'],
  'version': <String>['ورژن 1.0.0', 'Version 1.0.0'],
  'about': <String>['ایپ کے بارے میں', 'About'],
  'about_text': <String>[
    'طلبہ، اساتذہ اور حاضری کے انتظام کے لیے مکمل اسکول مینجمنٹ ایپ۔ تمام ڈیٹا آپ کے فون میں محفوظ رہتا ہے۔',
    'A complete school management app for students, teachers and attendance. All data stays on your phone.',
  ],

  // navigation
  'nav_home': <String>['ہوم', 'Home'],
  'nav_students': <String>['طلبہ', 'Students'],
  'nav_teachers': <String>['اساتذہ', 'Teachers'],
  'nav_attendance': <String>['حاضری', 'Attendance'],
  'nav_more': <String>['مزید', 'More'],

  // setup / login
  'welcome': <String>['خوش آمدید', 'Welcome'],
  'setup_hint': <String>[
    'اپنے اسکول کا نام لکھیں۔ چاہیں تو 4 ہندسوں کا پن بھی لگا لیں۔',
    'Enter your school name. You can also set a 4-digit PIN.',
  ],
  'school_name': <String>['اسکول کا نام', 'School name'],
  'pin_optional': <String>['پن (4 ہندسے، اختیاری)', 'PIN (4 digits, optional)'],
  'pin_confirm': <String>['پن دوبارہ لکھیں', 'Confirm PIN'],
  'enter_pin': <String>['اپنا پن لکھیں', 'Enter your PIN'],
  'wrong_pin': <String>['پن غلط ہے', 'Wrong PIN'],
  'err_school_name': <String>['اسکول کا نام لکھیں', 'Please enter the school name'],
  'err_pin_len': <String>['پن 4 ہندسوں کا ہونا چاہیے', 'PIN must be 4 digits'],
  'err_pin_match': <String>['دونوں پن ایک جیسے نہیں ہیں', 'PINs do not match'],

  // dashboard
  'total_students': <String>['کل طلبہ', 'Total students'],
  'total_teachers': <String>['کل اساتذہ', 'Total teachers'],
  'classes': <String>['کلاسیں', 'Classes'],
  'students_present_today': <String>['آج حاضر طلبہ', 'Students present today'],
  'today_summary': <String>['آج کی حاضری', "Today's attendance"],
  'quick_actions': <String>['فوری کام', 'Quick actions'],
  'mark_students': <String>['طلبہ کی حاضری', 'Student attendance'],
  'mark_teachers': <String>['اساتذہ کی حاضری', 'Teacher attendance'],

  // people
  'students': <String>['طلبہ', 'Students'],
  'teachers': <String>['اساتذہ', 'Teachers'],
  'add_student': <String>['نیا طالب علم', 'Add student'],
  'edit_student': <String>['طالب علم کی ترمیم', 'Edit student'],
  'student_details': <String>['طالب علم کی تفصیل', 'Student details'],
  'add_teacher': <String>['نیا استاد', 'Add teacher'],
  'edit_teacher': <String>['استاد کی ترمیم', 'Edit teacher'],
  'teacher_details': <String>['استاد کی تفصیل', 'Teacher details'],
  'student_name': <String>['طالب علم کا نام', 'Student name'],
  'teacher_name': <String>['استاد کا نام', 'Teacher name'],
  'father_name': <String>['والد کا نام', "Father's name"],
  'mother_name': <String>['والدہ کا نام', "Mother's name"],
  'father': <String>['والد', 'Father'],
  'parent_phone': <String>['والدین کا فون نمبر', "Parent's phone"],
  'phone': <String>['فون نمبر', 'Phone'],
  'roll_no': <String>['رول نمبر', 'Roll number'],
  'roll': <String>['رول', 'Roll'],
  'address': <String>['پتہ', 'Address'],
  'class': <String>['کلاس', 'Class'],
  'gender': <String>['جنس', 'Gender'],
  'male': <String>['مرد / لڑکا', 'Male'],
  'female': <String>['عورت / لڑکی', 'Female'],
  'admission_date': <String>['داخلے کی تاریخ', 'Admission date'],
  'join_date': <String>['تقرری کی تاریخ', 'Joining date'],
  'subject': <String>['مضمون', 'Subject'],
  'qualification': <String>['تعلیمی قابلیت', 'Qualification'],
  'no_students': <String>['ابھی کوئی طالب علم درج نہیں۔ نیچے والے بٹن سے شامل کریں۔', 'No students yet. Tap the button below to add one.'],
  'no_teachers': <String>['ابھی کوئی استاد درج نہیں۔ نیچے والے بٹن سے شامل کریں۔', 'No teachers yet. Tap the button below to add one.'],
  'no_results': <String>['کوئی نتیجہ نہیں ملا', 'No results found'],
  'err_required': <String>['یہ خانہ ضروری ہے', 'This field is required'],
  'err_choose_class': <String>['پہلے کلاس منتخب کریں یا نئی کلاس بنائیں', 'Choose a class first or create a new one'],
  'confirm_delete_student': <String>['کیا آپ اس طالب علم اور اس کی حاضری کو حذف کرنا چاہتے ہیں؟', 'Delete this student and their attendance?'],
  'confirm_delete_teacher': <String>['کیا آپ اس استاد اور اس کی حاضری کو حذف کرنا چاہتے ہیں؟', 'Delete this teacher and their attendance?'],

  // classes
  'new_class': <String>['نئی کلاس', 'New class'],
  'rename_class': <String>['کلاس کا نام بدلیں', 'Rename class'],
  'no_classes_hint': <String>['پہلے "مزید" میں جا کر کلاسیں بنائیں، مثلاً پہلی، دوسری', 'First create classes from "More", for example Class 1, Class 2'],
  'err_class_not_empty': <String>['اس کلاس میں طلبہ موجود ہیں، پہلے انہیں دوسری کلاس میں منتقل کریں', 'This class still has students. Move them first.'],
  'confirm_delete_class': <String>['کیا آپ اس کلاس کو حذف کرنا چاہتے ہیں؟', 'Delete this class?'],

  // attendance
  'attendance': <String>['حاضری', 'Attendance'],
  'present': <String>['حاضر', 'Present'],
  'absent': <String>['غیر حاضر', 'Absent'],
  'leave': <String>['رخصت', 'Leave'],
  'unmarked': <String>['نہیں لگی', 'Unmarked'],
  'p_short': <String>['ح', 'P'],
  'a_short': <String>['غ', 'A'],
  'l_short': <String>['ر', 'L'],
  'mark_all_present': <String>['سب کو حاضر لگائیں', 'Mark all present'],
  'no_students_in_class': <String>['اس کلاس میں ابھی کوئی طالب علم نہیں', 'No students in this class yet'],
  'no_records': <String>['کوئی ریکارڈ نہیں', 'No records'],

  // reports
  'reports': <String>['رپورٹس', 'Reports'],
  'reports_hint': <String>['ماہانہ حاضری کی رپورٹ', 'Monthly attendance report'],
  'copy_report': <String>['رپورٹ کاپی کریں', 'Copy report'],
  'copied': <String>['کاپی ہو گیا، اب کہیں بھی پیسٹ کر سکتے ہیں', 'Copied. You can paste it anywhere.'],

  // settings
  'settings': <String>['سیٹنگز', 'Settings'],
  'settings_hint': <String>['زبان، پن، بیک اپ', 'Language, PIN, backup'],
  'language': <String>['زبان', 'Language'],
  'set_pin': <String>['پن لگائیں', 'Set PIN'],
  'change_pin': <String>['پن تبدیل کریں', 'Change PIN'],
  'new_pin': <String>['نیا پن (4 ہندسے)', 'New PIN (4 digits)'],
  'pin_on': <String>['پن فعال ہے', 'PIN is on'],
  'pin_off': <String>['پن بند ہے', 'PIN is off'],
  'pin_saved': <String>['پن محفوظ ہو گیا', 'PIN saved'],
  'remove_pin': <String>['پن ہٹائیں', 'Remove PIN'],
  'confirm_remove_pin': <String>['کیا آپ پن ہٹانا چاہتے ہیں؟', 'Remove the PIN?'],
  'backup': <String>['بیک اپ بنائیں', 'Create backup'],
  'backup_hint': <String>['سارا ڈیٹا کاپی ہو جائے گا، اسے واٹس ایپ یا نوٹس میں پیسٹ کر کے محفوظ کر لیں', 'Copies all data. Paste it into WhatsApp or Notes to keep it safe.'],
  'backup_done': <String>['بیک اپ کاپی ہو گیا۔ اب اسے کہیں پیسٹ کر کے محفوظ کر لیں', 'Backup copied. Paste it somewhere safe.'],
  'restore': <String>['بیک اپ بحال کریں', 'Restore backup'],
  'restore_sub': <String>['پرانا بیک اپ واپس لائیں', 'Bring back an old backup'],
  'restore_hint': <String>['بیک اپ کا متن یہاں پیسٹ کریں۔ موجودہ ڈیٹا بدل جائے گا۔', 'Paste the backup text here. Current data will be replaced.'],
  'paste': <String>['پیسٹ', 'Paste'],
  'restore_ok': <String>['بیک اپ بحال ہو گیا', 'Backup restored'],
  'restore_fail': <String>['بیک اپ کا متن درست نہیں', 'The backup text is not valid'],
  'clear_all': <String>['سارا ڈیٹا حذف کریں', 'Delete all data'],
  'clear_all_hint': <String>['طلبہ، اساتذہ اور حاضری سب مٹ جائے گا', 'Removes students, teachers and attendance'],
  'confirm_clear_all': <String>['کیا آپ واقعی سارا ڈیٹا حذف کرنا چاہتے ہیں؟ یہ واپس نہیں ہو سکے گا۔', 'Delete ALL data? This cannot be undone.'],
  'cleared': <String>['سارا ڈیٹا حذف ہو گیا', 'All data deleted'],
};
