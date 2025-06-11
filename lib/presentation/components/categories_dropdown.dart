import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quoter/bloc/cubit/category_cubit.dart';
import 'package:quoter/bloc/quotes/quotes_bloc.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/presentation/extensions/string_extensions.dart';

class CategoriesDropdown extends StatelessWidget {
  const CategoriesDropdown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: BlocBuilder<CategoryCubit, String>(
        builder: (context, category) {
          // --- CHANGE: Get the CategoryCubit instance once here
          final categoryCubit = context.read<CategoryCubit>();
          final allCategories =
              categoryCubit.categories; // Access categories directly

          return DropdownMenu(
            initialSelection: category,
            trailingIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowDown01,
                color: kSecondaryDark),
            selectedTrailingIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowUp01, color: kSecondaryDark),
            textStyle: GoogleFonts.getFont('Montserrat',
                fontSize: 20, color: Colors.white),
            width: 250,
            inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: kSecondaryDark,
                  width: 1,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: kSecondaryDark,
                  width: 1,
                ),
              ),
            ),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStateProperty.all(kPrimaryLighterDark),
              elevation: WidgetStateProperty.all(1),
              minimumSize: WidgetStateProperty.all(
                const Size(238, 200), // Use const Size
              ),
              maximumSize: WidgetStateProperty.all(
                const Size(238, 500), // Use const Size
              ),
            ),
            label: Text(
              'Select category',
              style: GoogleFonts.getFont('Montserrat',
                  fontSize: 20, color: kSecondaryDark),
            ),
            onSelected: (String? value) {
              // --- CHANGE: Make value nullable as per DropdownMenu signature
              if (value == null) return; // Handle null case defensively

              if (value == 'Surprise Me') {
                categoryCubit
                    .clearCategory(); // --- CHANGE: Use the local cubit instance
                context.read<QuotesBloc>().add(LoadQuotes(category: ''));
              } else {
                categoryCubit.updateCategory(value
                    .toTitleCase); // --- CHANGE: Use the local cubit instance
                context.pop();
                context.read<QuotesBloc>().add(LoadQuotes(
                    category: categoryCubit
                        .state)); // --- CHANGE: Use the local cubit instance
              }
            },
            // --- CHANGE: Use the 'allCategories' list directly
            dropdownMenuEntries: allCategories.map((categoryItem) {
              return DropdownMenuEntry(
                value: categoryItem.toTitleCase,
                label: categoryItem.toTitleCase,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(kPrimaryLighterDark),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  textStyle: WidgetStateProperty.all(
                      GoogleFonts.getFont('Montserrat', fontSize: 20)),
                ),
              );
            }).toList(), // Convert iterable to List
          );
        },
      ),
    );
  }
}
