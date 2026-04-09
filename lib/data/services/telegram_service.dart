class TelegramBotService {
  static final TelegramBotService _instance = TelegramBotService._internal();
  factory TelegramBotService() => _instance;
  TelegramBotService._internal();

  String? _botToken;
  int? _adminChatId;
  String? _adminEmail;
  String? _smtpHost;
  int? _smtpPort;
  String? _smtpUser;
  String? _smtpPass;

  void initialize({
    String? botToken,
    int? adminChatId,
    String? adminEmail,
    String? smtpHost,
    int? smtpPort,
    String? smtpUser,
    String? smtpPass,
  }) {
    _botToken = botToken;
    _adminChatId = adminChatId;
    _adminEmail = adminEmail;
    _smtpHost = smtpHost;
    _smtpPort = smtpPort;
    _smtpUser = smtpUser;
    _smtpPass = smtpPass;
  }

  bool get isConfigured => _botToken != null && _adminChatId != null;
  bool get isEmailConfigured => _adminEmail != null && _smtpHost != null;

  void sendMessageToAdmin(String message, {bool sendToEmail = false}) {
    if (!isConfigured) return;
  }

  void notifyNewRegistration(String parentEmail, String childName,
      {bool sendToEmail = false}) {
    final telegramMsg =
        '📝 <b>Новая регистрация!</b>\n\n👤 Ребёнок: $childName\n📧 Родитель: $parentEmail';
    sendMessageToAdmin(telegramMsg);
  }

  void notifySubscriptionChange(String parentEmail, String status,
      {bool sendToEmail = false}) {
    final telegramMsg =
        '💳 <b>Изменение подписки</b>\n\n📧 Родитель: $parentEmail\nСтатус: $status';
    sendMessageToAdmin(telegramMsg);
  }

  void notifyChildProgress(String childName, String lessonTitle, int xp) {
    final telegramMsg =
        '🎯 <b>Прогресс ребёнка</b>\n\n👤 Ребёнок: $childName\n📚 Урок: $lessonTitle\n⭐ XP: +$xp';
    sendMessageToAdmin(telegramMsg);
  }

  void notifySupportMessage(String parentEmail, String message,
      {bool sendToEmail = false}) {
    final telegramMsg =
        '❓ <b>Сообщение в поддержку</b>\n\n📧 От: $parentEmail\n💬 Сообщение: $message';
    sendMessageToAdmin(telegramMsg);
  }

  void notifyPayment(String parentEmail, String amount, String method) {
    final telegramMsg =
        '💰 <b>Оплата!</b>\n\n📧 Родитель: $parentEmail\n💵 Сумма: $amount\n💳 Метод: $method';
    sendMessageToAdmin(telegramMsg);
  }
}
