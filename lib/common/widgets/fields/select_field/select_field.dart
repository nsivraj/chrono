import 'package:clock_app/common/logic/show_select.dart';
import 'package:clock_app/common/types/file_item.dart';
import 'package:clock_app/common/types/select_choice.dart';
import 'package:clock_app/common/widgets/fields/select_field/field_cards/audio_field_card.dart';
import 'package:clock_app/common/widgets/fields/select_field/field_cards/color_field_card.dart';
import 'package:clock_app/common/widgets/fields/select_field/field_cards/text_field_card.dart';
import 'package:flutter/material.dart';

class SelectField extends StatefulWidget {
  const SelectField({
    super.key,
    required this.selectedIndices,
    required this.title,
    this.description,
    required this.choices,
    required this.onChanged,
    this.multiSelect = false,
  });

  final List<int> selectedIndices;
  final String title;
  final String? description;
  final bool multiSelect;
  final List<SelectChoice> choices;
  final void Function(List<int> indices) onChanged;

  @override
  State<SelectField> createState() => _SelectFieldState();
}

class _SelectFieldState<T> extends State<SelectField> {
  Widget _getFieldCard() {
    SelectChoice choice = widget.choices[widget.selectedIndices[0]];

    if (choice.value is Color) {
      return ColorFieldCard(
        choice: SelectChoice<Color>(
            name: choice.name,
            value: choice.value,
            description: choice.description),
        title: widget.title,
      );
    }
    if (choice.value is FileItem) {
      return AudioFieldCard(
        choice: SelectChoice<FileItem>(
            name: choice.name,
            value: choice.value,
            description: choice.description),
        title: widget.title,
      );
    }

    return TextFieldCard(
      choice: choice,
      title: widget.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    void showSelect(List<int>? selectedIndices) async {
      setState(() {
        widget.onChanged(selectedIndices ?? widget.selectedIndices);
      });
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showSelectBottomSheet(context, showSelect,
            title: widget.title,
            description: widget.description,
            choices: widget.choices,
            initialSelectedIndices: widget.selectedIndices,
            multiSelect: widget.multiSelect),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _getFieldCard(),
        ),
      ),
    );
  }
}
