import 'package:eatneat/ui/magic_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eatneat/models/pantry_category.dart';
import 'package:eatneat/pages/pantry/pantry_card/pantry_item_card.dart';
import 'package:eatneat/pages/pantry/scanner/scan_failure_page.dart';
import 'package:eatneat/pages/pantry/scanner/scanner.dart';
import 'package:eatneat/pages/pantry/widgets/navigation_bar.dart';
import 'package:eatneat/providers/label_provider.dart';
import 'package:eatneat/providers/pantry_provider.dart';
import 'package:eatneat/pages/pantry/pantry_add/item_view_page.dart';
import 'package:eatneat/ui/buttons.dart';
import 'package:eatneat/util/debug.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class PantryPage extends StatefulWidget {
  @override
  PantryPageState createState() => PantryPageState();
}

class PantryPageState extends State<PantryPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pantry")
      ),
      body: Consumer2<PantryProvider, LabelProvider>(
        builder: (context, pantryProvider, labelProvider, child) {
          return Column(
            children: [
              SizedBox(height: 8),
              // Display the search and sorting box
              Navbar(),
              // Display all of the categories
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: pantryProvider.categories.length,
                        itemBuilder: (context, categoryIndex) {
                          PantryCategory category = pantryProvider.categories[categoryIndex];

                          return Column(
                            children: [
                              // Display category widget
                              Container(
                                width: double.infinity,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.06),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.blue,
                                      const Color.fromARGB(255, 46, 154, 243),
                                    ],
                                  ),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // The name of the category
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      // Quick click button to collapse/expand the category
                                      Spacer(),
                                      Buttons.minorIconButtonStyle(
                                        // TODO: I need a button which is remove_red_eye but with a line through it
                                        Icon((category.isHidden) ? Icons.remove_red_eye_sharp : Icons.remove_red_eye_sharp), 
                                        () {
                                          setState(() {
                                            category.toggleVisibility();
                                          });

                                          HapticFeedback.lightImpact();
                                        }, 
                                        Offset(0, -6)
                                      ),
                                      // Icons to edit the category
                                      Buttons.iconButtonStyle(Icon(Icons.more_horiz), () {}, Offset(0, -5)),
                                    ],
                                  ),
                                ),
                              ),
                              // Display children (PantryItemCard widgets) that belong to each of these categories
                              if(!category.isHidden)
                              SizedBox(
                                // This is probably a bad idea but we just set the height based on how many objects there are to render. 
                                // more than 2 objects = we use the second row of space then we scroll horizontally. 
                                height: (pantryProvider.categories[categoryIndex].itemCount <= 2) ? 220 : 470, 
                                child: (category.isHidden) ? null : GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 240,
                                    mainAxisExtent: 210,
                                    mainAxisSpacing: 8, // Spacing between items vertically
                                    crossAxisSpacing: 10, // Spacing between items horizontally
                                  ),
                                  // The number of items to render is the number of PantryItems in the current category of the iteration
                                  itemCount: pantryProvider.categories[categoryIndex].itemCount,
                                  itemBuilder: (context, itemIndex) {
                                    return PantryItemCard(
                                      item: pantryProvider.categories[categoryIndex].items[itemIndex],
                                    );
                                  },
                                ),
                              ),

                              if(!category.isHidden)
                              // Page viewer widget ( . . . )
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  growable: true,
                                  (category.itemCount <= 4) ? 0 : (category.itemCount / 4).ceil(),
                                  (index) {
                                    return Center(
                                      child: IconButton(
                                        icon: Icon(
                                            color: (category.pageIndex == index) ? Colors.blueAccent : const Color.fromARGB(255, 68, 68, 68),
                                            Icons.circle,
                                            size: 13,
                                          ),
                                        onPressed: () {
                                          setState(() {
                                            category.pageIndex = index;
                                            HapticFeedback.selectionClick();
                                          });                 
                                        }
                                      ),
                                    );
                                  }
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                    // TODO: Improve this button by encapsulating default full page translucent button and calling the styling method from Buttons static class
                    // Add category button

                    TextButton.icon(
                      icon: Icon(Icons.add),
                      label: Text("Add Category"),
                      style: Buttons.genericButtonStyle(0.8, null).copyWith(textStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                      onPressed: () {

                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: SpeedDial(
        onOpen: () {
          HapticFeedback.heavyImpact();
        },
        icon: Icons.add,
        iconTheme: IconThemeData(
          weight: 30,
          size: 26,
        ),
        backgroundColor: Colors.blue.withOpacity(0.9),
        foregroundColor: Colors.white,
        buttonSize: Size(60, 60),
        children: [
          SpeedDialChild(
            child: Icon(Icons.barcode_reader),
            label: "Scan Barcode",
            onTap: () async {
              HapticFeedback.mediumImpact();
              
              await Scanner.scan(context, OriginPage.pantryPage);
            }
          ),
          SpeedDialChild(
            child: Icon(Icons.plus_one),
            label: "Manually Add",
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder:(context) => ItemViewPage(),
                )
              );
            }
          ),

          SpeedDialChild(
            child: Icon(Icons.tab),
            label: "[DEBUG] Create test items",
            onTap: () {
              Debug().configure(Provider.of<PantryProvider>(context, listen:false), Provider.of<LabelProvider>(context, listen:false));
            }
          ),

          SpeedDialChild(
            child: Icon(Icons.tab),
            label: "[DEBUG] Magic Keyboard",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MagicKeyboard())
              );
            }

          ),

          SpeedDialChild(
            child: Icon(Icons.tab),
            label: "[DEBUG] Barcode scan failure",
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BarcodeScanFailurePage())
              );
            }
          ),
        ]
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}