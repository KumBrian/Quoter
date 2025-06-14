part of 'quotes_bloc.dart';

abstract class QuotesEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadQuotes extends QuotesEvent {
  final String category;

  LoadQuotes({required this.category});
}
