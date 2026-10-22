import 'package:flutter/material.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/features/dashboard/dashboard_screen.dart';
import 'package:saleskido/features/leads/screens/lead_list_screen.dart';
import 'package:saleskido/features/profile/screens/profile_screen.dart';
import 'package:saleskido/features/quotations/screens/quotation_list_screen.dart';
import 'package:saleskido/features/whatsapp/screens/chat_list_screen.dart';
import 'package:saleskido/shared/widgets/app_drawer.dart';
import 'package:saleskido/shared/widgets/bottom_nav_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _titles = const [
    'Dashboard',
    'Lead Manage',
    'My WhatsApp',
    'Quotation',
    'Profile',
  ];

  final _drawerRoutes = const [
    'dashboard',
    'leads',
    'whatsapp',
    'quotation',
    'dashboard',
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialTab.clamp(0, 4);
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _index = widget.initialTab.clamp(0, 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(_titles[_index]),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: AppDrawer(activeRoute: _drawerRoutes[_index]),
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          LeadListScreen(),
          ChatListScreen(),
          QuotationListScreen(),
          ProfileScreen(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 28),
        child: SkWhatsAppFab(
          active: _index == 2,
          onPressed: () => setState(() => _index = 2),
        ),
      ),
      bottomNavigationBar: SkBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
