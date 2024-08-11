import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CustomDropdown<T> extends StatelessWidget {
  final itemBuilder;
  final style;
  final emptyText;
  final label;
  final onChanged;
  final asyncItems;
  final dropdownBuilder;
  final validator;
  final selectedItem;
  final items;
  const CustomDropdown(
      {Key? key,
      this.itemBuilder,
      this.items,
      this.style,
      this.emptyText,
      this.label,
      this.onChanged,
      this.asyncItems,
      this.validator,
      this.selectedItem,
      this.dropdownBuilder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      validator: this.validator,
      selectedItem: this.selectedItem,
      popupProps: PopupProps.dialog(
        itemBuilder: this.itemBuilder,
        emptyBuilder: (BuildContext context, String? _) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(20),
            child: Text(
              this.emptyText,
              style: this.style,
              textAlign: TextAlign.center,
            ),
          );
        },
        showSearchBox: true,
        isFilterOnline: true,
        scrollbarProps: ScrollbarProps(
          thickness: 7,
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: this.label,
          hintText: this.label,
        ),
      ),
      onChanged: this.onChanged,
      asyncItems: this.asyncItems,
      dropdownBuilder: this.dropdownBuilder,

      // popupSafeArea:
      // PopupSafeArea(
      //     top: true,
      //     bottom: true),
    );
  }
}
