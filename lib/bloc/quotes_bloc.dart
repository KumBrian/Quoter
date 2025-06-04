import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quoter/data/repository/hive_quote.dart';
import 'package:quoter/data/repository/quotes_repository.dart';
import 'package:quoter/models/quote.dart';

part 'quotes_event.dart';
part 'quotes_state.dart';

class QuotesBloc extends Bloc<QuotesEvent, QuotesState> {
  final QuotesRepository quotesRepository;
  final LikedQuotesRepository likedQuotesRepository = LikedQuotesRepository();
  QuotesBloc(this.quotesRepository) : super(QuotesInitial()) {
    on<QuotesFetch>(_fetchQuotes);
    on<ToggleLike>(_toggleLike);
  }

  Future<void> _fetchQuotes(
      QuotesFetch event, Emitter<QuotesState> emit) async {
    emit(QuotesLoading());
    try {
      debugPrint('Fetching Quotes...');
      final quotes = await quotesRepository.fetchQuotes();
      debugPrint('Quotes Loaded : ${quotes.toString()}');
      emit(QuotesSuccess(
        quotes: quotes,
        likedQuotes: likedQuotesRepository.getAllLikedQuotes(),
      ));
    } catch (e) {
      emit(QuotesFailure(e.toString()));
    }
  }

  void _toggleLike(ToggleLike event, Emitter<QuotesState> emit) async {
    final likedQuotesRepo = LikedQuotesRepository();
    if (state is! QuotesSuccess) return;
    final current = state as QuotesSuccess;

    // 1) Make a fresh copy of the full list and toggle `isLiked` on the single index
    final oldList = current.quotes;
    final updated = List<Quote>.from(oldList);
    final oldQuote = updated[event.index];
    final newQuote = oldQuote.copyWith(isLiked: !oldQuote.isLiked);
    updated[event.index] = newQuote;

    // 2) Build a new likedQuotes list:
    //    If newQuote.isLiked is true → add it to likedQuotes.
    //    Otherwise → remove it from likedQuotes.
    final oldLiked = List<Quote>.from(current.likedQuotes);
    if (newQuote.isLiked) {
      oldLiked.add(newQuote);
      await likedQuotesRepo.addQuote(newQuote);
    } else {
      oldLiked.removeWhere((q) => q == newQuote);
    }

    // 3) Emit a brand‐new state with both lists replaced
    emit(QuotesSuccess(
      quotes: updated,
      likedQuotes: oldLiked,
    ));
  }
}
