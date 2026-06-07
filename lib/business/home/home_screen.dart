import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:yol_arkadasim/business/favorites/favorites_screen.dart';
import 'package:yol_arkadasim/business/nearby/nearby_screen.dart';
import 'package:yol_arkadasim/business/place_results/place_results_screen.dart';
import 'package:yol_arkadasim/business/search/search_screen.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_radius.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';
import 'package:yol_arkadasim/core/widgets/app_button.dart';
import 'package:yol_arkadasim/core/widgets/app_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _homeActionIconSize = 50;
  static const double _homeActionIconTextGap = 8;

  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _voiceResultHandled = false;
  String _lastRecognizedWords = '';

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  Future<void> _announce(String message) async {
    if (!mounted) return;
    SemanticsService.announce(message, Directionality.of(context));
  }

  void _navigateToVoiceSearchResults(String query) {
    if (!mounted || _voiceResultHandled) return;
    _voiceResultHandled = true;
    setState(() => _isListening = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceResultsScreen(searchQuery: query),
      ),
    );
  }

  Future<void> _onVoiceListeningEnded() async {
    if (!mounted || _voiceResultHandled) return;

    final text = _lastRecognizedWords.trim();
    if (text.isNotEmpty) {
      _navigateToVoiceSearchResults(text);
      return;
    }

    setState(() => _isListening = false);
    await _announce('Ses algılanamadı. Lütfen tekrar deneyin.');
  }

  Future<void> _handleVoiceSearchUnavailable() async {
    if (!mounted || _voiceResultHandled) return;
    setState(() => _isListening = false);
    await _announce(
      'Sesli arama şu anda kullanılamıyor. Lütfen hedefi yazarak arayın.',
    );
  }

  Future<void> _handleVoiceSearch() async {
    if (_isListening) return;

    _voiceResultHandled = false;
    _lastRecognizedWords = '';
    setState(() => _isListening = true);

    await _announce('Dinleme başlıyor. Hedefinizi söyleyin.');
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    try {
      final available = await _speech.initialize(
        onError: (_) => _handleVoiceSearchUnavailable(),
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _onVoiceListeningEnded();
          }
        },
      );

      if (!available) {
        await _handleVoiceSearchUnavailable();
        return;
      }

      if (!mounted) return;

      await _announce('Dinleniyor. Hedefinizi söyleyin.');

      await _speech.listen(
        onResult: (result) {
          if (_voiceResultHandled) return;
          final text = result.recognizedWords.trim();
          if (text.isNotEmpty) {
            _lastRecognizedWords = text;
          }
          if (result.finalResult && text.isNotEmpty) {
            _speech.stop();
            _navigateToVoiceSearchResults(text);
          }
        },
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 5),
          localeId: 'tr_TR',
          cancelOnError: true,
        ),
      );
    } catch (_) {
      await _handleVoiceSearchUnavailable();
    }
  }

  void handleSearchDestination() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  void handleNearbyStops() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NearbyScreen()),
    );
  }

  void handleButtonPress(String action) {
    switch (action) {
      case 'search':
        handleSearchDestination();
        break;
      case 'favorites':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
        );
        break;
      case 'nearby':
        handleNearbyStops();
        break;
    }
  }

  Widget _buildColoredMainCard({
    required Color color,
    required VoidCallback onPressed,
    required String semanticsLabel,
    required double minHeight,
    required IconData icon,
    required String title,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    bool expandedTitle = true,
    bool isLoading = false,
  }) {
    final titleText = Text(
      title,
      style: AppTextStyles.buttonLabel,
      maxLines: expandedTitle ? 2 : 1,
      overflow: TextOverflow.ellipsis,
    );

    return AppButton(
      onPressed: onPressed,
      semanticsLabel: semanticsLabel,
      fullWidth: true,
      size: 'custom',
      variant: 'custom',
      backgroundColor: color,
      borderRadius: AppRadius.roundedXl,
      minHeight: minHeight,
      isLoading: isLoading,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: mainAxisAlignment,
        children: [
          ExcludeSemantics(
            child: Icon(
              icon,
              size: _homeActionIconSize,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: _homeActionIconTextGap),
          if (expandedTitle)
            Expanded(child: titleText)
          else
            Flexible(child: titleText),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.spaceX3),
        const Center(
          child: Text(
            'Erişilebilir ulaşım yardımcınız',
            style: AppTextStyles.screenSubtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceY4),
        Expanded(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: _buildColoredMainCard(
                  color: AppColors.blue600,
                  onPressed: () => handleButtonPress('search'),
                  semanticsLabel: 'Hedef bul, arama ekranını açar',
                  minHeight: 0,
                  icon: Icons.search,
                  title: 'Hedef Bul',
                ),
              ),
              const SizedBox(height: AppSpacing.spaceX3),
              Expanded(
                flex: 3,
                child: _buildColoredMainCard(
                  color: AppColors.green600,
                  onPressed: () => handleButtonPress('favorites'),
                  semanticsLabel: 'Favori yerler, kayıtlı konumlarınızı gösterir',
                  minHeight: 0,
                  icon: Icons.favorite,
                  title: 'Favori Yerler',
                ),
              ),
              const SizedBox(height: AppSpacing.spaceX3),
              Expanded(
                flex: 3,
                child: _buildColoredMainCard(
                  color: AppColors.orange600,
                  onPressed: () => handleButtonPress('nearby'),
                  semanticsLabel: 'Yakın duraklar, çevrenizdeki durakları listeler',
                  minHeight: 0,
                  icon: Icons.place,
                  title: 'Yakın Duraklar',
                ),
              ),
              const SizedBox(height: AppSpacing.spaceX3),
              Expanded(
                flex: 2,
                child: _buildColoredMainCard(
                  color: AppColors.blue600,
                  onPressed: _handleVoiceSearch,
                  semanticsLabel: _isListening
                      ? 'Dinleniyor. Hedefinizi söyleyin.'
                      : 'Sesli hedef ara, gitmek istediğiniz hedefi söylemek için çift dokunun.',
                  minHeight: 0,
                  icon: Icons.mic_none,
                  title: 'Sesli Komut',
                  mainAxisAlignment: MainAxisAlignment.center,
                  expandedTitle: false,
                  isLoading: _isListening,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavigationBar.home(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.p6),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Semantics(
                container: true,
                label: 'YolArkadaşım ana ekranı. Erişilebilir ulaşım yardımcınız.',
                child: _buildMainView(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
