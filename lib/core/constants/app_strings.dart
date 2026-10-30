class AppStrings {
  static const String appName = 'طابوري';
  static const String appNameEn = 'Taboori';

  // We can access localizations by calling translations[localeCode][key]
  static const Map<String, Map<String, String>> translations = {
    'ar': {
      'appName': 'طابوري',
      'appSubtitle': 'نظام إدارة طوابير وأسرة المستشفيات الحكومية',
      'rolePatient': 'مريض / زائر',
      'roleStaff': 'طاقم طبي (طبيب / ممرض / موظف)',
      'roleAdmin': 'مسؤول / وزارة الصحة',
      'selectRole': 'اختر نوع الحساب',
      'welcomeBack': 'مرحباً بك مجدداً',
      'loginDescription': 'سجل دخولك لتتبع دورك في الطابور أو إدارة الأسرة',
      
      // Fields
      'nationalId': 'الرقم القومي (14 رقم)',
      'nationalIdError': 'الرقم القومي يجب أن يتكون من 14 رقماً صحيحاً',
      'phone': 'رقم الهاتف المحمول',
      'phoneError': 'برجاء إدخال رقم هاتف صحيح',
      'name': 'الاسم الكامل',
      'nameError': 'الاسم الكامل مطلوب',
      'email': 'البريد الإلكتروني',
      'emailError': 'برجاء إدخال بريد إلكتروني صحيح',
      'password': 'كلمة المرور',
      'passwordError': 'كلمة المرور يجب أن لا تقل عن 6 أحرف',
      'hospital': 'المستشفى',
      'department': 'القسم / التخصص',
      
      // Actions
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب جديد',
      'dontHaveAccount': 'ليس لديك حساب؟ سجل الآن',
      'alreadyHaveAccount': 'لديك حساب بالفعل؟ سجل دخولك',
      'logout': 'تسجيل الخروج',
      'back': 'رجوع',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'book': 'حجز دور الآن',
      'scanQr': 'مسح رمز QR للتسجيل',
      
      // Patient Dashboard
      'patientDashboard': 'لوحة تحكم المريض',
      'activeTickets': 'تذاكر الحجز النشطة',
      'noActiveTickets': 'لا توجد حجوزات نشطة حالياً. احجز دوراً الآن!',
      'hospitalsList': 'دليل المستشفيات والأسرة',
      'searchHospital': 'ابحث عن مستشفى أو محافظة...',
      'icuBeds': 'أسرّة الرعاية المركزة',
      'incubators': 'الحضّانات للأطفال',
      'ventilators': 'أجهزة التنفس الصناعي',
      'generalBeds': 'الأسرة العادية',
      'available': 'متاح',
      'bedsTotal': 'إجمالي الأسرة',
      
      // Queue Detail
      'ticketNumber': 'رقم التذكرة',
      'currentCalled': 'الرقم المستدعى الآن',
      'peopleAhead': 'الأشخاص أمامك',
      'estimatedWait': 'وقت الانتظار المتوقع',
      'minutes': 'دقيقة',
      'scanAtReception': 'يرجى إبراز رمز QR عند مكتب الاستقبال لتأكيد الحضور',
      'bookingConfirmed': 'تم تأكيد حجز دورك بنجاح!',
      'ticketStatusWaiting': 'في الانتظار',
      'ticketStatusActive': 'تم استدعاؤك الآن!',
      'ticketStatusCompleted': 'تمت الخدمة',
      'ticketStatusAbsent': 'غير حاضر',
      'ticketStatusCancelled': 'ملغي',
      
      // Staff Dashboard
      'staffDashboard': 'لوحة تحكم الموظفين',
      'callNext': 'استدعاء المريض التالي',
      'markCompleted': 'إكمال الخدمة',
      'markAbsent': 'تحديد كغير حاضر',
      'queueStatus': 'حالة الطابور الحالي',
      'bedManagement': 'إدارة طاقة المستشفى والأسرة',
      'updateBedCount': 'تعديل عدد الأسرة المتاحة',
      'receptionScanner': 'ماسح الاستقبال',
      'scanSuccess': 'تم تسجيل دخول المريض بنجاح',
      'scanError': 'تذكرة غير صالحة أو منتهية الصلاحية',
      
      // Admin/Ministry Dashboard
      'adminDashboard': 'لوحة المتابعة الوزارية',
      'governorateStats': 'إحصائيات المحافظات',
      'averageWaitTimes': 'متوسط أوقات الانتظار بالدقائق',
      'bedOccupancy': 'نسبة إشغال أسرّة العناية المركزة والحضانات',
      'totalHospitals': 'المستشفيات المسجلة',
      'totalQueueBookings': 'إجمالي الحجوزات اليوم',
      'criticalAlert': 'تنبيه: عجز أسرة رعاية بمحافظة الجيزة!',
      
      // Outside the Box Features
      'aiTriage': 'المساعد الطبي الذكي (أعراضك إيه؟)',
      'aiTriageDesc': 'حدد أعراضك بالعامية لتوجيهك للعيادة الصحيحة ومنع الانتظار الخاطئ',
      'familyHub': 'حساب العائلة ورعاية الوالدين',
      'indoorCompass': 'بوصلة العيادة والاتجاهات الداخلية',
      'nafaqetDawla': 'التأمين الصحي الشامل ونفقة الدولة',
      'bloodBank': 'شبكة فصائل الدم وبلازما الطوارئ',
      'zeroInternetBooking': 'حجز بدون إنترنت (واتساب / SMS)',
    },
    'en': {
      'appName': 'Taboori',
      'appSubtitle': 'Government Hospital Queue & Bed Management System',
      'rolePatient': 'Patient / Visitor',
      'roleStaff': 'Medical Staff (Doctor/Nurse/Staff)',
      'roleAdmin': 'Admin / Ministry of Health',
      'selectRole': 'Select User Role',
      'welcomeBack': 'Welcome Back',
      'loginDescription': 'Log in to track your queue position or manage beds',
      
      // Fields
      'nationalId': 'Egyptian National ID (14 digits)',
      'nationalIdError': 'National ID must be exactly 14 valid digits',
      'phone': 'Mobile Phone Number',
      'phoneError': 'Please enter a valid phone number',
      'name': 'Full Name',
      'nameError': 'Full name is required',
      'email': 'Email Address',
      'emailError': 'Please enter a valid email address',
      'password': 'Password',
      'passwordError': 'Password must be at least 6 characters',
      'hospital': 'Hospital',
      'department': 'Department / Specialty',
      
      // Actions
      'login': 'Login',
      'register': 'Register New Account',
      'dontHaveAccount': 'Don\'t have an account? Sign Up',
      'alreadyHaveAccount': 'Already have an account? Log In',
      'logout': 'Logout',
      'back': 'Back',
      'save': 'Save',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'book': 'Book Queue Turn',
      'scanQr': 'Scan QR to Check-in',
      
      // Patient Dashboard
      'patientDashboard': 'Patient Dashboard',
      'activeTickets': 'Active Queue Tickets',
      'noActiveTickets': 'No active bookings. Book a turn now!',
      'hospitalsList': 'Hospitals & Beds Directory',
      'searchHospital': 'Search hospital or governorate...',
      'icuBeds': 'ICU Beds',
      'incubators': 'Neonatal Incubators',
      'ventilators': 'Ventilators',
      'generalBeds': 'General Beds',
      'available': 'Available',
      'bedsTotal': 'Total Beds',
      
      // Queue Detail
      'ticketNumber': 'Ticket No.',
      'currentCalled': 'Now Serving',
      'peopleAhead': 'People ahead of you',
      'estimatedWait': 'Est. Wait Time',
      'minutes': 'mins',
      'scanAtReception': 'Present this QR code at reception to confirm check-in',
      'bookingConfirmed': 'Your booking was successful!',
      'ticketStatusWaiting': 'Waiting',
      'ticketStatusActive': 'Now Serving!',
      'ticketStatusCompleted': 'Completed',
      'ticketStatusAbsent': 'No Show',
      'ticketStatusCancelled': 'Cancelled',
      
      // Staff Dashboard
      'staffDashboard': 'Staff Control Board',
      'callNext': 'Call Next Patient',
      'markCompleted': 'Mark Completed',
      'markAbsent': 'Mark No Show',
      'queueStatus': 'Current Queue Status',
      'bedManagement': 'Hospital Bed Capacity',
      'updateBedCount': 'Update Available Beds',
      'receptionScanner': 'Reception Scanner',
      'scanSuccess': 'Patient checked in successfully',
      'scanError': 'Invalid or expired ticket',
      
      // Admin/Ministry Dashboard
      'adminDashboard': 'MOH Oversight Board',
      'governorateStats': 'Governorate Stats',
      'averageWaitTimes': 'Average Wait Times (minutes)',
      'bedOccupancy': 'ICU & Incubator Occupancy Rate',
      'totalHospitals': 'Registered Hospitals',
      'totalQueueBookings': 'Total Bookings Today',
      'criticalAlert': 'Alert: Critical bed shortage in Giza Governorate!',
      
      // Outside the Box Features
      'aiTriage': 'AI Dialect Triage (What are your symptoms?)',
      'aiTriageDesc': 'Speak or pick your symptoms to be guided to the right clinic',
      'familyHub': 'Family & Guardian Hub',
      'indoorCompass': 'Clinic Wayfinding & Compass',
      'nafaqetDawla': 'Universal Health Insurance & State Support',
      'bloodBank': 'Critical Blood & Plasma Grid',
      'zeroInternetBooking': 'Zero-Internet Queuing (SMS/WhatsApp)',
    }
  };

  static String get(String key, String locale) {
    return translations[locale]?[key] ?? translations['ar']?[key] ?? key;
  }
}
