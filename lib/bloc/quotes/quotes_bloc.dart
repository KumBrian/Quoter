import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quoter/data/repository/quotes_repository.dart';
import 'package:quoter/models/quote.dart';

part 'quotes_event.dart';
part 'quotes_state.dart';

class QuotesBloc extends Bloc<QuotesEvent, QuotesState> {
  final QuotesRepository quotesRepository;

  QuotesBloc(this.quotesRepository) : super(QuotesLoading()) {
    on<LoadQuotes>(_onLoadQuotes);
  }

  Future<void> _onLoadQuotes(
    LoadQuotes event,
    Emitter<QuotesState> emit,
  ) async {
    emit(QuotesLoading());
    try {
      final quotes = await quotesRepository.fetchQuotes();
      emit(QuotesLoaded(allQuotes: quotes));
    } catch (e) {
      emit(QuotesError(message: e.toString()));
    }
  }
}
