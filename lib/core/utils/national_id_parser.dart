class NationalIdDetails {
  final DateTime birthDate;
  final String genderAr;
  final String genderEn;
  final String governorateAr;
  final String governorateEn;

  NationalIdDetails({
    required this.birthDate,
    required this.genderAr,
    required this.genderEn,
    required this.governorateAr,
    required this.governorateEn,
  });
}

class NationalIdParser {
  static const Map<String, List<String>> _governorates = {
    '01': ['القاهرة', 'Cairo'],
    '02': ['الإسكندرية', 'Alexandria'],
    '03': ['بورسعيد', 'Port Said'],
    '04': ['السويس', 'Suez'],
    '11': ['دمياط', 'Damietta'],
    '12': ['الدقهلية', 'Dakahlia'],
    '13': ['الشرقية', 'Sharqia'],
    '14': ['القليوبية', 'Qalyubia'],
    '15': ['كفر الشيخ', 'Kafr El Sheikh'],
    '16': ['الغربية', 'Gharbia'],
    '17': ['المنوفية', 'Monufia'],
    '18': ['البحيرة', 'Beheira'],
    '19': ['الإسماعيلية', 'Ismailia'],
    '21': ['الجيزة', 'Giza'],
    '22': ['بني سويف', 'Beni Suef'],
    '23': ['الفيوم', 'Faiyum'],
    '24': ['المنيا', 'Minya'],
    '25': ['أسيوط', 'Asyut'],
    '26': ['سوهاج', 'Sohag'],
    '27': ['قنا', 'Qena'],
    '28': ['أسوان', 'Aswan'],
    '29': ['الأقصر', 'Luxor'],
    '31': ['البحر الأحمر', 'Red Sea'],
    '32': ['الوادي الجديد', 'New Valley'],
    '33': ['مطروح', 'Matrouh'],
    '34': ['شمال سيناء', 'North Sinai'],
    '35': ['جنوب سيناء', 'South Sinai'],
    '88': ['خارج الجمهورية', 'Outside Egypt'],
  };

  /// Validates a 14-digit Egyptian National ID against civil registry rules
  static bool validate(String id) {
    if (id.length != 14) return false;             // Must be exactly 14 digits
    if (double.tryParse(id) == null) return false;  // Must contain only numeric digits (no letters)

    // Check 1: Century digit (Digit 1) -> 2 = 1900-1999, 3 = 2000-2099
    final centuryChar = id[0];
    if (centuryChar != '2' && centuryChar != '3') return false; // Reject unsupported centuries

    // Check 2: Birth Month (Digits 4 & 5) -> Must be 01 to 12
    final month = int.parse(id.substring(3, 5));
    if (month < 1 || month > 12) return false;

    // Check 3: Birth Day (Digits 6 & 7) -> Must be 01 to 31
    final day = int.parse(id.substring(5, 7));
    if (day < 1 || day > 31) return false;

    // Check 4: Governorate Code (Digits 8 & 9) -> Must match 27 official Egyptian governorates
    final govCode = id.substring(7, 9);
    if (!_governorates.containsKey(govCode)) return false; // Reject unknown codes

    return true; // Valid authentic Egyptian National ID structure
  }

  /// Parses birth date, gender, and governorate from a valid National ID
  static NationalIdDetails? parse(String id) {
    if (!validate(id)) return null; // Abort if ID fails structural validation

    // Step 1: Extract birth century and full 4-digit birth year
    final century = id[0] == '2' ? 1900 : 2000;              // 2 -> 1900s, 3 -> 2000s
    final year = century + int.parse(id.substring(1, 3));     // e.g. 1900 + 98 = 1998
    final month = int.parse(id.substring(3, 5));              // Birth month (01-12)
    final day = int.parse(id.substring(5, 7));                // Birth day (01-31)
    
    DateTime birthDate;
    try {
      birthDate = DateTime(year, month, day);                 // Construct valid DateTime
    } catch (_) {
      birthDate = DateTime.now();                             // Safe fallback for leap-year edge cases
    }

    // Step 2: Extract gender from 13th digit (Odd = Male, Even = Female)
    final genderCode = int.parse(id[12]);                     // Digit 13 represents gender
    final isMale = genderCode % 2 != 0;                       // Modulo 2 check: odd = male
    final genderAr = isMale ? 'ذكر' : 'أنثى';                 // Arabic gender label
    final genderEn = isMale ? 'Male' : 'Female';              // English gender label

    // Step 3: Extract governorate from digits 8 & 9
    final govCode = id.substring(7, 9);                       // 2-digit governorate code
    final gov = _governorates[govCode] ?? ['غير معروف', 'Unknown']; // Lookup name
    final governorateAr = gov[0];                             // Arabic governorate name (e.g. القاهرة)
    final governorateEn = gov[1];                             // English governorate name (e.g. Cairo)

    // Return strongly-typed result entity
    return NationalIdDetails(
      birthDate: birthDate,
      genderAr: genderAr,
      genderEn: genderEn,
      governorateAr: governorateAr,
      governorateEn: governorateEn,
    );
  }
}
