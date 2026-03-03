/// API endpoints va konfiguratsiyalar
class ApiConstants {
  ApiConstants._();

  // Base URL (dart-define: --dart-define=API_BASE_URL=https://...)
  // Local development uchun default URL (Android emulator → host localhost)
  // Production: --dart-define=API_BASE_URL=https://ranchschool.izlash.uz
  static const String _defaultBaseUrl = 'http://10.0.2.2:8000';
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );
  static String get baseUrl => _envBaseUrl.isEmpty ? _defaultBaseUrl : _envBaseUrl;

  // Timeout durations (milliseconds)
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // ─── Auth (Tenant OAS) ───
  static const String login = '/api/login';
  static const String logout = '/api/logout';
  static const String me = '/api/me';
  static const String forgotPassword = '/api/forgot-password';
  static const String resetPassword = '/api/reset-password';
  static const String qrLogin = '/api/qr-login';

  // ─── Parent (Tenant OAS) ───
  static const String parentChildren = '/api/parent/children';
  static String parentChildProfile(int studentId) =>
      '/api/parent/children/$studentId';
  static const String parentHomeworks = '/api/parent/homeworks';
  static String parentHomeworkDetails(int homeworkId) =>
      '/api/parent/homeworks/$homeworkId';
  static String parentHomeworkSubmit(int homeworkId) =>
      '/api/parent/homeworks/$homeworkId/submit';
  static const String parentTimetable = '/api/parent/timetable';
  static const String parentMeals = '/api/parent/meals';
  static const String parentPayments = '/api/parent/payments';
  static const String parentChatContacts = '/api/parent/chat/contacts';
  static String parentChatMessages(int userId) =>
      '/api/parent/chat/messages/$userId';
  static const String parentSendChatMessage = '/api/parent/chat/messages';

  // ─── User & Children (app aliases) ───
  static const String profile = me;
  static const String children = parentChildren;
  static String childDetails(int id) => parentChildProfile(id);

  // ─── Academics ───
  // Parent OAS grades/attendance/rating ni alohida endpoint qilib bermaydi;
  // child profile/timetable/homeworks dan derivation qilinadi.
  static String grades(int childId) => parentChildProfile(childId);
  static String schedule(int childId) =>
      parentTimetable; // childId queryda ketadi
  static String assignments(int childId) =>
      parentHomeworks; // childId queryda ketadi
  static String attendance(int childId) => parentChildProfile(childId);
  static String childRating(int childId) => parentChildProfile(childId);

  // ─── Assignments ───
  static String submitAssignment(int id) => parentHomeworkSubmit(id);

  // ─── Payments ───
  static const String balance = parentPayments;
  static const String paymentHistory = parentPayments;

  // ─── Menu ───
  static const String dailyMenu = parentMeals;

  // ─── Chat ───
  static const String conversations = parentChatContacts;
  static String messages(int conversationId) =>
      parentChatMessages(conversationId);
  static String sendMessage(int conversationId) => parentSendChatMessage;

  // ─── Notifications (tenant OAS'da yo'q, optional integration) ───
  static const String notifications = '/api/notifications';
  static String markAsRead(String id) => '/api/notifications/$id/read';
  static const String saveFcmToken = '/api/notifications/token';

  // ─── Profile & Password ───
  static const String parentUpdateProfile = '/api/parent/profile';
  static const String parentUploadAvatar = '/api/parent/avatar';
  static const String parentChangePassword = '/api/parent/password';

  // ─── Chat Files ───
  static const String parentChatFiles = '/api/parent/chat/files';

  // ─── Online Payment ───
  static const String createPayment = '/api/parent/payments/create';

  // ─── Pagination ───
  static const int defaultPageSize = 20;
}
