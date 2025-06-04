import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShareImageCubit extends Cubit<RepaintBoundary> {
  ShareImageCubit() : super(const RepaintBoundary());

  void setShareImage(RepaintBoundary image) {
    emit(image);
  }
}
