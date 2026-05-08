import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/calendar_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/mail_screen.dart';

class MainNavigationHolder extends StatefulWidget {
  const MainNavigationHolder({super.key});

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    ExploreScreen(), // Stream
    NotesScreen(),   // Hub (Notes & Transcripts)
    MailScreen(),    // Mail
    CalendarScreen(), // Schedule
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSyncing = Provider.of<CalendarProvider>(context).isSyncing;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
              child: Container(
                key: ValueKey<int>(_selectedIndex),
                child: _widgetOptions.elementAt(_selectedIndex),
              ),
            ),
            if (isSyncing)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: const Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.grid_view_outlined, "DASHBOARD"),
            _buildNavItem(1, Icons.explore_outlined, "STREAM"),
            _buildNavItem(2, Icons.auto_awesome, "HUB"),
            _buildNavItem(3, Icons.mail_outline, "MAIL"),
            _buildNavItem(4, Icons.calendar_month_outlined, "SCHEDULE"),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
        onPressed: () {
          // This is a bit tricky because the method is in DashboardScreen
          // but we can just show a snackbar or use a more global way
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Use 'QUICK NOTE' in the dashboard to add tasks/notes")),
          );
        },
        backgroundColor: const Color(0xFF1A2E1A),
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected ? Colors.black : Colors.grey.shade400,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.5,
              color: isSelected ? Colors.black : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
