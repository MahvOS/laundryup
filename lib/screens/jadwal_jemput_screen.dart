import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:LaundryUp/generated/app_localizations.dart';

class JadwalJemputScreen extends StatefulWidget {
  const JadwalJemputScreen({super.key});

  @override
  State<JadwalJemputScreen> createState() => _JadwalJemputScreenState();
}

class _JadwalJemputScreenState extends State<JadwalJemputScreen> {
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/staff/bookings'),
      );
      if (response.statusCode == 200) {
        final allBookings = jsonDecode(response.body);
        // Filter bookings with pickup delivery
        setState(() {
          _bookings = allBookings.where((booking) {
            final type = (booking['delivery_type'] ?? '').toString().trim().toLowerCase();
            return type == 'jemput';
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return dateString.split('T')[0]; // Fallback
    }
  }

  String _formatTime(String timeString) {
    // Assuming time is stored as HH:MM
    if (timeString.contains(':')) {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1].split(' ')[0]) ?? 0; // Handle any extra parts
        // Format as HH:MM
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    }
    return timeString; // Fallback
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _loadBookings, child: Text(l10n.tryAgain)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pickupSchedule),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: ListView.builder(
          padding: const EdgeInsets.all(24.0),
          itemCount: _bookings.length,
          itemBuilder: (context, index) {
            final booking = _bookings[index];
            final status = (booking['current_status'] ?? 'Diterima').toString();
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => _updateStatus(booking['id'], status, booking['delivery_type'] ?? 'Jemput', l10n),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Time Section
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.access_time_filled_rounded, color: theme.colorScheme.primary, size: 20),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(booking['time_slot']),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Detail Section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        booking['customer_email'],
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
                                      onPressed: () => _confirmDelete(booking['id'], l10n),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                _buildStatusBadge(status, theme, l10n),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.local_laundry_service_outlined, size: 14, color: theme.colorScheme.outline),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        booking['service_name'],
                                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined, size: 14, color: theme.colorScheme.outline),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatDate(booking['booking_date']),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (booking['whatsapp'] != null && booking['whatsapp'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                                onPressed: () => _launchWhatsApp(
                                  booking['whatsapp'], 
                                  l10n.contactCustomerMsg(booking['customer_email'], booking['delivery_type']),
                                  l10n
                                ),
                              icon: const Icon(Icons.chat_outlined, size: 18),
                              label: Text(l10n.contactCustomer),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                                side: const BorderSide(color: Colors.green),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _buildStatusBadge(String status, ThemeData theme, dynamic l10n) {
    Color color;
    String displayStatus = status;

    switch (status) {
      case 'Diterima': 
        color = theme.colorScheme.primary; 
        displayStatus = l10n.received;
        break;
      case 'Siap Diambil':
        color = Colors.orange;
        displayStatus = l10n.readyToPickup;
        break;
      case 'Siap Dikirim': 
        color = Colors.orange; 
        displayStatus = l10n.readyToDeliver;
        break;
      case 'Selesai': 
        color = theme.colorScheme.secondary; 
        displayStatus = l10n.done;
        break;
      default: 
        color = Colors.blue;
        if (status.isEmpty) displayStatus = l10n.process;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  void _confirmDelete(int bookingId, dynamic l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteBookingTitle),
        content: Text(l10n.deleteBookingConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              try {
                await ApiService.staffDeleteBooking(bookingId);
                if (!mounted) return;
                Navigator.pop(context);
                _loadBookings();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.deletedSuccess)));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(String phone, String message, dynamic l10n) async {
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.startsWith('0')) cleanPhone = '62${cleanPhone.substring(1)}';
    final url = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeFull(message)}");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.waError)));
    }
  }

  void _updateStatus(int bookingId, String currentStatus, String deliveryType, dynamic l10n) {
    String? notes;
    String selectedStatus = currentStatus;
    final terminalStatus = deliveryType == 'Jemput' ? l10n.readyToDeliver : l10n.readyToPickup;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.updateStatus),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: () {
                  final s = selectedStatus.trim().toLowerCase();
                  if (s.contains('siap')) return terminalStatus;
                  
                  final statusMap = {
                    l10n.received: 'Diterima',
                    l10n.weighed: 'Ditimbang',
                    l10n.washed: 'Dicuci',
                    l10n.dried: 'Dikeringkan',
                    l10n.ironed: 'Disetrika',
                    l10n.done: 'Selesai',
                  };
                  
                  for (var entry in statusMap.entries) {
                    if (entry.key.toLowerCase() == s || entry.value.toLowerCase() == s) return entry.key;
                  }
                  return l10n.received;
                }(),
                isExpanded: true,
                items: [
                  l10n.received, l10n.weighed, l10n.washed, l10n.dried, l10n.ironed, terminalStatus, l10n.done
                ].map<DropdownMenuItem<String>>((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (value) => setState(() {
                  if (value != null) {
                    final reverseMap = {
                      l10n.received: 'Diterima',
                      l10n.weighed: 'Ditimbang',
                      l10n.washed: 'Dicuci',
                      l10n.dried: 'Dikeringkan',
                      l10n.ironed: 'Disetrika',
                      l10n.done: 'Selesai',
                      l10n.readyToDeliver: 'Siap Dikirim',
                      l10n.readyToPickup: 'Siap Diambil',
                    };
                    selectedStatus = reverseMap[value] ?? value;
                  }
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: l10n.optionalNotes),
                onChanged: (value) => notes = value.isEmpty ? null : value,
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            TextButton(
              onPressed: () async {
                try {
                  final response = await http.post(
                    Uri.parse('${ApiService.baseUrl}/staff/bookings/$bookingId/update-status'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'new_status': selectedStatus, 'updated_by': 'Staff', 'notes': notes}),
                  );
                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    _loadBookings();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: Text(l10n.update),
            ),
          ],
        ),
      ),
    );
  }
}