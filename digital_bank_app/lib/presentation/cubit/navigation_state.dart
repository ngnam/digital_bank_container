import 'package:flutter/foundation.dart';

@immutable
class NavigationState {
  final int index;

  // Default to index 0 (Dashboard) so the Dashboard Navigation tab is selected when NavigationPage opens
  const NavigationState({this.index = 0});

  NavigationState copyWith({int? index}) => NavigationState(index: index ?? this.index);
}
