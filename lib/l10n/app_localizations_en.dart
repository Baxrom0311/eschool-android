// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Ranch School Parent';

  @override
  String get notificationFallbackTitle => 'New notification';

  @override
  String get close => 'Close';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get changeTheme => 'Change theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get loginHeader => 'Login';

  @override
  String get homeScreen => 'Home screen';

  @override
  String get welcome => 'Welcome!';

  @override
  String get loginHint => 'Enter your credentials\nto sign in';

  @override
  String get emailSection => 'PHONE NUMBER';

  @override
  String get passwordSection => 'PASSWORD';

  @override
  String get emailExample => 'Example: 90 123 45 67';

  @override
  String get forgotPasswordShort => 'Forgot password?';

  @override
  String get loginButton => 'Sign in';

  @override
  String get orLabel => 'OR';

  @override
  String get googleLabel => 'Google';

  @override
  String get qrCodeLabel => 'QR Code';

  @override
  String get googleSoon => 'Google sign-in will be available soon';

  @override
  String get accountCreatedByAdmin =>
      'Accounts are created by the administrator';

  @override
  String get registerUnavailableMessage =>
      'The tenant API does not provide a registration endpoint. Accounts are created by the administrator.';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle => 'Set up a new account';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get fullNameRequired => 'Please enter your name';

  @override
  String get phoneNumberLabel => 'Phone number';

  @override
  String get passwordLabel => 'Password';

  @override
  String get createAccountAction => 'Create account';

  @override
  String get haveAccountPrompt => 'Already have an account?';

  @override
  String get qrLoginTitle => 'Sign in with QR code';

  @override
  String get qrInvalidFormat => 'Invalid QR code format';

  @override
  String get qrLoginFailed => 'QR sign-in failed';

  @override
  String get qrScanInstruction => 'Hold the QR code in front of the camera';

  @override
  String get qrAdminInstruction =>
      'Scan the QR code provided by the school administrator';

  @override
  String get profileLoadError => 'Failed to load profile data';

  @override
  String get home => 'Home';

  @override
  String get academics => 'Academics';

  @override
  String get menu => 'Meals';

  @override
  String get paymentShort => 'Payments';

  @override
  String get profile => 'Profile';

  @override
  String get homeTitle => 'E-School';

  @override
  String get academicsTitle => 'Academics';

  @override
  String get retry => 'Retry';

  @override
  String get noData => 'No data';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get backendErrorTitle => 'Backend error';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorServer => 'Server error';

  @override
  String get errorAuth => 'Incorrect login or password';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get phoneRequired => 'Enter a phone number';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get emailRequired => 'Enter a phone number';

  @override
  String get invalidEmail => 'Invalid phone number';

  @override
  String get passwordRequired => 'Enter your password';

  @override
  String get passwordTooShort => 'Password must contain at least 6 characters';

  @override
  String get confirmPasswordRequired => 'Confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get requestTimeout => 'The server timed out. Please try again.';

  @override
  String get requestCancelled => 'Request was cancelled';

  @override
  String get badRequest => 'Bad request';

  @override
  String get forbidden => 'Access denied';

  @override
  String get notFound => 'Data not found';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get notificationsLoadFailed => 'Failed to load notifications';

  @override
  String get chatFallbackTitle => 'Chat';

  @override
  String get userFallbackName => 'User';

  @override
  String get subjectFallbackName => 'Subject';

  @override
  String get teacherLabel => 'Teacher';

  @override
  String get meLabel => 'You';

  @override
  String get groupLabel => 'Group';

  @override
  String get balanceLabel => 'Balance';

  @override
  String get childrenLabel => 'Children';

  @override
  String get myChildrenTitle => 'My children';

  @override
  String get noChildrenFound => 'No children found';

  @override
  String get editProfileTitle => 'Personal information';

  @override
  String get changeAvatarAction => 'Change avatar';

  @override
  String get basicInfoTitle => 'Basic information';

  @override
  String get notificationsToggleTitle => 'Notifications';

  @override
  String get notificationsToggleSubtitle =>
      'Enable or disable push notifications';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully.';

  @override
  String get achievementsTitle => 'Achievements & Badges';

  @override
  String get achievementsSubtitle => 'Gamified ranking';

  @override
  String get conferencesTitle => 'Parent Meetings';

  @override
  String get conferencesSubtitle => 'Schedule a meeting with the teacher';

  @override
  String get absenceAppealTitle => 'E-Request';

  @override
  String get absenceAppealSubtitle => 'Attendance excuses';

  @override
  String get digitalLibraryTitle => 'Digital Library';

  @override
  String get digitalLibrarySubtitle => 'Textbooks and books';

  @override
  String get personalInfoTitle => 'Personal information';

  @override
  String get personalInfoSubtitle => 'Edit your profile';

  @override
  String get passwordChangeTitle => 'Change password';

  @override
  String get passwordChangeSubtitle => 'Security settings';

  @override
  String get chatSupportTitle => 'Chat / Support';

  @override
  String get chatSupportSubtitle => 'Support service';

  @override
  String get notificationSettingsSubtitle => 'Notification settings';

  @override
  String get aboutAppTitle => 'About the app';

  @override
  String get logoutTitle => 'Log out';

  @override
  String get logoutConfirmMessage => 'Do you really want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get logoutAction => 'Log out';

  @override
  String get schoolAppName => 'E-School';

  @override
  String get conferenceTitle => 'Parent meetings';

  @override
  String get selectChildFirst => 'Select a child first';

  @override
  String get conferenceBookedSuccess => 'Meeting scheduled successfully';

  @override
  String get conferenceBookFailed => 'Failed to schedule the meeting';

  @override
  String get invalidMeetingLink => 'The meeting link is invalid';

  @override
  String get openMeetingLinkFailed => 'Failed to open the meeting link';

  @override
  String get conferenceEmpty => 'No meetings have been booked yet';

  @override
  String get scheduleConferenceAction => 'Schedule meeting';

  @override
  String get availableSlotsTitle => 'Available meeting slots';

  @override
  String get noAvailableSlots => 'No available slots found yet';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get bookConferenceAction => 'Schedule meeting';

  @override
  String get absenceTitle => 'E-request (attendance)';

  @override
  String get absenceNeedChild =>
      'Select a child to submit an attendance request.';

  @override
  String get submitRequestAction => 'Create request';

  @override
  String get noRequestsYet => 'No requests yet';

  @override
  String get requestStatusCaption =>
      'Once you submit an excuse request, its status will appear here.';

  @override
  String get noReasonProvided => 'No reason provided';

  @override
  String get fileAttached => 'File attached';

  @override
  String get absenceRequestTitle => 'Create attendance request';

  @override
  String get startDateLabel => 'Start date';

  @override
  String get endDateLabel => 'End date';

  @override
  String get reasonLabel => 'Reason';

  @override
  String get reasonHint => 'Briefly describe the reason';

  @override
  String get attachFile => 'Attach file';

  @override
  String get fileReady => 'File ready';

  @override
  String get reasonRequired => 'Enter the reason';

  @override
  String get requestSubmitted => 'Request submitted';

  @override
  String get requestSubmitFailed => 'Failed to submit the request';

  @override
  String get sendAction => 'Send';

  @override
  String get libraryBooksTab => 'Books';

  @override
  String get libraryMyBooksTab => 'My books';

  @override
  String get librarySearchHint => 'Search books...';

  @override
  String get libraryNoBooksFound => 'No books found';

  @override
  String get libraryUnknownAuthor => 'Unknown author';

  @override
  String get libraryBorrowAction => 'Borrow';

  @override
  String get libraryUnavailableAction => 'Unavailable';

  @override
  String get libraryNoLoans => 'You have no borrowed books';

  @override
  String get libraryUnknownBook => 'Unknown book';

  @override
  String get libraryReturnAction => 'Return';

  @override
  String get libraryReturnedStatus => 'Returned';

  @override
  String get libraryBorrowedSuccess => 'Book reserved!';

  @override
  String get libraryReturnedSuccess => 'Book returned!';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get saveAction => 'Save';

  @override
  String get passwordUpdatedSuccess => 'Password updated successfully!';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordPhoneSubtitle => 'Enter your phone number';

  @override
  String get forgotPasswordCodeSubtitle => 'Enter the code sent via SMS';

  @override
  String get phoneNumberSection => 'PHONE NUMBER';

  @override
  String get sendCodeAction => 'Send code';

  @override
  String get backToLoginAction => 'Back to login';

  @override
  String get verificationCodeSection => 'VERIFICATION CODE';

  @override
  String get verificationCodeHint => '123456';

  @override
  String get codeRequired => 'Enter the code';

  @override
  String get codeLengthInvalid => 'The code must be 6 digits long';

  @override
  String get resetPasswordAction => 'Update password';

  @override
  String get resendCodeAction => 'Send code again';

  @override
  String get verificationCodeSent => 'Verification code sent';

  @override
  String get verificationCodeSendFailed =>
      'Failed to send the verification code';

  @override
  String get passwordResetSuccess => 'Password updated successfully!';

  @override
  String get passwordResetFailed => 'Failed to update the password';

  @override
  String get paymentsTitle => 'Payments';

  @override
  String get accountBalanceTitle => 'Account balance';

  @override
  String get notUpdatedLabel => 'Not updated';

  @override
  String get todayLabel => 'Today';

  @override
  String get yesterdayLabel => 'Yesterday';

  @override
  String get tomorrowLabel => 'Tomorrow';

  @override
  String get justNowLabel => 'Just now';

  @override
  String get noFinancialData => 'No data';

  @override
  String get contractInfoTitle => 'Contract information';

  @override
  String get contractLabel => 'Contract';

  @override
  String get studentLabel => 'Student';

  @override
  String get classLabel => 'Class';

  @override
  String get monthlyPaymentLabel => 'Monthly payment';

  @override
  String get debtExistsTitle => 'ATTENTION';

  @override
  String debtPaymentPrompt(Object amount) {
    return 'An outstanding debt of $amount has been detected. Please make a payment to avoid service interruption.';
  }

  @override
  String get payNowAction => 'Pay now';

  @override
  String get paymentHistoryTitle => 'Payment history';

  @override
  String get paymentHistoryEmpty => 'Payment history is empty';

  @override
  String get paymentMethodTitle => 'Payment method';

  @override
  String get paymentAmountLabel => 'Payment amount (UZS)';

  @override
  String get paymentMethodsPrompt => 'How would you like to pay?';

  @override
  String get paymentAction => 'Proceed to payment';

  @override
  String get paymentAgreementText =>
      'By pressing the button, you agree to the terms of the public offer.';

  @override
  String get paymentAmountInvalid => 'Enter a valid payment amount';

  @override
  String get paymentCreateUnsupported =>
      'Payment creation is not yet supported in the Parent API.';

  @override
  String get paymentRedirectOpenFallback =>
      'Failed to open the app. Please try the link in a browser.';

  @override
  String get paymentLinkOpenFailed => 'Could not open the payment link';

  @override
  String get paymentCreatedNoLink =>
      'Payment was created, but no link was returned';

  @override
  String get allPaymentsFilter => 'All';

  @override
  String get successfulPaymentsFilter => 'Successful';

  @override
  String get rejectedPaymentsFilter => 'Rejected';

  @override
  String get paymentStatusPending => 'Pending';

  @override
  String get paymentStatusCompleted => 'Completed';

  @override
  String get paymentStatusFailed => 'Failed';

  @override
  String get paymentStatusRefunded => 'Refunded';

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodTransfer => 'Transfer';

  @override
  String get currencyCode => 'UZS';

  @override
  String get gradesTab => 'Grades';

  @override
  String get ratingTab => 'Rating';

  @override
  String get todayLessonsSectionTitle => 'Today\'s classes';

  @override
  String get viewAllAction => 'View all';

  @override
  String get noLessonsTodayShort => 'No classes found for today';

  @override
  String get servicesTitle => 'Services';

  @override
  String get conferenceServiceTitle => 'Meeting';

  @override
  String get absenceServiceTitle => 'Absence note';

  @override
  String get libraryServiceTitle => 'Library';

  @override
  String get ratingServiceTitle => 'Rating';

  @override
  String get averageGradeTitle => 'Average grade';

  @override
  String get classRankingTitle => 'Class ranking';

  @override
  String get placeSuffix => 'place';

  @override
  String get attendanceStatLabel => 'Attendance';

  @override
  String get attendanceTitle => 'Attendance statistics';

  @override
  String get attendanceTotalLessonsLabel => 'Total lessons';

  @override
  String get attendancePresentLabel => 'Present';

  @override
  String get attendanceAbsentLabel => 'Unexcused';

  @override
  String get attendancePresentLegend => 'Present';

  @override
  String get attendanceAbsentLegend => 'Absent';

  @override
  String get attendanceLateLegend => 'Late';

  @override
  String get attendanceBackendErrorTitle => 'Backend error';

  @override
  String get coinsStatLabel => 'Coins';

  @override
  String get latestNewsTitle => 'Latest update';

  @override
  String get todayLunchTitle => 'Today\'s lunch';

  @override
  String get todayLunchSubtitle => 'Fresh meals are ready in the cafeteria';

  @override
  String get dailyMenuTitle => 'Meal menu';

  @override
  String get noMenuOnSelectedDay => 'No menu is available for the selected day';

  @override
  String get mealIngredientsTitle => 'Ingredients:';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get chatsEmpty => 'No chats yet';

  @override
  String get noMessageShort => 'No messages';

  @override
  String get ratingTitle => 'Rating';

  @override
  String get classScopeTab => 'Class';

  @override
  String get schoolScopeTab => 'School';

  @override
  String get ratingDataEmpty => 'No data';

  @override
  String get ratingListEmpty => 'No rating data found';

  @override
  String get ratingLoadFailed => 'Failed to load the rating';

  @override
  String get schoolRatingLoadFailed => 'Failed to load the school rating';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardClassTab => 'Class';

  @override
  String get leaderboardSchoolTab => 'School';

  @override
  String get leaderboardBadgesTab => 'Badges';

  @override
  String get leaderboardClassEmpty => 'No class ranking yet';

  @override
  String get leaderboardSchoolEmpty => 'No school ranking yet';

  @override
  String get myBadgesTitle => 'My badges';

  @override
  String get noBadgesYet => 'No badges yet';

  @override
  String get scheduleTitle => 'Class schedule';

  @override
  String get noScheduleAvailable => 'No classes available';

  @override
  String get currentLessonBadge => 'Now';

  @override
  String get noClassLabel => 'No class';

  @override
  String get assignmentsTab => 'Assignments';

  @override
  String get newAssignmentsTab => 'New assignments';

  @override
  String get allAssignmentsTab => 'All';

  @override
  String get assignmentsEmpty => 'No assignments found';

  @override
  String get assignmentStatusPending => 'In progress';

  @override
  String get assignmentStatusSubmitted => 'Submitted';

  @override
  String get assignmentStatusGraded => 'Graded';

  @override
  String get assignmentStatusOverdue => 'Overdue';

  @override
  String get assignmentSubmitAction => 'Submit';

  @override
  String get assignmentSubmitSoon => 'Assignment submission is coming soon...';

  @override
  String get myPerformanceTitle => 'My performance';

  @override
  String get noGradesAvailable => 'No grades available';

  @override
  String get gradesBySubjectTitle => 'By subject';

  @override
  String get averageShortLabel => 'Average';

  @override
  String get overallPerformanceTitle => 'Overall performance';

  @override
  String get overallPerformanceSubtitle =>
      'Your overall result across subjects';

  @override
  String get lessonsStatLabel => 'Lessons';

  @override
  String get assignmentDetailsTitle => 'Assignment details';

  @override
  String get assignmentNotFound => 'Assignment not found';

  @override
  String get assignmentSelectFileFirst => 'Select a file first';

  @override
  String get assignmentStudentResolveFailed =>
      'Could not determine the student for this assignment. Please try again.';

  @override
  String get assignmentSubmittedSuccess => 'Assignment submitted successfully';

  @override
  String get assignmentSubmitFailed => 'Failed to submit the assignment';

  @override
  String get assignmentTeacherFilesTitle => 'Teacher files';

  @override
  String get assignmentNoTeacherFiles => 'No files attached';

  @override
  String get assignmentSubmittedFilesTitle => 'Submitted files';

  @override
  String get assignmentNotSubmittedYet => 'Not submitted yet';

  @override
  String get chooseFileAction => 'Choose file';

  @override
  String get chooseAnotherFileAction => 'Choose another file';

  @override
  String get chatOnlineStatus => 'Online';

  @override
  String get chatOfflineStatus => 'Offline';

  @override
  String get refreshAction => 'Refresh';

  @override
  String get backToChatsAction => 'Back to chats';

  @override
  String get chatMessageHint => 'Type a message...';

  @override
  String get chatMessageSendFailed => 'Message was not sent';

  @override
  String get chatFileSendFailed => 'File was not sent';

  @override
  String get breakfastLabel => 'Breakfast';

  @override
  String get lunchLabel => 'Lunch';

  @override
  String get afternoonTeaLabel => 'Afternoon tea';

  @override
  String get dinnerLabel => 'Dinner';

  @override
  String get snackLabel => 'Snack';

  @override
  String get gradesLoadFailed => 'Failed to load grades';

  @override
  String get gradeSummaryLoadFailed => 'Failed to load the grade summary';

  @override
  String get scheduleLoadFailed => 'Failed to load the schedule';

  @override
  String get assignmentsLoadFailed => 'Failed to load assignments';

  @override
  String get assignmentDetailsLoadFailed => 'Failed to load assignment details';

  @override
  String get assignmentUploadFailed => 'Failed to upload the file';

  @override
  String get attendanceLoadFailed => 'Failed to load attendance';

  @override
  String get attendanceSummaryLoadFailed =>
      'Failed to load the attendance summary';

  @override
  String get menuLoadFailed => 'Failed to load the menu';

  @override
  String get weeklyMenuLoadFailed => 'Failed to load the weekly menu';

  @override
  String get conversationsLoadFailed => 'Failed to load conversations';

  @override
  String get messagesLoadFailed => 'Failed to load messages';

  @override
  String get profileUpdateFailed => 'Failed to update the profile';

  @override
  String get imageUploadFailed => 'Failed to upload the image';

  @override
  String get childrenLoadFailed => 'Failed to load children';

  @override
  String get dataLoadFailed => 'Failed to load the data';

  @override
  String get changePasswordFailed => 'Failed to change the password';

  @override
  String get balanceLoadFailed => 'Failed to load the balance';

  @override
  String get paymentHistoryLoadFailed => 'Failed to load the payment history';

  @override
  String get paymentCreateFailed => 'Failed to create the payment';

  @override
  String get paymentMethodsLoadFailed => 'Failed to load payment methods';

  @override
  String get gradeTypeDaily => 'Daily';

  @override
  String get gradeTypeExam => 'Exam';

  @override
  String get gradeTypeHomework => 'Homework';

  @override
  String get gradeTypeTest => 'Test';

  @override
  String get langUz => 'Uzbek';

  @override
  String get langRu => 'Russian';

  @override
  String get langEn => 'English';

  @override
  String get paymentSuccessTitle => 'To\'lov muvaffaqiyatli!';

  @override
  String get paymentSuccessMessage =>
      'To\'lov muvaffaqiyatli amalga oshirildi. Farzandingiz balansi yaqin daqiqalarda yangilanadi.';

  @override
  String get backToHome => 'Asosiy ekranga qaytish';

  @override
  String get paymentFailedTitle => 'To\'lovda xatolik';

  @override
  String get paymentFailedMessage =>
      'To\'lovni amalga oshirishda muammo yuzaga keldi. Iltimos, qayta urinib ko\'ring yoki qo\'llab-quvvatlash xizmatiga murojaat qiling.';

  @override
  String get aiInsightsTitle => 'AI Recommendations';

  @override
  String aiInsightsError(String message) {
    return 'Error: $message';
  }

  @override
  String get aiInsightsEmpty => 'No data found';

  @override
  String aiRiskLevelLabel(String level) {
    return 'Risk level: $level';
  }

  @override
  String aiAttendanceAndGrade(String attendance, String grade) {
    return 'Attendance: $attendance% | Average grade: $grade';
  }

  @override
  String get aiWeakAreasTitle => 'Subjects that need more attention';

  @override
  String get diaryServiceTitle => 'Diary';

  @override
  String get diaryTitle => 'Diary';

  @override
  String get diaryWeeklyView => 'Weekly';

  @override
  String get diaryDailyView => 'Daily';

  @override
  String get diaryNoLessons => 'No lessons on this day';

  @override
  String get diaryNoData => 'No diary data found';

  @override
  String get diaryLoadFailed => 'Failed to load diary';

  @override
  String get diarySubject => 'Subject';

  @override
  String get diaryTeacher => 'Teacher';

  @override
  String get diaryTopic => 'Topic';

  @override
  String get diaryGrade => 'Grade';

  @override
  String get diaryHomework => 'Homework';

  @override
  String get diaryComment => 'Comment';

  @override
  String get diaryPresent => 'Present';

  @override
  String get diaryAbsent => 'Absent';

  @override
  String get diaryLate => 'Late';

  @override
  String get diaryExcused => 'Excused';

  @override
  String diaryLessonsCount(int count) => '$count lessons';

  @override
  String diaryAvgGrade(String grade) => 'Average: $grade';

  @override
  String diaryAttendanceRate(int present, int total) =>
      'Attendance: $present/$total';

  @override
  String get classStoryServiceTitle => 'Class News';

  @override
  String get classStoryTitle => 'Class News';

  @override
  String get classStoryEmpty => 'No stories yet';

  @override
  String get classStoryLoadFailed => 'Failed to load stories';

  @override
  String get classStoryCommentHint => 'Write a comment...';

  @override
  String classStoryLikes(int count) => '$count likes';

  @override
  String classStoryComments(int count) => '$count comments';

  @override
  String get transportServiceTitle => 'Transport';

  @override
  String get transportTitle => 'School Bus';

  @override
  String get transportNoBus => 'No bus found';

  @override
  String get transportNoBusDesc =>
      'Your child is not assigned to any active bus route';

  @override
  String get transportDriver => 'Driver';

  @override
  String get transportLiveLocation => 'Live Location';

  @override
  String get transportJustNow => 'Just now';

  @override
  String get transportStops => 'Stops';

  @override
  String get transportPickup => 'Pickup';

  @override
  String get transportDropoff => 'Drop-off';

  @override
  String get quizServiceTitle => 'Quizzes';
  @override
  String get quizTitle => 'Quizzes';
  @override
  String get quizEmpty => 'No quizzes available';
  @override
  String get quizLoadFailed => 'Failed to load quizzes';
  @override
  String get quizMinutes => 'min';
  @override
  String get quizMaxScore => 'Max score';
  @override
  String get quizAlreadyAttempted => 'Completed';
  @override
  String get quizQuestion => 'Question';
  @override
  String get quizAnswered => 'answered';
  @override
  String get quizPrevious => 'Previous';
  @override
  String get quizNext => 'Next';
  @override
  String get quizSubmit => 'Submit';
  @override
  String get quizStartFailed => 'Failed to start quiz';
  @override
  String get quizScore => 'Score';
  @override
  String get quizResultGreat => 'Great result!';
  @override
  String get quizResultTryAgain => 'Better luck next time!';
  @override
  String get quizBackToList => 'Back to quizzes';

  @override
  String get eventsServiceTitle => 'Events';
  @override
  String get eventsTitle => 'Events';
  @override
  String get eventsEmpty => 'No events found';
  @override
  String get eventsLoadFailed => 'Failed to load events';
  @override
  String get eventsAll => 'All';
  @override
  String get eventsHoliday => 'Holiday';
  @override
  String get eventsExam => 'Exam';
  @override
  String get eventsMeeting => 'Meeting';
  @override
  String get eventsSport => 'Sport';
  @override
  String get eventsOther => 'Other';
  @override
  String get galleryServiceTitle => 'Gallery';
  @override
  String get galleryTitle => 'Photo Gallery';
  @override
  String get galleryEmpty => 'No albums yet';
  @override
  String get galleryLoadFailed => 'Failed to load gallery';
  @override
  String get galleryPhotos => 'photos';
  @override
  String get galleryNoPhotos => 'No photos in this album';
  @override
  String get formsServiceTitle => 'Surveys';
  @override
  String get formsTitle => 'Surveys';
  @override
  String get formsEmpty => 'No surveys available';
  @override
  String get formsLoadFailed => 'Failed to load surveys';
  @override
  String get formsSubmitted => 'Submitted';
  @override
  String get formsExpired => 'Expired';
  @override
  String get formsPending => 'Pending';
  @override
  String get formsSubmitAction => 'Submit';
  @override
  String get formsSubmitFailed => 'Submission failed';
  @override
  String get formsAlreadySubmitted => 'You have already submitted';
  @override
  String get formsSubmittedSuccess => 'Your response was submitted successfully!';
  @override
  String get formsBackToList => 'Back to surveys';
  @override
  String get behaviorServiceTitle => 'Behavior';
  @override
  String get behaviorTitle => 'Behavior';
  @override
  String get behaviorLoadFailed => 'Failed to load data';
  @override
  String get behaviorEmpty => 'No behavior records';
  @override
  String get behaviorNetScore => 'Net score';
  @override
  String get behaviorPositive => 'Positive';
  @override
  String get behaviorNegative => 'Negative';
  @override
  String get behaviorTotal => 'Total';
  @override
  String get behaviorHistory => 'History';
}
