import 'dart:math';
import 'storage_service.dart';
import 'gamification_service.dart';

class ReferralService {
  static final ReferralService _instance = ReferralService._internal();
  factory ReferralService() => _instance;
  ReferralService._internal();

  String? _currentReferralCode;
  int _referredCount = 0;

  String generateReferralCode(String childName) {
    final random = Random();
    final prefix = childName.isNotEmpty
        ? childName.substring(0, min(3, childName.length)).toUpperCase()
        : 'NER';
    final suffix = random.nextInt(9000) + 1000;
    return '$prefix$suffix';
  }

  String getReferralLink(String code) {
    return 'neuroexplorer.ru/?ref=$code';
  }

  Future<void> saveReferralCode(String code) async {
    _currentReferralCode = code;
    await StorageService.setReferralCode(code);
  }

  Future<String?> loadReferralCode() async {
    _currentReferralCode = StorageService.getReferralCode();
    return _currentReferralCode;
  }

  String? get currentCode => _currentReferralCode;

  Future<bool> applyReferralCode(String code) async {
    final current = await loadReferralCode();
    if (current != null && current == code) return false;
    if (StorageService.hasReferralBonus()) return false;

    await StorageService.setReferredBy(code);
    _referredCount = 1;
    _giveReferralBonus();
    return true;
  }

  Future<void> _giveReferralBonus() async {
    await GamificationService.addXp(XpSource.referralBonus);
  }

  Map<String, dynamic> getReferralStats() {
    return {
      'referralCode': _currentReferralCode ?? 'Не создан',
      'referralLink': _currentReferralCode != null
          ? getReferralLink(_currentReferralCode!)
          : '',
      'referredCount': _referredCount,
      'bonusXp': _referredCount * 100,
    };
  }
}
