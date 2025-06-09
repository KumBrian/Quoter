// liked_quotes_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/data/repository/hive_quote.dart';
import 'package:quoter/models/quote.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

part 'liked_quotes_event.dart';
part 'liked_quotes_state.dart';

class LikedQuotesBloc extends Bloc<LikedQuotesEvent, LikedQuotesState> {
  final LikedQuotesRepository repository;

  LikedQuotesBloc(this.repository) : super(LikedQuotesLoading()) {
    on<LoadLikedQuotes>(_onLoadLikedQuotes);
    on<AddFavorite>(_onAddFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);
  }

  Future<void> _onLoadLikedQuotes(
    LoadLikedQuotes event,
    Emitter<LikedQuotesState> emit,
  ) async {
    emit(LikedQuotesLoading());
    final allLiked = repository.getAllLikedQuotes();
    emit(LikedQuotesLoaded(allLiked));
  }

  Future<void> _onAddFavorite(
    AddFavorite event,
    Emitter<LikedQuotesState> emit,
  ) async {
    if (state is! LikedQuotesLoaded) return;
    final current = (state as LikedQuotesLoaded).likedQuotes;
    // 1) Add to Hive
    await repository.addQuote(event.quote);
    // 2) Build new list
    final newList = List<Quote>.from(current)..add(event.quote);

    if (event.context.mounted) {
      showTopSnackBar(
        Overlay.of(event.context),
        CustomSnackBar.info(
            backgroundColor: kSecondaryDark.withAlpha(200),
            textStyle: GoogleFonts.getFont(
              'Montserrat',
              color: kPrimaryDark,
              fontSize: 20,
              fontWeight: FontWeight.w100,
            ),
            message: 'You Liked a Quote By ${event.quote.author}'),
      );
    }
    emit(LikedQuotesLoaded(newList));
  }

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<LikedQuotesState> emit,
  ) async {
    if (state is! LikedQuotesLoaded) return;
    final current = (state as LikedQuotesLoaded).likedQuotes;
    // 1) Remove from Hive
    await repository.removeQuote(event.quote);
    // 2) Build new list
    final newList = current.where((q) => q != event.quote).toList();

    if (event.context.mounted) {
      showTopSnackBar(
        Overlay.of(event.context),
        CustomSnackBar.info(
            backgroundColor: kPrimaryDark.withAlpha(200),
            textStyle: GoogleFonts.getFont(
              'Montserrat',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w100,
            ),
            message: 'You DisLiked a Quote By ${event.quote.author}'),
      );
    }
    emit(LikedQuotesLoaded(newList));
  }
}
