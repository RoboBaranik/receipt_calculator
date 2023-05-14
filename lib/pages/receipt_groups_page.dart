import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_payment.dart';
import 'package:receipt_calculator/helper.dart';
import 'package:receipt_calculator/routes.dart';
import 'package:receipt_calculator/widgets/drawer.dart';
import 'package:receipt_calculator/widgets/receipt_groups/date.dart';

class ReceiptGroupsPage extends StatefulWidget {
  static const String route = '/groups';
  final List<Event> groups;
  ReceiptGroupsPage({super.key, required this.groups}) {
    for (var group in groups) {
      if (group.receipts.isEmpty) {
        group.receipts.addAll([Routes.mocked1, Routes.mocked2]);
      }
    }
  }

  @override
  State<ReceiptGroupsPage> createState() => _ReceiptGroupsPageState();
}

enum _ReceiptGroupsPageTab { groups, members }

class _ReceiptGroupsPageState extends State<ReceiptGroupsPage> {
  _ReceiptGroupsPageTab selectedTab = _ReceiptGroupsPageTab.groups;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt groups')),
      drawer: const Drawer(
        child: AppDrawer(currentRoute: Routes.receiptList),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // showDialog<Receipt>(
          //   context: context,
          //   builder: (_) => const DialogReceiptAdd(),
          // ).then((createdReceipt) {
          //   if (createdReceipt != null) {
          //     debugPrint('New receipt $createdReceipt');
          //     widget.group.receipts.add(createdReceipt);
          //     setState(() {});
          //   }
          // });
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab.index,
        onTap: (tabIndex) => setState(() {
          selectedTab = _ReceiptGroupsPageTab.values[tabIndex];
        }),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Events'),
          BottomNavigationBarItem(
              icon: Icon(Icons.groups), label: 'Event members'),
        ],
      ),
      body: [groupsTab(), membersTab()][selectedTab.index],
    );
  }

  Widget groupsTab() {
    return ListView.separated(
        itemBuilder: (context, index) {
          Event event = widget.groups.elementAt(index);
          String groupName =
              'Abraham Asertive, Betty Bored, Cindy Clever'; //event.group.toString();

          List<String> stores = event.allStoresToString(39);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              debugPrint('Tapped');
            },
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: groupName.length > 60
                    ? [
                        DateWidget(date: event.timeCreated),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            groupName,
                            maxLines: 4,
                            style: TextStyle(
                                fontSize: groupName.length > 125 ? 12 : 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]
                    : [
                        DateWidget(date: event.timeCreated),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: stores.length > 1
                                ? [
                                    Text(
                                      groupName,
                                      maxLines: 2,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(children: [
                                      Text(stores[0], maxLines: 1),
                                      Text(
                                        stores[1],
                                        maxLines: 1,
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    ]),
                                  ]
                                : [
                                    Text(
                                      groupName,
                                      maxLines: 2,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(stores[0], maxLines: 1),
                                  ],
                          ),
                        ),
                      ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Container(
            height: 1,
            color: Colors.black12,
          );
        },
        itemCount: 1);
  }

  Widget membersTab() {
    return Container();
  }
}
