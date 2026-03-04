import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import 'widgets/server_list.dart';
import 'widgets/channel_list.dart';

class ServerChannelDrawer extends StatelessWidget {
  const ServerChannelDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine screen width to give the drawer an appropriate width.
    // We don't want it to take 100% of the screen.
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.85;

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        backgroundColor: AuraTheme.backgroundSecondary,
        child: Row(
          children: [
            // Left Strip: Server List
            const SizedBox(width: 72, child: ServerList()),
            // Right Area: Channel List for the selected server
            const Expanded(child: ChannelList()),
          ],
        ),
      ),
    );
  }
}
