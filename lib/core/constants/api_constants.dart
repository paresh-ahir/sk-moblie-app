class ApiConstants {
  static const String baseUrl = 'https://api.beta.saleskido.com';

  // Auth
  static const String login = '/user/login';
  static const String register = '/user/register';
  static const String forgotPassword = '/user/forgotPassword';
  static const String forgotPasswordAgain = '/user/forgotPasswordEmailAgain';
  static const String resetPassword = '/user/resetPassword';
  static const String verifyEmail = '/user/verifyEmail';
  static const String verifyEmailAgain = '/user/verifyEmailAgain';
  static const String userFromToken = '/user/userFromToken';
  static const String logout = '/user/logout';
  static String updateUser(String id) => '/user/update/$id';

  // Dashboard
  static const String overAllTotal = '/dashboard/overAllTotal';
  static const String leadGraph = '/dashboard/lead_graph';
  static const String leadListDash = '/dashboard/leadList';
  static const String leadSummary = '/dashboard/leadSummary';
  static const String emailSummary = '/dashboard/emailSummary';
  static const String whatsAppGraph = '/dashboard/whatsAppGraph';

  // Leads
  static const String leadList = '/lead/list';
  static const String leadFind = '/lead/find';
  static const String leadCreate = '/lead/create';
  static const String leadUpdate = '/lead/update';
  static const String leadDelete = '/lead/delete';
  static const String leadTaskList = '/lead/taskList';
  static const String leadAddTask = '/lead/addTask';
  static const String leadNotesList = '/lead/notesList';
  static const String leadAddNotes = '/lead/addNotes';

  // Quotation
  static const String quotationList = '/quotation/list';
  static const String quotationGetOne = '/quotation/getOne';
  static const String quotationAddEdit = '/quotation/addAndEdit';
  static const String quotationDelete = '/quotation/delete';
  static const String quotationShare = '/quotation/share';

  // WhatsApp
  static String activeChats(String companyId) =>
      '/whatsappTools/findActiveLeads/$companyId';
  static String requestingChats(String companyId) =>
      '/whatsappTools/findRequestingLeads/$companyId';
  static String historyChats(String companyId) =>
      '/whatsappTools/findHistoryChatRooms/$companyId';
  static String getMessages(String userId) =>
      '/whatsappTools/getMessages/$userId';
  static const String sendMessages = '/whatsappTools/sendMessages';
  static String pinMessage(String userId) =>
      '/whatsappTools/pinnedMessage/$userId';
  static String unpinMessage(String userId) =>
      '/whatsappTools/unPinnedMessage/$userId';
  static String deleteMessage(String userId) =>
      '/whatsappTools/deleteMessage/$userId';

  // Notifications
  static const String notifications = '/notifications/getNotifications';
  static const String clearNotifications = '/notifications/clearAll';
  static String markNotificationRead(String id) =>
      '/notifications/markAsReadNotification/$id';

  // Reports / misc
  static const String customReport = '/customReport';
  static const String products = '/product/list';
  static const String tags = '/tag/list';
}
