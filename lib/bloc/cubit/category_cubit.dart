import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryCubit extends Cubit<String> {
  CategoryCubit() : super('');

  List<String> categories = [
    'Surprise Me',
    'Inspiration',
    'Love',
    'Motivation',
    'Anger',
    'Friendship',
    'Happiness'
  ];

  void updateCategory(String category) => emit(category);
  void clearCategory() => emit('');
}
