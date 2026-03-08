import 'package:flutter_bloc/flutter_bloc.dart';
import 'game_state.dart';
import '../models/citizen.dart';
import '../systems/citizen_generator.dart';

class GameCubit extends Cubit<GameState> {
  // Accumulate dt and only emit state when enough time has elapsed.
  // This caps the BLoC stream to ~10 updates/sec instead of 60fps,
  // reducing unnecessary BlocBuilder predicate evaluations.
  double _pendingDt = 0.0;
  static const double _emitThreshold = 0.1;

  // 6 minutes per day.
  static const double _dayDuration = 360.0;

  // Threat starts at 15% and must reach 100% in exactly 2 days of passive play.
  // That is 85% over 2 × 360s = 720s → 85 / 720 ≈ 0.1181 % per second.
  static const double _threatRatePerSecond = 85.0 / 720.0;

  // Citizens are generated once when the game session starts and persist
  // across day rollovers. Only detaining removes citizens from this pool.
  GameCubit()
    : super(
        GameState.initial().copyWith(
          todayCitizens: CitizenGenerator.generateDailyCitizens(30),
        ),
      );

  void _startNewDay({required int newDay, required double currentThreat}) {
    // todayCitizens is intentionally omitted so the existing citizen list
    // carries over unchanged into the next day.
    emit(
      state.copyWith(
        remainingTimeInDay: _dayDuration,
        currentDay: newDay,
        terroristThreat: currentThreat,
      ),
    );
  }

  /// Updates the time and threat based on delta time (dt).
  void tick(double dt) {
    if (state.terroristThreat >= 100.0) return;

    _pendingDt += dt;
    if (_pendingDt < _emitThreshold) return;

    final effectiveDt = _pendingDt;
    _pendingDt = 0.0;

    double newTime = state.remainingTimeInDay - effectiveDt;
    double newThreat =
        (state.terroristThreat + _threatRatePerSecond * effectiveDt).clamp(
          0.0,
          100.0,
        );

    if (newThreat >= 100.0) {
      // TODO: Handle game over condition
    }

    if (newTime <= 0) {
      _startNewDay(newDay: state.currentDay + 1, currentThreat: newThreat);
      return;
    }

    emit(
      state.copyWith(remainingTimeInDay: newTime, terroristThreat: newThreat),
    );
  }

  /// Action: Detain a citizen.
  /// The citizen remains in the database but is marked as detained.
  void detainCitizen(Citizen citizen) {
    if (citizen.isDetained) return;

    final updatedCitizens = state.todayCitizens.map((c) {
      if (c.idNumber == citizen.idNumber) {
        return c.copyWith(isDetained: true);
      }
      return c;
    }).toList();

    double newThreat = state.terroristThreat;

    // Apply threat rules on detaining
    if (citizen.riskScore > 60) {
      newThreat = (newThreat - 10.0).clamp(0.0, 100.0);
    } else if (citizen.riskScore < 40) {
      newThreat = (newThreat + 10.0).clamp(0.0, 100.0);
    }

    emit(
      state.copyWith(
        detaineeCount: state.detaineeCount + 1,
        todayCitizens: updatedCitizens,
        terroristThreat: newThreat,
      ),
    );
  }

  /// Action: Investigate a citizen.
  void investigateCitizen(Citizen citizen) {
    if (!citizen.isInvestigated) {
      final updatedCitizens = state.todayCitizens.map((c) {
        if (c.idNumber == citizen.idNumber) {
          return c.copyWith(isInvestigated: true);
        }
        return c;
      }).toList();

      emit(
        state.copyWith(
          investigationCount: state.investigationCount + 1,
          todayCitizens: updatedCitizens,
        ),
      );
    }
  }
}
