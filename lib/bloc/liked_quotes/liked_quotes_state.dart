part of 'liked_quotes_bloc.dart';

abstract class LikedQuotesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LikedQuotesLoading extends LikedQuotesState {}

class LikedQuotesLoaded extends LikedQuotesState {
  final List<Quote> likedQuotes;
  LikedQuotesLoaded(this.likedQuotes);

  @override
  List<Object?> get props => [likedQuotes];
}
