/// API endpoints va konfiguratsiyalar
class ApiConstants {
  ApiConstants._();

  // Base URL
  static const String baseUrl = 'https://ranchschool.izlash.uz/api';

  // Timeout durations (milliseconds)
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // ─── Auth ───
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String googleAuth = '/auth/google';

  // ─── User & Children ───
  static const String profile = '/parent/profile';
  static const String updateProfile = '/parent/profile';
  static const String children = '/parent/children';
  static String childDetails(int id) => '/parent/children/$id';

  // ─── School ───
  static const String schoolSettings = '/school/settings';
  static const String schoolTheme = '/school/theme';

  // ─── Academics ───
  static String grades(int childId) => '/parent/children/$childId/grades';
  static String schedule(int childId) => '/parent/children/$childId/schedule';
  static String assignments(int childId) =>
      '/parent/children/$childId/assignments';
  static String attendance(int childId) =>
      '/parent/children/$childId/attendance';
  static String childRating(int childId) =>
      '/parent/children/$childId/rating';

  // ─── Assignments ───
  static String assignmentDetails(int id) => '/assignments/$id';
  static String submitAssignment(int id) => '/assignments/$id/submit';
  static String uploadAssignmentFile(int id) => '/assignments/$id/upload';

  // ─── Payments ───
  static const String balance = '/parent/balance';
  static const String contract = '/parent/contract';
  static const String paymentHistory = '/parent/payments/history';
  static const String createPayment = '/parent/payments/create';
  static const String paymentMethods = '/payments/methods';

  // ─── Menu ───
  static const String dailyMenu = '/menu/daily';
  static const String weeklyMenu = '/menu/weekly';

  // ─── Chat ───
  static const String conversations = '/chat/conversations';
  static String messages(int conversationId) =>
      '/chat/$conversationId/messages';
  static String sendMessage(int conversationId) =>
      '/chat/$conversationId/send';
  static const String uploadChatFile = '/chat/upload';

  // ─── Notifications ───
  static const String notifications = '/notifications';
  static String markAsRead(int id) => '/notifications/$id/read';
  static const String saveFcmToken = '/notifications/token';

  // ─── Rating ───
  static String classRating(int classId) => '/rating/class/$classId';
  static const String schoolRating = '/rating/school';

  // ─── Pagination ───
  static const int defaultPageSize = 20;
}
