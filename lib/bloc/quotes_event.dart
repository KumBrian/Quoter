part of 'quotes_bloc.dart';

@immutable
sealed class QuotesEvent {}

final class QuotesFetch extends QuotesEvent {}

class ToggleLike extends QuotesEvent {
  final int index;

  ToggleLike(this.index);
}
