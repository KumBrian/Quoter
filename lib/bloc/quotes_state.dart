part of 'quotes_bloc.dart';

@immutable
sealed class QuotesState {}

final class QuotesInitial extends QuotesState {}

final class QuotesSuccess extends QuotesState {
  final List<Quote> quotes;
  final List<Quote> likedQuotes;

  QuotesSuccess({required this.quotes, required this.likedQuotes});
}

final class QuotesFailure extends QuotesState {
  final String error;

  QuotesFailure(this.error);
}

final class QuotesLoading extends QuotesState {}
