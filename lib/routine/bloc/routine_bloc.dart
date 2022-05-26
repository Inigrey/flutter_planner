import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:routines_api/routines_api.dart';
import 'package:routines_repository/routines_repository.dart';

part 'routine_event.dart';
part 'routine_state.dart';

class RoutineBloc extends Bloc<RoutineEvent, RoutineState> {
  RoutineBloc({
    required RoutinesRepository routinesRepository,
    required Routine initialRoutine,
  })  : _routinesRepository = routinesRepository,
        super(
          RoutineState(
            initialRoutine: initialRoutine,
            name: initialRoutine.name,
            day: initialRoutine.day,
            startTime: initialRoutine.startTime,
            endTime: initialRoutine.endTime,
          ),
        ) {
    on<RoutineSaved>(_onSaved);
    on<RoutineDeleted>(_onDeleted);
    on<RoutineNameChanged>(_onNameChanged);
    on<RoutineDayChanged>(_onDayChanged);
    on<RoutineStartTimeChanged>(_onStarTimeChanged);
    on<RoutineEndTimeChanged>(_onEndTimeChanged);
  }

  final RoutinesRepository _routinesRepository;

  Future<void> _onSaved(
    RoutineSaved event,
    Emitter<RoutineState> emit,
  ) async {
    emit(state.copyWith(status: RoutineStatus.loading));
    final routine = state.initialRoutine.copyWith(
      name: state.name,
      day: state.day,
      startTime: state.startTime,
      endTime: state.endTime,
    );

    try {
      final initialRoutine = await _routinesRepository.saveRoutine(routine);
      emit(
        state.copyWith(
          status: RoutineStatus.success,
          initialRoutine: initialRoutine,
        ),
      );
    } catch (e) {
      log(e.toString());
      emit(state.copyWith(status: RoutineStatus.failure));
    }
  }

  Future<void> _onDeleted(
    RoutineDeleted event,
    Emitter<RoutineState> emit,
  ) async {
    if (state.initialRoutine.id != null) {
      emit(state.copyWith(status: RoutineStatus.loading));
      try {
        await _routinesRepository.deleteRoutine(state.initialRoutine.id!);
        emit(state.copyWith(status: RoutineStatus.success));
      } catch (e) {
        log(e.toString());
        emit(state.copyWith(status: RoutineStatus.failure));
      }
    }
  }

  void _onNameChanged(
    RoutineNameChanged event,
    Emitter<RoutineState> emit,
  ) {
    emit(state.copyWith(name: event.name));
    log('RoutineBloc(83)-- stateName: ${state.name}, eventName: ${event.name}');
  }

  void _onDayChanged(
    RoutineDayChanged event,
    Emitter<RoutineState> emit,
  ) {
    emit(
      state.copyWith(day: event.day),
    );
  }

  void _onStarTimeChanged(
    RoutineStartTimeChanged event,
    Emitter<RoutineState> emit,
  ) {
    emit(
      state.copyWith(startTime: event.startTime),
    );
  }

  void _onEndTimeChanged(
    RoutineEndTimeChanged event,
    Emitter<RoutineState> emit,
  ) {
    emit(
      state.copyWith(endTime: event.endTime),
    );
  }
}
