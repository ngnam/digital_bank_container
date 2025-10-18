import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/';
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Digital Bank')),
        body: const Center(child: HomeBody()),
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeInitial) {
          return ElevatedButton(
            onPressed: () => context.read<HomeCubit>().loadGreeting(),
            child: const Text('Load Greeting'),
          );
        } else if (state is HomeLoaded) {
          return Text(state.message);
        } else if (state is HomeLoading) {
          return const CircularProgressIndicator();
        }
        return const SizedBox.shrink();
      },
    );
  }
}
