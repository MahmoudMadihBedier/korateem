class AppLocalizations {
  static const Map<String, String> arabicStrings = {
    'app_title': 'كورة تيم',
    'login': 'تسجيل الدخول',
    'signup': 'إنشاء حساب',
    'profile': 'الملف الشخصي',
    'fields': 'الملاعب',
    'teams': 'الفرق',
    'book': 'حجز',
    'join_match': 'انضم للمباراة',
    'owner_portal': 'بوابة صاحب الملعب',
    'rating': 'تقييم',
    'reviews': 'مراجعات',
    'top_fields': 'أفضل الملاعب',
    'discover': 'اكتشف',
    'schedule': 'جدول المباريات',
    'invite': 'دعوة',
    'share': 'مشاركة',
    'logout': 'تسجيل الخروج',
    'location': 'الموقع',
    'price': 'السعر',
    'photos': 'صور',
    'videos': 'فيديوهات',
    'search': 'بحث',
    'edit_profile': 'تعديل الملف الشخصي',
    'create_team': 'إنشاء فريق',
    'join_team': 'انضم لفريق',
    'owner_updates': 'تحديثات صاحب الملعب',
    'booking_success': 'تم الحجز بنجاح',
    'booking_failed': 'فشل الحجز',
    'no_fields_found': 'لا توجد ملاعب قريبة',
    'no_matches': 'لا توجد مباريات',
    'no_teams': 'لا توجد فرق',
    'welcome': 'مرحبًا بك في كورة تيم',
  };

  static String get(String key) {
    return arabicStrings[key] ?? key;
  }
}
