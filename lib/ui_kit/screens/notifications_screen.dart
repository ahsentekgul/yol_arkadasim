import 'package:flutter/material.dart';
import '../widgets/notification_card.dart';
import '../widgets/app_button.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_spacing.dart';
import '../widgets/navigation_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationModel? _currentNotification;
  bool _isVisible = false;

  final NotificationModel _mockNotification = NotificationModel(
    id: 1,
    type: 'stop_arrival',
    title: 'Durağa Varıyorsunuz',
    message: 'Taksim Meydanı durağına 2 dakika kaldı',
    stopName: 'Taksim Meydanı',
    estimatedTime: '2 dakika',
  );

  @override
  void initState() {
    super.initState();
    // Tek bir mock bildirimi göster (sadece UI). Zamanlayıcı yok.
    _currentNotification = _mockNotification;
    _isVisible = true;
    // TODO: Eğer ses/titreşim etkin olsaydı, varış burada duyurulacaktı.
  }

  void _dismissNotification() {
    setState(() {
      _isVisible = false;
    });
    // TODO: speak('Bildirim kapatıldı')
  }

  void _handleAlternative() {
    // Demo eylemi
    // TODO: burada alternatif rota arama tetiklenecek
    debugPrint('Alternatif rota tetiklendi (demo)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const NavigationHeader(),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.p6),
            child: _currentNotification == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Bildirim Bekleniyor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Yolculuk sırasında bildirimler burada görünecek',
                        style: TextStyle(color: AppColors.gray300, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        child: const Text('Ana Menü'),
                        onPressed: () => Navigator.of(context).maybePop(),
                        semanticsLabel: 'Ana menüye dön',
                      )
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NotificationCard(
                        notification: _currentNotification!,
                        isVisible: _isVisible,
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        child: const Text('Anladım'),
                        onPressed: _dismissNotification,
                        semanticsLabel: 'Bildirim kapat',
                        fullWidth: true,
                      ),
                      const SizedBox(height: 8),
                      if (_currentNotification!.type == 'route_alert')
                        AppButton(
                          child: const Text('Alternatif Rota'),
                          onPressed: _handleAlternative,
                          semanticsLabel: 'Alternatif rota bul',
                          fullWidth: true,
                        ),
                      const SizedBox(height: 12),
                      AppButton(
                        child: const Text('Ana Menü'),
                        onPressed: () => Navigator.of(context).maybePop(),
                        semanticsLabel: 'Ana menüye dön',
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

