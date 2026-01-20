import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:LaundryUp/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class StatusScreen extends StatefulWidget {
  final int?
  bookingId; 

  const StatusScreen({super.key, this.bookingId});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  Map<String, dynamic>? _statusData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      if (widget.bookingId == null) {
        throw Exception('ID booking tidak ditemukan. Silakan buat booking terlebih dahulu.');
      }

      var data = await ApiService.getBookingStatus(widget.bookingId!);
      
      // Fallback: If price is missing or 0, find it in the booking list
      final price = double.tryParse((data['estimated_total'] ?? data['booking']?['estimated_total'] ?? '0').toString()) ?? 0;
      if (price == 0) {
        try {
          final bookings = await ApiService.getUserBookings();
          final currentBooking = bookings.firstWhere((b) => b['id'] == widget.bookingId, orElse: () => null);
          if (currentBooking != null) {
            // Merge price and other details into our status data
            data['estimated_total'] = currentBooking['estimated_total'];
            data['service_name'] = currentBooking['service_name'];
          }
        } catch (e) {
          // Ignore error in fallback
        }
      }

      setState(() {
        _statusData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data status: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString; // Fallback
    }
  }

  Widget _buildStepper(String currentStatus, List<dynamic> history, AppLocalizations l10n) {
    const steps = [
      'Diterima',
      'Ditimbang',
      'Dicuci',
      'Dikeringkan',
      'Disetrika',
      'Siap Diambil',
    ];

    final currentStepIndex = steps.indexOf(currentStatus);
    final completedSteps = currentStepIndex >= 0 ? currentStepIndex + 1 : 0;

    return Stepper(
      currentStep: currentStepIndex,
      steps: steps.map((step) {
        final isCompleted = steps.indexOf(step) < completedSteps;
        final isActive = steps.indexOf(step) == currentStepIndex;
        final stepHistory = history.where((h) => h['status'] == step).toList();
        final completionDate = stepHistory.isNotEmpty ? stepHistory.last['updated_at'] : null;
        final formattedDate = completionDate != null ? _formatDateTime(completionDate) : null;
        return Step(
          title: Text(step),
          content: isCompleted
              ? Text(formattedDate != null ? '${l10n.completedOn}: $formattedDate' : l10n.completed)
              : Text(l10n.inProcess),
          isActive: isActive,
          state: isCompleted
              ? StepState.complete
              : isActive
                  ? StepState.editing
                  : StepState.indexed,
        );
      }).toList(),
      controlsBuilder: (context, details) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.statusLaundry)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.statusLaundry)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(_errorMessage!, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _loadStatus, child: Text(l10n.tryAgain)),
              ],
            ),
          ),
        ),
      );
    }

    final currentStatus = _statusData!['current_status'];
    final history = _statusData!['history'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statusLaundry),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.alert),
                  content: Text(l10n.confirmDeleteBooking),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete)),
                  ],
                ),
              );
              if (confirm == true) {
                try {
                  await ApiService.deleteBooking(widget.bookingId!);
                  Navigator.pop(context, true); 
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStatus,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Order Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${l10n.orderNumber}${widget.bookingId}", style: theme.textTheme.titleMedium),
                            Text(currentStatus, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.totalFees, style: theme.textTheme.bodyLarge),
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(
                          double.tryParse(
                            (_statusData!['estimated_total'] ?? 
                             _statusData!['booking']?['estimated_total'] ?? 
                             _statusData!['data']?['estimated_total'] ??
                             _statusData!['total_price'] ??
                             _statusData!['total'] ??
                             _statusData!['booking']?['total_price'] ??
                             '0').toString()
                          ) ?? 0
                        )}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        const phone = '6281282480007';
                        final totalPrice = NumberFormat('#,###', 'id_ID').format(
                          double.tryParse(
                            (_statusData!['estimated_total'] ?? 
                             _statusData!['booking']?['estimated_total'] ?? 
                             _statusData!['data']?['estimated_total'] ??
                             _statusData!['total_price'] ??
                             _statusData!['total'] ??
                             _statusData!['booking']?['total_price'] ??
                             '0').toString()
                          ) ?? 0
                        );
                        final serviceName = _statusData!['service_name'] ?? 
                                           _statusData!['booking']?['service_name'] ?? 
                                           _statusData!['data']?['service_name'] ??
                                           l10n.laundry;
                        final message = l10n.waMeMessageStatus(
                            widget.bookingId.toString(),
                            serviceName,
                            totalPrice,
                        );
                        
                        final url = Uri.parse("https://wa.me/$phone?text=${Uri.encodeFull(message)}");
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.waError)),
                          );
                        }
                      },
                      icon: const Icon(Icons.account_balance_wallet_rounded),
                      label: Text(l10n.payNowWa),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(l10n.laundryProgress, style: theme.textTheme.titleLarge),
            const SizedBox(height: 24),
            
            // Custom Timeline
            ..._buildTimeline(currentStatus, history, theme, l10n),
            
            const SizedBox(height: 32),
            Text(l10n.fullHistory, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            ...history.map((item) => _buildHistoryItem(item, theme, l10n)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimeline(String currentStatus, List<dynamic> history, ThemeData theme, dynamic l10n) {
    final deliveryType = _statusData?['delivery_type'] ?? 'Antar Sendiri';
    final terminalStatus = deliveryType == 'Jemput' ? l10n.readyToDeliver : l10n.readyToPickup;
    final normalizedStatus = (currentStatus ?? '').trim();
    
    final steps = [
      'Diterima',
      'Ditimbang',
      'Dicuci',
      'Dikeringkan',
      'Disetrika',
      terminalStatus,
      l10n.done,
    ];

    int currentStepIndex = steps.indexWhere((s) => s.toLowerCase() == normalizedStatus.toLowerCase());
    
    // Fallback khusus untuk terminal status (Siap Diambil/Dikirim)
    if (currentStepIndex == -1) {
      if (normalizedStatus.toLowerCase().contains('siap')) {
        currentStepIndex = 5; // index terminalStatus
      } else if (normalizedStatus.toLowerCase() == 'selesai') {
        currentStepIndex = 6;
      }
    }

    return List.generate(steps.length, (index) {
      final step = steps[index];
      final isCompleted = index < currentStepIndex || normalizedStatus.toLowerCase() == 'selesai';
      final isActive = index == currentStepIndex && normalizedStatus.toLowerCase() != 'selesai';
      final isLast = index == steps.length - 1;
      
      final stepHistory = history.where((h) => h['status'].toString().trim().toLowerCase() == step.toLowerCase()).toList();
      final completionDate = stepHistory.isNotEmpty ? stepHistory.last['updated_at'] : null;

      return IntrinsicHeight(
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (isCompleted || isActive) ? theme.colorScheme.primary : Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    (isCompleted || (step == l10n.done && currentStatus == 'Selesai')) ? Icons.check : isActive ? Icons.autorenew_rounded : Icons.radio_button_unchecked,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? theme.colorScheme.primary : Colors.grey.withOpacity(0.2),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isActive ? theme.colorScheme.primary : isCompleted ? theme.colorScheme.onSurface : Colors.grey,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    if (completionDate != null)
                      Text(
                        _formatDateTime(completionDate),
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHistoryItem(dynamic item, ThemeData theme, dynamic l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item['status'], style: theme.textTheme.titleSmall),
              Text(_formatDateTime(item['updated_at']), style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.updatedBy}: ${item['updated_by']}',
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          if (item['notes'] != null && item['notes'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['notes'],
                  style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
