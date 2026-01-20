import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:LaundryUp/generated/app_localizations.dart';
import '../services/api_service.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  List<dynamic> _bookings = [];
  Map<String, int> _orderCounts = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load both bookings and counts
      final bookingsResponse = await http.get(
        Uri.parse('${ApiService.baseUrl}/staff/bookings'),
      );
      final countsResponse = await http.get(
        Uri.parse('${ApiService.baseUrl}/staff/order-counts'),
      );

      if (bookingsResponse.statusCode == 200 && countsResponse.statusCode == 200) {
        final List<dynamic> bookingsData = jsonDecode(bookingsResponse.body);
        final Map<String, int> countsData = Map<String, int>.from(jsonDecode(countsResponse.body));
        
        // Manual override for 'Selesai' count if API is lagging
        final manualSelesai = bookingsData.where((b) => b['current_status'] == 'Selesai').length;
        if (manualSelesai > (countsData['selesai'] ?? 0)) {
          countsData['selesai'] = manualSelesai;
        }

        setState(() {
          _bookings = bookingsData;
          _orderCounts = countsData;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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
              ElevatedButton(onPressed: _loadData, child: Text(l10n.tryAgain)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.staffPortal),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: l10n.refreshData,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_id');
                await prefs.remove('user_role');
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(l10n.todaySummary, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 20),
            
            // Statistics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 0.7, // Increased to allow more vertical space
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildCountCard(l10n.newOrderLabel, _orderCounts['orderBaru'] ?? 0, theme.colorScheme.primary, Icons.new_releases_rounded),
                _buildCountCard(l10n.process, _orderCounts['dalamProses'] ?? 0, Colors.orange, Icons.cached_rounded),
                _buildCountCard(l10n.done, _orderCounts['selesai'] ?? _orderCounts['orderSelesai'] ?? 0, theme.colorScheme.secondary, Icons.check_circle_rounded),
              ],
            ),
            
            const SizedBox(height: 32),
            Text(l10n.quickActions, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStaffActionButton(
                    icon: Icons.list_alt_rounded,
                    label: l10n.viewOrders,
                    color: theme.colorScheme.primary,
                    onPressed: () => Navigator.pushNamed(context, '/order-masuk'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStaffActionButton(
                    icon: Icons.delivery_dining_rounded,
                    label: l10n.pickupSchedule,
                    color: theme.colorScheme.secondary,
                    onPressed: () => Navigator.pushNamed(context, '/jadwal-jemput'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.latestBooking, style: theme.textTheme.titleLarge),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/order-masuk'),
                  child: Text(l10n.seeAll),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            if (_bookings.isEmpty)
              _buildEmptyState(theme, l10n)
            else
              ..._bookings.take(5).map((booking) => _buildBookingListItem(booking, theme, l10n)),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildStaffActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingListItem(dynamic booking, ThemeData theme, dynamic l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  radius: 20,
                  child: Icon(Icons.person_outline, color: theme.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['customer_email'],
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        booking['service_name'],
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
                  onPressed: () => _confirmDelete(booking['id'], l10n),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(booking['current_status'] ?? '', theme, l10n),
                Row(
                  children: [
                    Text(
                      'Rp ${NumberFormat('#,###', 'id_ID').format(double.tryParse(booking['estimated_total']?.toString() ?? '0') ?? 0)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.edit_note_rounded, color: theme.colorScheme.primary, size: 20),
                        onPressed: () => _updateStatus(booking['id'], booking['current_status'] ?? '', booking['delivery_type'] ?? 'Antar Sendiri', l10n),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (booking['notes'] != null && booking['notes'].toString().isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${l10n.notes} ${booking['notes']}',
                  style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
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
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.deletedSuccess)),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
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
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '62${cleanPhone.substring(1)}';
    }
    
    final url = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeFull(message)}");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.waError)),
        );
      }
    }
  }

  Widget _buildEmptyState(ThemeData theme, dynamic l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: theme.colorScheme.outline.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(l10n.noOrders, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
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
                  
                  // Case-insensitive matching with localized strings
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
                  DropdownMenuItem(value: l10n.received, child: Text(l10n.received)),
                  DropdownMenuItem(value: l10n.weighed, child: Text(l10n.weighed)),
                  DropdownMenuItem(value: l10n.washed, child: Text(l10n.washed)),
                  DropdownMenuItem(value: l10n.dried, child: Text(l10n.dried)),
                  DropdownMenuItem(value: l10n.ironed, child: Text(l10n.ironed)),
                  DropdownMenuItem(value: terminalStatus, child: Text(terminalStatus)),
                  DropdownMenuItem(value: l10n.done, child: Text(l10n.done)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      // Map back to internal status for API if needed, or use localized
                      // The API seems to expect the strings like 'Diterima' etc.
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
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: l10n.optionalNotes,
                  hintText: l10n.addNotesHint,
                ),
                onChanged: (value) => notes = value.isEmpty ? null : value,
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final response = await http.post(
                    Uri.parse('${ApiService.baseUrl}/staff/bookings/$bookingId/update-status'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'new_status': selectedStatus,
                      'updated_by': 'Staff',
                      'notes': notes,
                    }),
                  );
                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    _loadData();
                  } else {
                    throw Exception('Failed to update');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: Text(l10n.update),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountCard(String title, int count, Color color, IconData icon) {
    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0), // Reduced vertical padding
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content
          children: [
            Container(
              padding: const EdgeInsets.all(10), // Reduced from 12
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24, // Reduced from 28
              ),
            ),
            const SizedBox(height: 8), // Reduced from 12
            FittedBox( // Added to prevent text overflow
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24, // Reduced from 28
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4), // Reduced from 8
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}