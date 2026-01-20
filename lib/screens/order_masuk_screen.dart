import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:LaundryUp/generated/app_localizations.dart';
import '../services/api_service.dart';

class OrderMasukScreen extends StatefulWidget {
  const OrderMasukScreen({super.key});

  @override
  State<OrderMasukScreen> createState() => _OrderMasukScreenState();
}

class _OrderMasukScreenState extends State<OrderMasukScreen> {
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
        setState(() {
          _bookings = jsonDecode(response.body);
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
        title: Text(l10n.orderIn),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _showAddOrderDialog(l10n),
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: ListView.builder(
          padding: const EdgeInsets.all(24.0),
          itemCount: _bookings.length,
          itemBuilder: (context, index) {
            final booking = _bookings[index];
            final status = booking['current_status'] ?? 'Unknown';
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: InkWell(
                onTap: () => _updateStatus(booking['id'], status, booking['delivery_type'] ?? 'Antar Sendiri', l10n),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking['customer_email'],
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
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
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
                            onPressed: () => _confirmDelete(booking['id'], l10n),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusBadge(status, theme, l10n),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rp ${NumberFormat('#,###', 'id_ID').format(double.tryParse(booking['estimated_total']?.toString() ?? '0') ?? 0)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 12, color: theme.colorScheme.outline),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(booking['booking_date']),
                                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (booking['notes'] != null && booking['notes'].toString().isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
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
                          padding: const EdgeInsets.only(top: 20),
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
                    _loadBookings();
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

  void _showAddOrderDialog(dynamic l10n) {
    String customerPhone = '';
    String customerName = '';
    int selectedServiceId = 1;
    double weight = 1.0;
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    String deliveryType = 'Jemput';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView(
              controller: scrollController,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.addNewOrder,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.manualOrderDesc,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                
                // Customer Profile Section
                _buildSectionHeader(l10n.customerInfo, Icons.person_outline),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: l10n.customerNameLabel,
                    hintText: l10n.customerNameHint,
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) => customerName = value,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: l10n.customerPhoneLabel,
                    hintText: l10n.customerPhoneHint,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => customerPhone = value,
                ),
                
                const SizedBox(height: 32),
                _buildSectionHeader(l10n.serviceDetails, Icons.local_laundry_service_outlined),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedServiceId,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(value: 1, child: Text(l10n.dryWash)),
                        DropdownMenuItem(value: 2, child: Text(l10n.washIron)),
                        DropdownMenuItem(value: 3, child: Text(l10n.express24)),
                      ],
                      onChanged: (value) => setModalState(() => selectedServiceId = value!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: l10n.estimatedWeight,
                    prefixIcon: const Icon(Icons.scale_outlined),
                    suffixText: 'kg',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => weight = double.tryParse(value) ?? 1.0,
                ),
                
                const SizedBox(height: 32),
                _buildSectionHeader(l10n.timeAndDelivery, Icons.calendar_today_outlined),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildPickerCard(
                        label: selectedDate == null ? l10n.pickDate : DateFormat('dd MMM yyyy').format(selectedDate!),
                        icon: Icons.date_range_outlined,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date != null) setModalState(() => selectedDate = date);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPickerCard(
                        label: selectedTime == null ? l10n.pickTime : selectedTime!.format(context),
                        icon: Icons.access_time_outlined,
                        onTap: () async {
                          final List<TimeOfDay> slots = [
                            for (int i = 8; i <= 20; i++) TimeOfDay(hour: i, minute: 0)
                          ];
                          
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            builder: (bottomSheetContext) => DraggableScrollableSheet(
                              initialChildSize: 0.5,
                              minChildSize: 0.3,
                              maxChildSize: 0.8,
                              expand: false,
                              builder: (context, scrollController) => SingleChildScrollView(
                                controller: scrollController,
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 40, height: 4,
                                        margin: const EdgeInsets.only(bottom: 20),
                                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                                      ),
                                    ),
                                    Text(l10n.selectOperationTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 16),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3, childAspectRatio: 2.2, crossAxisSpacing: 10, mainAxisSpacing: 10,
                                      ),
                                      itemCount: slots.length,
                                      itemBuilder: (context, index) {
                                        final slot = slots[index];
                                        return InkWell(
                                          onTap: () {
                                            setModalState(() => selectedTime = slot);
                                            Navigator.pop(bottomSheetContext);
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: selectedTime == slot ? Colors.blue : Colors.blue.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              slot.format(context),
                                              style: TextStyle(color: selectedTime == slot ? Colors.white : Colors.blue, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: deliveryType,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(value: 'Jemput', child: Text(l10n.pickup)),
                        DropdownMenuItem(value: 'Antar Sendiri', child: Text(l10n.selfDrop)),
                      ],
                      onChanged: (value) => setModalState(() => deliveryType = value!),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${l10n.estimatedTotal}:', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(double.tryParse((5000.0 + (selectedServiceId == 1 ? 6000.0 * weight : selectedServiceId == 2 ? 8000.0 * weight : 12000.0 * weight) + (deliveryType == 'Jemput' ? 5000.0 : 0.0)).toString()) ?? 0)}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (customerPhone.isEmpty || selectedDate == null || selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.completeData)));
                        return;
                      }

                      try {
                        final bookingDate = '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
                        final timeSlot = selectedTime!.format(context);

                        double basePrice = 5000.0;
                        double servicePrice = 0.0;
                        double deliveryPrice = deliveryType == 'Jemput' ? 5000.0 : 0.0;

                        if (selectedServiceId == 1) servicePrice = 6000.0 * weight;
                        else if (selectedServiceId == 2) servicePrice = 8000.0 * weight;
                        else if (selectedServiceId == 3) servicePrice = 12000.0 * weight;

                        final estimatedTotal = basePrice + servicePrice + deliveryPrice;

                        await ApiService.createBookingForCustomer(
                          customerPhone: customerPhone,
                          serviceId: selectedServiceId,
                          bookingDate: bookingDate,
                          timeSlot: timeSlot,
                          deliveryType: deliveryType,
                          estimatedTotal: estimatedTotal,
                        );

                        if (Navigator.canPop(context)) Navigator.pop(context);
                        _loadBookings();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(l10n.saveCreateOrder, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildPickerCard({required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}