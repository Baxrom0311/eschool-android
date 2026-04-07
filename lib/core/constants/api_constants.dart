/// API endpoints va konfiguratsiyalar
class ApiConstants {
  ApiConstants._();

  // Base URL (dart-define: --dart-define=API_BASE_URL=https://...)
  // Production default teacher ilovasi bilan bir xil saqlanadi.
  // Local development: --dart-define=API_BASE_URL=http://10.0.2.2:8000
  static const String _defaultBaseUrl = 'https://ranchschool.izlash.uz';
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );
  static const String _envHostHeader = String.fromEnvironment(
    'API_HOST_HEADER',
    defaultValue: '',
  );
  static String get baseUrl =>
      _envBaseUrl.isEmpty ? _defaultBaseUrl : _envBaseUrl;
  static String? get hostHeader {
    final trimmed = _envHostHeader.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static Map<String, String> get defaultHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final host = hostHeader;
    if (host != null) {
      headers['Host'] = host;
    }
    return headers;
  }

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
  static const String parentGradesQuarter = '/api/parent/grades';
  static const String parentGradesYear = '/api/parent/grades/year';
  static const String parentAttendanceEndpoint = '/api/parent/attendance';
  
  static String grades(int childId) => parentGradesQuarter;
  static String schedule(int childId) => parentTimetable; // childId queryda ketadi
  static String assignments(int childId) => parentHomeworks; // childId queryda ketadi
  static String attendance(int childId) => parentAttendanceEndpoint;
  static String childRating(int childId) => parentChildProfile(childId);

  // ─── Gamification & Leaderboard ───
  static const String leaderboardGlobal = '/api/leaderboard/global';
  static const String leaderboardClass = '/api/leaderboard/class';
  static const String leaderboardCoins = '/api/leaderboard/coins';
  static const String leaderboardBadges = '/api/leaderboard/badges';
  static const String leaderboardMyBadges = '/api/leaderboard/my-badges';

  // ─── Absence Excuses & Conference ───
  static const String absenceExcuses = '/api/excuses';
  static const String submitAbsenceExcuse = '/api/parent/excuses';
  static const String conferenceAvailable = '/api/parent/conferences/available';
  static const String conferenceBook = '/api/parent/conferences/book';
  static const String conferenceMyBookings = '/api/parent/conferences/my-bookings';

  // ─── Library ───
  static const String libraryBooks = '/api/library/books';
  static const String libraryMyLoans = '/api/library/my-loans';
  static String borrowBook(int id) => '/api/library/books/$id/borrow';
  static String returnBook(int id) => '/api/library/loans/$id/return';

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

  // ─── WebSocket (Laravel Reverb) ───
  static const String reverbKey = String.fromEnvironment(
    'REVERB_APP_KEY',
    defaultValue: 'local', // O'zgartirish kerak
  );
  
  static const String reverbHost = String.fromEnvironment(
    'REVERB_HOST',
    defaultValue: 'ranchschool.izlash.uz',
  );
  
  static const int reverbPort = int.fromEnvironment(
    'REVERB_PORT',
    defaultValue: 443,
  );
  
  static const String reverbScheme = String.fromEnvironment(
    'REVERB_SCHEME',
    defaultValue: 'https',
  );

  // ─── Pagination ───
  static const int defaultPageSize = 20;
}
