import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quoter/bloc/cubit/category_cubit.dart';
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
          return DropdownMenu(
              initialSelection: category,
              trailingIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  color: kSecondaryDark),
              selectedTrailingIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowUp01,
                  color: kSecondaryDark),
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
                  Size(238, 200),
                ),
                maximumSize: WidgetStateProperty.all(
                  Size(238, 500),
                ),
              ),
              label: Text(
                'Select category',
                style: GoogleFonts.getFont('Montserrat',
                    fontSize: 20, color: kSecondaryDark),
              ),
              onSelected: (value) {
                if (value == 'Surprise Me') {
                  context.read<CategoryCubit>().clearCategory();
                } else {
                  context
                      .read<CategoryCubit>()
                      .updateCategory(value!.toTitleCase);
                }
              },
              dropdownMenuEntries: List.generate(
                  context.read<CategoryCubit>().categories.length, (index) {
                return DropdownMenuEntry(
                  value: context
                      .read<CategoryCubit>()
                      .categories[index]
                      .toTitleCase,
                  label: context
                      .read<CategoryCubit>()
                      .categories[index]
                      .toTitleCase,
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(kPrimaryLighterDark),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    textStyle: WidgetStateProperty.all(
                        GoogleFonts.getFont('Montserrat', fontSize: 20)),
                  ),
                );
              }));
        },
      ),
    );
  }
}
