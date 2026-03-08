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

  GameCubit()
    : super(
        GameState.initial().copyWith(
          todayCitizens: CitizenGenerator.generateDailyCitizens(30),
        ),
      );

  void _startNewDay({required int newDay, required double currentThreat}) {
    emit(
      state.copyWith(
        remainingTimeInDay: 60.0,
        currentDay: newDay,
        terroristThreat: currentThreat,
        todayCitizens: CitizenGenerator.generateDailyCitizens(30),
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
    double newThreat = (state.terroristThreat + effectiveDt).clamp(0.0, 100.0);

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
  void detainCitizen(Citizen citizen) {
    // Use ID-based filtering rather than List.remove() to avoid an Equatable
    // pitfall: if the citizen was investigated after the dialog opened,
    // its isInvestigated field differs from the snapshot held by the dialog,
    // so value-equality would fail to find it in the list.
    final updatedCitizens = state.todayCitizens
        .where((c) => c.idNumber != citizen.idNumber)
        .toList();

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
