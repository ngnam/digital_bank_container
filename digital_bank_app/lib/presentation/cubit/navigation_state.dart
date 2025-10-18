import 'package:flutter/foundation.dart';

@immutable
class NavigationState {
  final int index;

  const NavigationState({this.index = 0});

  NavigationState copyWith({int? index}) => NavigationState(index: index ?? this.index);
}
