import 'package:flutter_riverpod/flutter_riverpod.dart';

final testClockProvider =
    NotifierProvider<TestClockController, TestClockState>(
  TestClockController.new,
);

class TestClockState {
  const TestClockState({
    required this.enabled,
    required this.currentTime,
  });

  final bool enabled;
  final DateTime currentTime;

  TestClockState copyWith({
    bool? enabled,
    DateTime? currentTime,
  }) {
    return TestClockState(
      enabled: enabled ?? this.enabled,
      currentTime: currentTime ?? this.currentTime,
    );
  }
}

class TestClockController extends Notifier<TestClockState> {
  @override
  TestClockState build() {
    return TestClockState(
      enabled: false,
      currentTime: DateTime.now(),
    );
  }

  void setEnabled(bool value) {
    state = state.copyWith(enabled: value);
  }

  void adjust(Duration offset) {
    state = state.copyWith(
      enabled: true,
      currentTime: state.currentTime.add(offset),
    );
  }

  void setTime(DateTime value) {
    state = state.copyWith(
      enabled: true,
      currentTime: value,
    );
  }

  void reset() {
    state = TestClockState(
      enabled: false,
      currentTime: DateTime.now(),
    );
  }
}
