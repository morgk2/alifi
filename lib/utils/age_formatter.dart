class AgeFormatter {
  static String formatAge(double? age) {
    if (age == null) return 'Unknown';
    
    if (age < 0) {
      final months = (-age).toInt();
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else if (age < 1) {
      final months = (age * 12).round();
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else {
      final years = age;
      final displayYears = years == years.toInt() ? years.toInt() : years;
      return '$displayYears ${years == 1 ? 'year' : 'years'}';
    }
  }
}







