import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:LaundryUp/generated/app_localizations.dart';
import '../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<dynamic> _services = [];
  int? _selectedServiceId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _deliveryType = 'Jemput';
  double _weight = 1.0;
  double _estimatedTotal = 0.0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final services = await ApiService.getServices();
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _calculateEstimate() {
    double basePrice = 0.0;
    double servicePrice = 0.0;
    double deliveryPrice = 0.0;

    if (_selectedServiceId != null) {
      final selectedService = _services.firstWhere(
        (service) => service['id'] == _selectedServiceId,
        orElse: () => null,
      );
      if (selectedService != null) {
        final name = selectedService['name'].toString().toLowerCase();
        if (name.contains('kering')) {
          servicePrice = 6000.0 * _weight;
        } else if (name.contains('setrika')) {
          servicePrice = 8000.0 * _weight;
        } else if (name.contains('express')) {
          servicePrice = 12000.0 * _weight;
        }
      }
    }

    if (_deliveryType == 'Jemput') {
      deliveryPrice = 5000.0;
    }

    setState(() {
      _estimatedTotal = basePrice + servicePrice + deliveryPrice;
    });
  }

  Future<void> _confirmBooking() async {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedServiceId == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        _weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.completeBookingData),
        ),
      );
      return;
    }

    try {
      final bookingDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final timeSlot =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      await ApiService.createBooking(
        serviceId: _selectedServiceId!,
        bookingDate: bookingDate,
        timeSlot: timeSlot,
        deliveryType: _deliveryType,
        estimatedTotal: _estimatedTotal,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.bookingSuccess)));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
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
              ElevatedButton(onPressed: _loadServices, child: Text(l10n.tryAgain)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingLaundry)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image/Icon Section
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
              ),
              child: Center(
                child: Icon(Icons.calendar_month_rounded, size: 64, color: theme.colorScheme.primary),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.selectService, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedServiceId,
                        isExpanded: true,
                        hint: Text(l10n.selectServiceHint),
                        items: _services.map((service) {
                          return DropdownMenuItem<int>(
                            value: service['id'],
                            child: Text(service['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedServiceId = value;
                            _calculateEstimate();
                          });
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Text(l10n.estimatedWeight, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: _weight.toString(),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: l10n.enterWeightHint,
                      suffixText: 'kg',
                      prefixIcon: const Icon(Icons.scale_rounded),
                    ),
                    onChanged: (value) {
                      final weight = double.tryParse(value) ?? 1.0;
                      setState(() {
                        _weight = weight;
                        _calculateEstimate();
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.pickDate, style: theme.textTheme.titleMedium),
                            const SizedBox(height: 12),
                            _buildPickerButton(
                              icon: Icons.calendar_today_rounded,
                              label: _selectedDate == null ? l10n.pickDate : DateFormat('dd MMM yyyy').format(_selectedDate!),
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 30)),
                                );
                                if (date != null) setState(() { _selectedDate = date; _calculateEstimate(); });
                              },
                              theme: theme,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.pickTime, style: theme.textTheme.titleMedium),
                            const SizedBox(height: 12),
                            _buildPickerButton(
                              icon: Icons.access_time_rounded,
                              label: _selectedTime == null ? l10n.pickTime : _selectedTime!.format(context),
                              onPressed: () => _showTimeSlotPicker(theme, l10n),
                              theme: theme,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  Text(l10n.deliveryType, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          label: l10n.pickup,
                          icon: Icons.delivery_dining_rounded,
                          selected: _deliveryType == 'Jemput',
                          onSelected: (val) => setState(() { _deliveryType = 'Jemput'; _calculateEstimate(); }),
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildChoiceChip(
                          label: l10n.selfDrop,
                          icon: Icons.storefront_rounded,
                          selected: _deliveryType == 'Antar Sendiri',
                          onSelected: (val) => setState(() { _deliveryType = 'Antar Sendiri'; _calculateEstimate(); }),
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.estimatedTotal, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                            Text(
                              'Rp ${_estimatedTotal.toStringAsFixed(0)}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _confirmBooking,
                          child: Text(l10n.confirmBooking),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required IconData icon,
    required bool selected,
    required Function(bool) onSelected,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () => onSelected(true),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : Colors.grey.withOpacity(0.2),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? theme.colorScheme.primary : Colors.grey),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? theme.colorScheme.primary : Colors.grey,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimeSlotPicker(ThemeData theme, dynamic l10n) {
    final List<TimeOfDay> slots = [
      const TimeOfDay(hour: 8, minute: 0),
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 10, minute: 0),
      const TimeOfDay(hour: 11, minute: 0),
      const TimeOfDay(hour: 12, minute: 0),
      const TimeOfDay(hour: 13, minute: 0),
      const TimeOfDay(hour: 14, minute: 0),
      const TimeOfDay(hour: 15, minute: 0),
      const TimeOfDay(hour: 16, minute: 0),
      const TimeOfDay(hour: 17, minute: 0),
      const TimeOfDay(hour: 18, minute: 0),
      const TimeOfDay(hour: 19, minute: 0),
      const TimeOfDay(hour: 20, minute: 0),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
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
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(l10n.selectOperationTime, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text("${l10n.operationHours}: 08:00 - 20:00", style: theme.textTheme.bodyMedium),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final isSelected = _selectedTime != null && 
                                     _selectedTime!.hour == slot.hour;
                    
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTime = slot;
                          _calculateEstimate();
                        });
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          slot.format(context),
                          style: TextStyle(
                            color: isSelected ? Colors.white : theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
