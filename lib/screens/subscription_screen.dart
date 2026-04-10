import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/payment_provider.dart';
import '../data/services/firebase_service.dart'; // Оставляем для получения информации о подписке

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final PaymentProvider _paymentProvider = YooKassaPaymentProvider();
  bool _isLoading = false;
  String? _selectedPlan;

  // Определяем цены здесь, чтобы использовать их в нескольких местах
  final int _monthlyPrice = 299;
  final int _yearlyPrice = 1990;
  final int _seasonPrice = 500;
  final int _lifetimePrice = 2500;

  @override
  Widget build(BuildContext context) {
    final subscriptionInfo = SubscriptionService().getSubscriptionInfo();
    final isSubscribed = subscriptionInfo['isSubscribed'] as bool;
    final isTrialActive = subscriptionInfo['isTrialActive'] as bool;
    final trialDaysRemaining = subscriptionInfo['trialDaysRemaining'] as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Подписка'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSubscribed || isTrialActive)
                    _buildCurrentStatus(subscriptionInfo),
                  const SizedBox(height: 24),
                  _buildTrialSection(trialDaysRemaining, isTrialActive),
                  const SizedBox(height: 24),
                  _buildPricingSection(),
                  const SizedBox(height: 24),
                  if (_selectedPlan != null) _buildPaymentMethodsSection(),
                  const SizedBox(height: 24),
                  _buildFeaturesSection(),
                ],
              ),
            ),
    );
  }
  
  Widget _buildCurrentStatus(Map<String, dynamic> info) {
    final isTrial = info['isTrialActive'] as bool;
    final endDate = info['subscriptionEnd'] as String?;

    return Card(
      color: Colors.green.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isTrial ? Icons.timer : Icons.check_circle,
                color: Colors.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTrial ? 'Активен пробный период' : 'Премиум подписка',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                  ),
                  Text(
                    isTrial
                        ? 'Осталось дней: ${info['trialDaysRemaining']}'
                        : 'До ${endDate ?? "неизвестно"}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialSection(int daysRemaining, bool isActive) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.card_giftcard, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Бесплатный пробный период',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isActive
                  ? 'У вас активен пробный период! Осталось $daysRemaining дней.'
                  : 'Получите 7 дней бесплатно при регистрации.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (!isActive) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _activateTrial,
                  child: const Text('Активировать пробный период'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Выберите тариф',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Базовый (уроки без AI)',
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPricingCard(
                'Базовый Месяц',
                '199 ₽',
                'в месяц',
                false,
                199,
                isBasic: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPricingCard(
                'Базовый Год',
                '1490 ₽',
                'в год',
                false,
                1490,
                isBasic: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'С AI Ассистентом (помесячно)',
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        _buildPricingCard(
          'С AI Ассистентом',
          '499 ₽',
          'в месяц + безлимит AI',
          true,
          499,
          isAssistant: true,
        ),
        const SizedBox(height: 16),
        const Text(
          'Разовые покупки',
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPricingCard(
                '1 сезон',
                '$_seasonPrice ₽',
                'один сезон',
                false,
                _seasonPrice,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPricingCard(
                'Все 8 сезонов',
                '$_lifetimePrice ₽',
                'навсегда',
                true,
                _lifetimePrice,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingCard(
      String title, String price, String subtitle, bool isPopular, int amount, {
        bool isBasic = false,
        bool isAssistant = false,
      }) {
    final isSelected = _selectedPlan == title;
    final cardColor = isAssistant 
        ? Colors.cyan.withOpacity(0.1) 
        : isBasic 
            ? Colors.grey.withOpacity(0.1)
            : null;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : cardColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAssistant 
                ? Colors.cyan 
                : isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: isSelected || isAssistant ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAssistant 
                      ? Colors.cyan.withOpacity(0.2)
                      : Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isAssistant ? 'AI включён' : 'Выгодно',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isAssistant ? Colors.cyan : Colors.amber,
                  ),
                ),
              ),
            if (isBasic)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Без AI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isAssistant 
                        ? Colors.cyan 
                        : Theme.of(context).colorScheme.primary,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      'Доступ ко всем сезонам',
      'Безлимитные задания',
      'Персональный аватар',
      'Сохранение прогресса в облаке',
      'Родительский кабинет',
      'Без рекламы',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Что входит в подписку',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Способы оплаты',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('Банковская карта / СБП'),
                subtitle: const Text('Оплатить через YooKassa'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _startPayment(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Отмена в любой момент. Деньги вернём за неиспользованные дни.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _activateTrial() async {
    setState(() => _isLoading = true);
    await SubscriptionService().activateTrial();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пробный период активирован!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    }
    setState(() => _isLoading = false);
  }

  Future<void> _startPayment() async {
    if (_selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, сначала выберите тариф.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Получаем сумму и описание в зависимости от выбранного плана
    int amount;
    String description;
    bool withAI = false;
    switch (_selectedPlan) {
      case 'Базовый Месяц':
        amount = 199;
        description = 'Базовый тариф (уроки) - 1 месяц';
        break;
      case 'Базовый Год':
        amount = 1490;
        description = 'Базовый тариф (уроки) - 1 год';
        break;
      case 'С AI Ассистентом':
        amount = 499;
        description = 'Тариф с AI Ассистентом - 1 месяц';
        withAI = true;
        break;
      case 'Год':
        amount = _yearlyPrice;
        description = 'Подписка на 1 год';
        break;
      case '1 сезон':
        amount = _seasonPrice;
        description = 'Покупка 1 сезона';
        break;
      case 'Все 8 сезонов':
        amount = _lifetimePrice;
        description = 'Покупка всех сезонов (навсегда)';
        break;
      default:
        setState(() => _isLoading = false);
        return;
    }

    try {
      final redirectUrl = await _paymentProvider.initiatePayment(
        planId: _selectedPlan!,
        amount: amount,
        description: description,
      );

      // Для демонстрации - сразу активируем подписку
      // В реальном приложении это будет делаться после webhook от YooKassa
      if (redirectUrl != null) {
        final service = SubscriptionService();
        
        int months = 1;
        if (_selectedPlan == 'Базовый Год' || _selectedPlan == 'Год') {
          months = 12;
        }
        
        await service.subscribe(
          months: months,
          paymentMethodId: 'demo',
          withAI: withAI,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                withAI 
                  ? 'Подписка с AI Ассистентом активирована!'
                  : 'Подписка активирована!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {});
        }
      }

      if (redirectUrl != null && await canLaunchUrl(Uri.parse(redirectUrl))) {
        await launchUrl(Uri.parse(redirectUrl), webOnlyWindowName: '_blank');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при инициации платежа: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
