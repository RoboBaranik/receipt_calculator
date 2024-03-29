import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:receipt_calculator/data/receipt_payment.dart';
import 'package:receipt_calculator/helper.dart';
import 'package:receipt_calculator/routes.dart';
import 'package:receipt_calculator/widgets/drawer.dart';
import 'package:receipt_calculator/widgets/person_chip.dart';
import 'package:receipt_calculator/widgets/receipt_groups/date.dart';
import 'package:receipt_calculator/widgets/receipt_groups/dialog_event_add.dart';

class ReceiptGroupsPage extends StatefulWidget {
  static const String route = 'groups';
  final List<Event> events;
  final List<PersonGroup> memberGroups;
  ReceiptGroupsPage(
      {super.key, required this.events, required this.memberGroups}) {
    for (var event in events) {
      if (event.receipts.isEmpty) {
        event.receipts.addAll([Routes.mocked1, Routes.mocked2]);
      }
    }
  }

  @override
  State<ReceiptGroupsPage> createState() => _ReceiptGroupsPageState();
}

enum _ReceiptGroupsPageTab { events, members }

class _ReceiptGroupsPageState extends State<ReceiptGroupsPage> {
  _ReceiptGroupsPageTab selectedTab = _ReceiptGroupsPageTab.events;

  void openEvent(Event event) {
    Navigator.pushNamed(context, Routes.receiptList, arguments: event);
  }

  void createEvent() {
    showDialog<PersonGroup>(
      context: context,
      builder: (_) => DialogEventAdd(groups: widget.memberGroups),
    ).then((group) {
      if (group == null) return;
      showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1970),
              lastDate: DateTime(3000))
          .then((date) async {
        if (date == null) {
          Event createdEvent = Event(group: group);
          widget.events.add(createdEvent);
          setState(() {});
          return;
        }
        TimeOfDay? time = await showTimePicker(
            context: context, initialTime: TimeOfDay.now());
        date = Helper.mergeDateAndTime(date, time);

        Event createdEvent = Event(group: group, created: date);
        widget.events.add(createdEvent);
        setState(() {});
      });
      // debugPrint('Group ${group.toString()} was selected');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: selectedTab == _ReceiptGroupsPageTab.events
              ? const Text('Events')
              : const Text('Groups')),
      // drawer: const Drawer(
      //   child: AppDrawer(currentRoute: Routes.receiptList),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedTab == _ReceiptGroupsPageTab.events) {
            createEvent();
          }
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
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Groups'),
        ],
      ),
      body: [eventsTab(), membersTab()][selectedTab.index],
    );
  }

  Widget eventsTab() {
    return ListView.separated(
        itemBuilder: (context, index) {
          Event event = widget.events.elementAt(index);
          String groupName = event.group.toString();
          // 'Abraham Asertive, Betty Bored, Cindy Clever';

          List<String> stores = event.allStoresToString(39);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              openEvent(event);
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
        itemCount: widget.events.length);
  }

  Widget membersTab() {
    return ListView.separated(
        itemBuilder: (context, index) {
          PersonGroup group = widget.memberGroups.elementAt(index);
          return Container(
            decoration: const BoxDecoration(color: Colors.white),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: group.members
                      .mapIndexed((index, member) =>
                          PersonChip(index: index, member: member))
                      .toList(),
                ),
                // ...group.members
                //     .mapIndexed((index, member) => Container(
                //           decoration: BoxDecoration(
                //               border: Border.all(color: Colors.black12),
                //               borderRadius: BorderRadius.circular(16)),
                //           padding:
                //               const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                //           child: Row(
                //             mainAxisSize: MainAxisSize.min,
                //             children: [
                //               Icon(
                //                 Icons.person,
                //                 color: Helper.colorPerPerson[index % 10],
                //               ),
                //               const SizedBox(width: 4),
                //               Text(member.name)
                //             ],
                //           ),
                //         ))
                //     .toList()
              ],
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Container(height: 1, color: Colors.black12);
        },
        itemCount: widget.memberGroups.length);
  }
}
