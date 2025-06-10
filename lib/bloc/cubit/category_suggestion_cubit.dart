import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'category_suggestion_state.dart';

class CategorySuggestionCubit extends Cubit<CategorySuggestionState> {
  CategorySuggestionCubit() : super(CategorySuggestionInitial());

  void updateSuggestion(String suggestion) {
    emit(CategorySuggestionLoaded(suggestion));
  }

  void clearSuggestion() {
    emit(CategorySuggestionInitial());
  }

  void setLoading() {
    emit(CategorySuggestionLoading());
  }
}
