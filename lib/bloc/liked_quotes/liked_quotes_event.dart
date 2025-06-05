// liked_quotes_event.dart

part of 'liked_quotes_bloc.dart';

abstract class LikedQuotesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadLikedQuotes extends LikedQuotesEvent {}

class AddFavorite extends LikedQuotesEvent {
  final Quote quote;
  final BuildContext context;
  AddFavorite(this.quote, this.context);
  @override
  List<Object?> get props => [quote];
}

class RemoveFavorite extends LikedQuotesEvent {
  final Quote quote;
  final BuildContext context;
  RemoveFavorite(this.quote, this.context);
  @override
  List<Object?> get props => [quote];
}
