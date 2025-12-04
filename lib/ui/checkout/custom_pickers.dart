import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/provider/provider_availability_model.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';

// Custom Date Picker với lịch đẹp
class CustomDatePicker extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final Future<bool> Function(DateTime) onCheckAvailability;

  const CustomDatePicker({
    super.key,
    required this.initialDate,
    required this.onCheckAvailability,
  });

  @override
  ConsumerState<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends ConsumerState<CustomDatePicker> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  final Map<DateTime, bool> _availabilityCache = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final startDate = firstDay.subtract(Duration(days: firstDay.weekday % 7));
    
    final days = <DateTime>[];
    for (int i = 0; i < 42; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  Future<bool> _checkAvailability(DateTime date) async {
    final key = DateTime(date.year, date.month, date.day);
    if (_availabilityCache.containsKey(key)) {
      return _availabilityCache[key]!;
    }
    try {
      final available = await widget.onCheckAvailability(date);
      _availabilityCache[key] = available;
      return available;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider); // Rebuild when language changes
    final days = _getDaysInMonth(_currentMonth);
    final today = DateTime.now();
    final lastDate = today.add(const Duration(days: 60));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: ThemeHelper.getDialogBackgroundColor(context),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.getShadowColor(context),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header với gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade600,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                        });
                      },
                    ),
                  ),
                  Text(
                    '${_currentMonth.month}/${_currentMonth.year}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                      onPressed: () {
                        final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                        if (nextMonth.isBefore(lastDate) || nextMonth.isAtSameMomentAs(lastDate)) {
                          setState(() {
                            _currentMonth = nextMonth;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  // Tên các ngày trong tuần
                  Row(
                    children: [
                      context.tr('weekday_sun'),
                      context.tr('weekday_mon'),
                      context.tr('weekday_tue'),
                      context.tr('weekday_wed'),
                      context.tr('weekday_thu'),
                      context.tr('weekday_fri'),
                      context.tr('weekday_sat'),
                    ]
                        .map((day) => Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ThemeHelper.getSecondaryTextColor(context),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  // Lịch
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                    ),
                    itemCount: 42,
                    itemBuilder: (context, index) {
                      final date = days[index];
                      final isCurrentMonth = date.month == _currentMonth.month;
                      final isToday = date.year == today.year &&
                          date.month == today.month &&
                          date.day == today.day;
                      final isSelected = date.year == _selectedDate.year &&
                          date.month == _selectedDate.month &&
                          date.day == _selectedDate.day;
                      final isPast = date.isBefore(today);
                      final isFuture = date.isAfter(lastDate);

                      return FutureBuilder<bool>(
                        future: isCurrentMonth && !isPast && !isFuture
                            ? _checkAvailability(date)
                            : Future.value(false),
                        builder: (context, snapshot) {
                          // Nếu đang loading hoặc chưa có kết quả, mặc định cho phép chọn (optimistic)
                          // Chỉ disable nếu chắc chắn không available (có kết quả và là false)
                          final isInValidRange = isCurrentMonth && !isPast && !isFuture;
                          final hasResult = snapshot.hasData;
                          final available = snapshot.data ?? true; // Mặc định true nếu chưa có kết quả
                          // Cho phép chọn nếu trong khoảng hợp lệ và (chưa có kết quả hoặc available)
                          final canSelect = isInValidRange && (!hasResult || available);

                          return GestureDetector(
                            onTap: canSelect
                                ? () {
                                    setState(() {
                                      _selectedDate = date;
                                    });
                                  }
                                : null,
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? ThemeHelper.getPrimaryColor(context)
                                    : isToday
                                        ? ThemeHelper.getLightBlueBackgroundColor(context)
                                        : Colors.transparent,
                                border: isToday && !isSelected
                                    ? Border.all(
                                        color: ThemeHelper.getPrimaryColor(context),
                                        width: 2,
                                      )
                                    : null,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : !isCurrentMonth
                                            ? ThemeHelper.getTertiaryTextColor(context)
                                            : !canSelect
                                                ? ThemeHelper.getSecondaryIconColor(context)
                                                : ThemeHelper.getTextColor(context),
                                    fontWeight: isSelected || isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: Text(
                          context.tr('cancel'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ThemeHelper.getSecondaryTextColor(context),
                          side: BorderSide(
                            color: ThemeHelper.getBorderColor(context),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context, _selectedDate),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          context.tr('select'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeHelper.getPrimaryColor(context),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Time Picker với kéo cuộn (scrollable columns)
class CustomTimePicker extends ConsumerStatefulWidget {
  final TimeOfDay initialTime;
  final DateTime date;
  final Future<ProviderAvailabilityModel> Function(DateTime date, TimeOfDay time) onCheckTime;

  const CustomTimePicker({
    super.key,
    required this.initialTime,
    required this.date,
    required this.onCheckTime,
  });

  @override
  ConsumerState<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends ConsumerState<CustomTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;
  final Map<String, bool> _availabilityCache = {};
  final FixedExtentScrollController _hourController = FixedExtentScrollController();
  final FixedExtentScrollController _minuteController = FixedExtentScrollController();

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    // Đảm bảo giờ trong khoảng 1-24
    if (_selectedHour == 0) _selectedHour = 24;
    // Scroll đến giờ và phút đã chọn sau khi build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hourController.hasClients) {
        final hourIndex = _selectedHour == 24 ? 23 : _selectedHour - 1;
        _hourController.animateToItem(
          hourIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      if (_minuteController.hasClients) {
        _minuteController.animateToItem(
          _selectedMinute,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  Future<bool> _checkAvailability(TimeOfDay time) async {
    final key = '${time.hour}:${time.minute}';
    if (_availabilityCache.containsKey(key)) {
      return _availabilityCache[key]!;
    }
    try {
      final dto = await widget.onCheckTime(widget.date, time);
      _availabilityCache[key] = dto.isAvailable;
      return dto.isAvailable;
    } catch (e) {
      return false;
    }
  }

  String _formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider); // Rebuild when language changes
    final hours = List.generate(24, (index) => index + 1); // 1-24
    final minutes = List.generate(60, (index) => index); // 0-59 phút

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: ThemeHelper.getDialogBackgroundColor(context),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.getShadowColor(context),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header với gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade600,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.access_time_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.tr('select_time'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  // Hiển thị giờ đã chọn
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ThemeHelper.getLightBlueBackgroundColor(context),
                          ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
              child: FutureBuilder<bool>(
                future: _checkAvailability(TimeOfDay(hour: _selectedHour, minute: _selectedMinute)),
                builder: (context, snapshot) {
                  final available = snapshot.data ?? false;
                  return Column(
                    children: [
                      Text(
                        _formatTime(_selectedHour, _selectedMinute),
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: ThemeHelper.getPrimaryColor(context),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: available
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: available
                                ? Colors.green.shade300
                                : Colors.orange.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              available
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              size: 16,
                              color: available
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              available ? context.tr('available') : context.tr('not_available'),
                              style: TextStyle(
                                color: available
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
                  const SizedBox(height: 24),
                  // Picker với kéo cuộn - 2 cột: giờ và phút
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: ThemeHelper.getLightBackgroundColor(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ThemeHelper.getBorderColor(context),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Cột giờ
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: _hourController,
                            itemExtent: 50,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _selectedHour = hours[index];
                                // Chuyển 24 thành 0 cho TimeOfDay
                                if (_selectedHour == 24) {
                                  _selectedHour = 0;
                                }
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                if (index < 0 || index >= hours.length) return null;
                                final hour = hours[index];
                                // Hiển thị 24 nhưng lưu là 0
                                final displayHour = hour == 24 ? 0 : hour;
                                final isSelected = displayHour == _selectedHour;
                                
                                return Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? ThemeHelper.getPrimaryColor(context)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        hour.toString().padLeft(2, '0'),
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Colors.white
                                              : ThemeHelper.getTextColor(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: hours.length,
                            ),
                          ),
                        ),
                        // Dấu hai chấm
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            ':',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: ThemeHelper.getTextColor(context),
                            ),
                          ),
                        ),
                        // Cột phút
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: _minuteController,
                            itemExtent: 50,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _selectedMinute = minutes[index];
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                if (index < 0 || index >= minutes.length) return null;
                                final minute = minutes[index];
                                final isSelected = minute == _selectedMinute;
                                
                                return Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? ThemeHelper.getPrimaryColor(context)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        minute.toString().padLeft(2, '0'),
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Colors.white
                                              : ThemeHelper.getTextColor(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: minutes.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: Text(
                          context.tr('cancel'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ThemeHelper.getSecondaryTextColor(context),
                          side: BorderSide(
                            color: ThemeHelper.getBorderColor(context),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final time = TimeOfDay(hour: _selectedHour, minute: _selectedMinute);
                          final available = await _checkAvailability(time);
                          if (available && context.mounted) {
                            Navigator.pop(context, time);
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.tr('time_slot_not_available')),
                                backgroundColor: Colors.orange.shade400, // Accent color, keep as is
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          context.tr('select'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeHelper.getPrimaryColor(context),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

