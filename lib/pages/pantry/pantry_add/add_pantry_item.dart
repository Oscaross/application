import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:namer_app/models/label_item.dart';
import 'package:namer_app/models/pantry_item.dart';
import 'package:namer_app/providers/label_provider.dart';
import 'package:namer_app/providers/pantry_provider.dart';
import 'package:namer_app/pages/pantry/widgets/label_bar.dart';
import 'package:namer_app/ui/buttons.dart';
import 'package:provider/provider.dart';

class AddItemPage extends StatefulWidget {
  @override
  AddItemPageState createState() => AddItemPageState();
}

class AddItemPageState extends State<AddItemPage> {
  static const double labelSpacing = 20;

  final TextEditingController _nameController = TextEditingController();
  
  double _weight = 0;
  bool _isQuantity = true; // true for a quantity (ie. 3 chicken breast), false for kgs

  // Expiry management system
  DateTime? _expires;

  // Open the calendar dialog, at some point in the future we expect a date to be picked but no result back from this call - hence it is void.
  Future<void> selectDate(BuildContext context) async {
    final DateTime? expiry = await showDatePicker(
      context:context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Can't have something expire before now!
      lastDate: DateTime(2100), // An arbitrarily large end window - could potentially be changed...
    );

    if(expiry != null && expiry != _expires) {
      setState(() {
        _expires = expiry;
      });
    }
  }

  // The set of labels that need to be assigned to this item
  Set<LabelItem>? selectedLabelSet;

  @override
  Widget build(BuildContext context) {
    var labelProvider = Provider.of<LabelProvider>(context);
    selectedLabelSet = labelProvider.selectedLabels;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Pantry Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                  child: TextField(
                    autocorrect: true,
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText:"Item Name"
                    ),
                    keyboardType:TextInputType.text,)
                    ),
            // Break up the space between the item name and quantity input
            SizedBox(height: labelSpacing),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SpinBox(
                    value: _weight,
                    onChanged: (value) {
                      setState(() {
                        _weight = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                    ),
                    min: 0,
                    max:100000,
                    // TODO: Implement smart STEP
                    step: 100,
                    decimals: 1,
                  ),
                ),

                SizedBox(width: 20),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ToggleButtons(
                      borderRadius: BorderRadius.circular(20),
                      isSelected: [_isQuantity, !_isQuantity],
                      onPressed: (int index) {
                        setState(() {
                          _isQuantity = index == 0;
                        });
                      },
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('qty'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('gram'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: labelSpacing*1.5),
            InkWell(
              onTap: () => selectDate(context),
              child: InputDecorator(decoration: InputDecoration(
                labelText: "Expires on",
                border: OutlineInputBorder(),
              ),
              child: Text(
              _expires == null ? "None specified" : '${_expires!.day}/${_expires!.month}/${_expires!.year}',
              ),
              )
            ),
            SizedBox(height: labelSpacing),

            // TODO: Make it so that somehow the set of selected labels is applied to the pantry item in backend code

            LabelBar(),

            SizedBox(height:labelSpacing),
            Center(
              child: ElevatedButton.icon(
                label: Text("Add Item"),
                icon: Icon(Icons.add),
                style: Buttons.genericButtonStyle(1),
                onPressed: () {
                  // Add item to pantry logic
                  var name = _nameController.text;
                  var quantity = 1;
                  
                  if(_weight != 0 && _weight > 0 && _expires != null) {
                    var pantryItem = PantryItem(expiry: _expires!, name: name, weight: _weight, added: DateTime.now(), quantity: quantity,  labelSet: selectedLabelSet!);
                    Provider.of<PantryProvider>(context, listen:false).addItem(pantryItem);
                  }
                  else {
                    print("Error validating input to Pantry!");
                  }
                  
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
