import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/calendar_provider.dart';
import '../providers/auth_provider.dart';
import '../models/calendar_event.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  void _showAddEventDialog(BuildContext context, CalendarProvider provider) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    DateTime selectedTime = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add Event", style: GoogleFonts.instrumentSerif(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: "Event Title", border: UnderlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(hintText: "Location (optional)", border: UnderlineInputBorder()),
              ),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Time"),
                trailing: Text(DateFormat('hh:mm a').format(selectedTime)),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(selectedTime));
                  if (time != null) {
                    setModalState(() {
                      selectedTime = DateTime(
                        selectedTime.year, selectedTime.month, selectedTime.day,
                        time.hour, time.minute
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final newEvent = CalendarEvent(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        startTime: selectedTime,
                        endTime: selectedTime.add(const Duration(hours: 1)),
                        location: locationController.text,
                        requiresCommute: locationController.text.isNotEmpty,
                      );
                      provider.addEvent(newEvent);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event added")));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A2E1A), foregroundColor: Colors.white),
                  child: const Text("SAVE EVENT"),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: authProvider.user?.photoURL != null 
                ? NetworkImage(authProvider.user!.photoURL!) 
                : null,
            child: authProvider.user?.photoURL == null 
                ? const Icon(Icons.person_outline, size: 20, color: Colors.black54) 
                : null,
          ),
        ),
        title: Text("Kairo", style: GoogleFonts.instrumentSerif(
          fontSize: 24, fontStyle: FontStyle.italic, color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black, size: 22),
            onPressed: () {
              Provider.of<CalendarProvider>(context, listen: false).syncWithGoogle();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Settings coming soon")));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<CalendarProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Schedule", style: GoogleFonts.instrumentSerif(fontSize: 36, color: Colors.black)),
                        Text(DateFormat('EEEE, MMM d').format(provider.selectedDay ?? DateTime.now()), 
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _showAddEventDialog(context, provider),
                      icon: const Icon(Icons.add_circle_outline, size: 28),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildDateScroller(provider),
              const SizedBox(height: 32),
              Expanded(
                child: _buildTimeline(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateScroller(CalendarProvider provider) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Show 2 weeks
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index - 3));
          final isSelected = provider.selectedDay?.day == date.day && 
                            provider.selectedDay?.month == date.month;
          
          return GestureDetector(
            onTap: () => provider.selectDay(date),
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1A2E1A) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 9, 
                      fontWeight: FontWeight.bold, 
                      color: isSelected ? Colors.white54 : Colors.grey.shade400
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: isSelected ? Colors.white : Colors.black
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline(CalendarProvider provider) {
    final events = provider.eventsForSelectedDay;
    
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("No events for this day", style: TextStyle(color: Colors.grey.shade400)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildTimelineItem(
          DateFormat('HH:mm').format(event.startTime),
          _buildEventCard(context, event)
        );
      }
    );
  }

  Widget _buildTimelineItem(String time, Widget card) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(time, style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
            ),
          ),
          Container(
            width: 1,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: card,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, CalendarEvent event) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("CALENDAR EVENT", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
              GestureDetector(
                onTap: () {
                  Provider.of<CalendarProvider>(context, listen: false).removeEvent(event.id);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event removed")));
                },
                child: const Icon(Icons.close, size: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(event.title, style: GoogleFonts.instrumentSerif(fontSize: 18, height: 1.1)),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(DateFormat('hh:mm a').format(event.startTime), style: const TextStyle(fontSize: 11, color: Colors.grey)),
              if (event.location != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Expanded(child: Text(event.location!, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMailCard(String title, String timeAgo, String snippet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2ED),
        borderRadius: BorderRadius.circular(24),
        border: const Border(left: BorderSide(color: Color(0xFF8B0000), width: 3)), // Deep red accent for urgent mail
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, size: 10, color: Color(0xFF8B0000)),
              const SizedBox(width: 4),
              const Text("URGENT MAIL", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF8B0000), letterSpacing: 0.5)),
              const Spacer(),
              Text(timeAgo, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.instrumentSerif(fontSize: 18, height: 1.1)),
          const SizedBox(height: 8),
          Text(snippet, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMailBtn("Review Now", const Color(0xFF1A2E1A), Colors.white),
              const SizedBox(width: 8),
              _buildMailBtn("Archive", Colors.white, Colors.black),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMailBtn(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: text)),
    );
  }
}
