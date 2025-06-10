part of 'category_suggestion_cubit.dart';

@immutable
sealed class CategorySuggestionState {}

class CategorySuggestionInitial extends CategorySuggestionState {}

class CategorySuggestionLoading extends CategorySuggestionState {}

class CategorySuggestionLoaded extends CategorySuggestionState {
  final String suggestion;
  CategorySuggestionLoaded(this.suggestion);
}

class CategorySuggestionError extends CategorySuggestionState {
  final String message;

  CategorySuggestionError(this.message);
}
