import 'package:flutter_bloc/flutter_bloc.dart';

class SwiperCubit extends Cubit<int> {
  SwiperCubit() : super(0);

  void updateIndex(int newIndex) => emit(newIndex);
}
