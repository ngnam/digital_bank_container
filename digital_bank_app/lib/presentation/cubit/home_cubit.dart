import 'package:flutter_bloc/flutter_bloc.dart';

abstract class HomeState {}
class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final String message;
  HomeLoaded(this.message);
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> loadGreeting() async {
    emit(HomeLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    emit(HomeLoaded('Welcome to Digital Bank'));
  }
}
