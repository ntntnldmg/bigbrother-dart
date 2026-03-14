import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_typography.dart';
import '../audio/audio_settings.dart';
import '../consts.dart';
import '../game/game_cubit.dart';
import 'game_screen.dart';

class ExpositionScreen extends StatefulWidget {
  const ExpositionScreen({super.key});

  @override
  State<ExpositionScreen> createState() => _ExpositionScreenState();
}

class _ExpositionScreenState extends State<ExpositionScreen> {
  int _pageIndex = 0;
  int _audioRequestId = 0;
  String? _activeTrack;

  static const List<String> _pageTracks = ['exposition.ogg', 'exposition2.ogg'];

  static const List<_ExpositionPageData> _pages = [
    _ExpositionPageData(
      title: 'STATE OF THE NATION // YEAR 2049',
      body:
          'After twelve consecutive years of bombings and coordinated cyber '
          'sabotage, civilian trust has collapsed. Infrastructure runs under '
          'military emergency protocols, and every district is now divided into '
          'surveillance sectors.\n\n'
          'Your command center receives fragmented intelligence, incomplete '
          'witness reports, and manipulated public data. Every decision must be '
          'made under pressure, before the next incident unfolds.',
    ),
    _ExpositionPageData(
      title: 'YOUR MANDATE',
      body:
          'You are assigned to the Internal Stability Bureau to identify and '
          'neutralize active threats hidden among ordinary residents.\n\n'
          'Investigate patterns, issue arrests with care, and deploy wire taps '
          'strategically. Wrong actions fuel panic and political backlash. '
          'Delay gives hostile networks time to regroup.\n\n'
          'There is no perfect information. Only consequences.',
    ),
  ];

  bool get _isLastPage => _pageIndex == _pages.length - 1;

  @override
  void initState() {
    super.initState();
    _syncPageAudio();
  }

  @override
  void dispose() {
    _stopExpositionAudio();
    super.dispose();
  }

  Future<void> _startPageTrack(String trackName) async {
    if (!AudioSettings.isEnabled) {
      _activeTrack = null;
      await FlameAudio.bgm.stop();
      return;
    }
    if (_activeTrack == trackName) return;

    final requestId = ++_audioRequestId;

    Future<void> playOnce() async {
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.play(trackName);
    }

    try {
      await playOnce();
      if (!mounted || requestId != _audioRequestId) return;
      _activeTrack = trackName;
    } catch (error) {
      if (error.toString().contains('AbortError')) {
        await Future.delayed(const Duration(milliseconds: 220));
        if (!mounted || requestId != _audioRequestId) return;
        try {
          await playOnce();
          if (!mounted || requestId != _audioRequestId) return;
          _activeTrack = trackName;
          return;
        } catch (_) {
          // Fall through to generic handler below.
        }
      }
      debugPrint('Exposition audio unavailable: $error');
      _activeTrack = null;
    }
  }

  Future<void> _stopExpositionAudio() async {
    _audioRequestId++;
    _activeTrack = null;
    await FlameAudio.bgm.stop();
  }

  void _syncPageAudio() {
    final track = _pageTracks[_pageIndex.clamp(0, _pageTracks.length - 1)];
    _startPageTrack(track);
  }

  Future<void> _startGame() async {
    await _stopExpositionAudio();
    if (!mounted) return;
    context.read<GameCubit>().startNewSimulation();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const GameScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_pageIndex];

    return Scaffold(
      backgroundColor: AppColors.expositionBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.expositionGradientTop,
                      AppColors.expositionGradientBottom,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 100),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.expositionCardBackground,
                        border: Border.all(
                          color: AppColors.green.withAlpha(180),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.breakingNewsBackground,
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CLASSIFIED BRIEFING',
                            style: AppTypography.mono(
                              color: AppColors.green,
                              fontSize: 20,
                              letterSpacing: 2.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(height: 2, color: AppColors.green),
                          const SizedBox(height: 26),
                          Text(
                            page.title,
                            style: AppTypography.mono(
                              color: AppColors.textPrimary,
                              fontSize: 38,
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                page.body,
                                style: AppTypography.mono(
                                  color: AppColors.textSecondary,
                                  fontSize: 24,
                                  letterSpacing: 0.6,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: List.generate(
                              _pages.length,
                              (index) => Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(right: 8),
                                color: index == _pageIndex
                                    ? AppColors.green
                                    : AppColors.textLowEmphasis,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_isLastPage) {
                                  _startGame();
                                  return;
                                }
                                setState(() => _pageIndex += 1);
                                _syncPageAudio();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 12,
                                ),
                                child: Text(
                                  _isLastPage ? 'BEGIN OPERATION' : 'NEXT',
                                  style: AppTypography.mono(
                                    fontSize: 18,
                                    letterSpacing: 1.6,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: Center(
                child: TextButton(
                  onPressed: _startGame,
                  child: Text(
                    'SKIP EXPOSITION',
                    style: AppTypography.mono(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpositionPageData {
  final String title;
  final String body;

  const _ExpositionPageData({required this.title, required this.body});
}
