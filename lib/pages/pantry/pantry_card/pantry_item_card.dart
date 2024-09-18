import 'package:eatneat/pages/pantry/item_view_page.dart';
import 'package:eatneat/ui/options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:eatneat/models/pantry_item.dart';
import 'package:eatneat/providers/pantry_provider.dart';
import 'package:flutter/services.dart';

class PantryItemCard extends StatelessWidget {

  final PantryItem item;
  PantryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    // Render the item without a banner if it isn't expired, otherwise, add a banner saying 'EXPIRED'
    if (!item.isExpired()) {
      return renderCardWithoutBanner(context);
    } 
    else {
      return ClipRRect(
        child: Banner(
          color: Colors.red[600]!,
          message: "EXPIRED",
          location: BannerLocation.topStart,
          // Fog out the rest of the card to make it more obvious that this item is expired and make the banner stand out
          child: Opacity(
            opacity: 0.6,
            child: renderCardWithoutBanner(context),
          ),
        ),
      );
    }
  }

  Widget renderCardWithoutBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0), 
      child: GestureDetector(
        // If we tap the item go to its page
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ItemViewPage(item: item, actionType: ActionType.edit),)
            );
        },
        // Spawn the item card dialog
        onLongPress: () {
          OptionsDialog(actionItems: []);
          
          HapticFeedback.mediumImpact();
        },
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.5,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(14.0)),
                          image: DecorationImage(
                            image: NetworkImage(item.image ?? "https://assets.sainsburys-groceries.co.uk/gol/7931400/1/640x640.jpg"), 
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          item.name,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.grey[700]),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Card(
                          color: Colors.white,
                          elevation: 0.5,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.scale, size: 17, color: Colors.grey[800]),
                                // If the item has a weight of 0 we just care about its arbitrary quantity (ie. 2 "large" chicken breasts)
                                Text(" ${item.quantity} x ${item.weight == 0 ? "" : item.weightFormatted()}", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          elevation: 0.5,
                          color: item.colorCodeExpiry(context),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.timer, size: 17, color: Colors.grey[800]),
                                Text(" ${item.formatExpiryTime()}", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void deleteItem(PantryItem item, PantryProvider provider) {
    provider.removeItem(item);
  }
}