# هيكل قاعدة بيانات Firebase لتطبيق كورة تيم

## المستخدمون (Users)
- uid
- الاسم
- البريد الإلكتروني
- رقم الهاتف
- صورة الملف الشخصي
- الموقع
- الفرق التي ينتمي إليها
- تقييم المستخدم
- نوع الحساب (لاعب/صاحب ملعب)

## الملاعب (Fields)
- fieldId
- اسم الملعب
- الموقع (إحداثيات)
- صاحب الملعب (uid)
- الصور والفيديوهات
- الأسعار
- جدول المواعيد
- التقييمات والمراجعات
- تحديثات صاحب الملعب

## الفرق (Teams)
- teamId
- اسم الفريق
- أعضاء الفريق (uids)
- مباريات الفريق
- صورة الفريق

## المباريات (Matches)
- matchId
- الفريقان المشاركان
- تاريخ ووقت المباراة
- الملعب
- حالة الحجز
- المشاركون
- نتائج المباراة

## الحجوزات (Bookings)
- bookingId
- المستخدم
- الملعب
- الوقت
- حالة الحجز

## التقييمات والمراجعات (Ratings & Reviews)
- reviewId
- المستخدم
- الملعب
- التقييم
- نص المراجعة
- تاريخ

---

# Firebase Database Structure for Korateem

- All collections and documents are fully in Arabic for cultural relevance.
- Modular, scalable, and ready for production.
- Authentication via Firebase Auth.
- Media via Firebase Storage.
- Real-time updates via Firestore.
