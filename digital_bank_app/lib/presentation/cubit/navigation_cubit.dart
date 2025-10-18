import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  void changeIndex(int newIndex) {
    if (newIndex == state.index) return;
    emit(state.copyWith(index: newIndex));
  }
}
