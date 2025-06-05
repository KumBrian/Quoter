part of 'quotes_bloc.dart';

abstract class QuotesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class QuotesInitial extends QuotesState {}

class QuotesLoading extends QuotesState {}

class QuotesLoaded extends QuotesState {
  final List<Quote> allQuotes;
  QuotesLoaded({required this.allQuotes});

  @override
  List<Object?> get props => [allQuotes];
}

class QuotesError extends QuotesState {
  final String message;
  QuotesError({required this.message});

  @override
  List<Object?> get props => [message];
}
