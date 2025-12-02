import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_detail_model.dart';
import 'package:vhs_mobile_user/data/models/report/report_models.dart';
import 'package:vhs_mobile_user/ui/report/report_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final HistoryBookingDetail bookingDetail;

  const ReportScreen({super.key, required this.bookingDetail});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  ReportTypeEnum? _selectedType; // Null initially để hiển thị placeholder
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  
  // Error messages
  String? _reportTypeError;
  String? _titleError;
  String? _descriptionError;
  String? _bankNameError;
  String? _accountHolderError;
  String? _bankAccountError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tối đa 5 hình ảnh")),
      );
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final remaining = 5 - _selectedImages.length;
        final toAdd = images.take(remaining).map((x) => File(x.path)).toList();
        setState(() {
          _selectedImages.addAll(toAdd);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi chọn ảnh: $e")),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _clearErrors() {
    setState(() {
      _reportTypeError = null;
      _titleError = null;
      _descriptionError = null;
      _bankNameError = null;
      _accountHolderError = null;
      _bankAccountError = null;
    });
  }

  Future<void> _submitReport() async {
    _clearErrors();
    bool hasError = false;

    // Validation
    if (_selectedType == null) {
      setState(() {
        _reportTypeError = "Vui lòng chọn loại báo cáo";
      });
      hasError = true;
    }

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _titleError = "Vui lòng nhập tiêu đề báo cáo";
      });
      hasError = true;
    } else if (title.length > 100) {
      setState(() {
        _titleError = "Tiêu đề không được vượt quá 100 ký tự";
      });
      hasError = true;
    }

    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      setState(() {
        _descriptionError = "Vui lòng nhập mô tả chi tiết";
      });
      hasError = true;
    } else if (description.length > 1000) {
      setState(() {
        _descriptionError = "Mô tả không được vượt quá 1000 ký tự";
      });
      hasError = true;
    }

    // Validate thông tin ngân hàng nếu là yêu cầu hoàn tiền
    if (_selectedType == ReportTypeEnum.refundRequest) {
      final bankName = _bankNameController.text.trim();
      final accountHolder = _accountHolderController.text.trim();
      final bankAccount = _bankAccountController.text.trim();

      if (bankName.isEmpty) {
        setState(() {
          _bankNameError = "Vui lòng nhập tên ngân hàng";
        });
        hasError = true;
      }

      if (accountHolder.isEmpty) {
        setState(() {
          _accountHolderError = "Vui lòng nhập tên chủ tài khoản";
        });
        hasError = true;
      }

      if (bankAccount.isEmpty) {
        setState(() {
          _bankAccountError = "Vui lòng nhập số tài khoản";
        });
        hasError = true;
      } else if (!RegExp(r'^\d{6,20}$').hasMatch(bankAccount)) {
        setState(() {
          _bankAccountError = "Số tài khoản phải là số và có từ 6 đến 20 ký tự";
        });
        hasError = true;
      }
    }

    if (hasError) {
      // Scroll to first error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final imagePaths = _selectedImages.map((f) => f.path).toList();
      
      // Nếu là yêu cầu hoàn tiền, thêm thông tin ngân hàng vào description
      String? finalDescription = description.isNotEmpty ? description : null;
      if (_selectedType == ReportTypeEnum.refundRequest) {
        final bankName = _bankNameController.text.trim();
        final accountHolder = _accountHolderController.text.trim();
        final bankAccount = _bankAccountController.text.trim();
        
        final bankInfo = "\n\n--- THÔNG TIN NGÂN HÀNG ĐỂ HOÀN TIỀN ---\n" +
                        "Tên ngân hàng: $bankName\n" +
                        "Tên chủ tài khoản: $accountHolder\n" +
                        "Số tài khoản: $bankAccount";
        
        finalDescription = finalDescription != null 
            ? finalDescription + bankInfo 
            : bankInfo.trim();
      }
      
      final dto = CreateReportDTO(
        bookingId: widget.bookingDetail.bookingId,
        reportType: _selectedType!, // Gửi đúng loại báo cáo đã chọn
        title: title,
        description: finalDescription,
        providerId: widget.bookingDetail.provider.providerId,
        imagePaths: imagePaths.isNotEmpty ? imagePaths : null,
        bankName: _selectedType == ReportTypeEnum.refundRequest ? _bankNameController.text.trim() : null,
        accountHolderName: _selectedType == ReportTypeEnum.refundRequest ? _accountHolderController.text.trim() : null,
        bankAccountNumber: _selectedType == ReportTypeEnum.refundRequest ? _bankAccountController.text.trim() : null,
      );

      final result = await ref.read(reportViewModelProvider.notifier).submitReport(dto);

      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Báo cáo đã được gửi thành công!"),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh history detail và quay lại
          context.pop(true); // Return true để indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Gửi báo cáo thất bại. Vui lòng thử lại."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Nếu lỗi do backend không hỗ trợ RefundRequest, thử lại với Other
      if (mounted && _selectedType == ReportTypeEnum.refundRequest && e.toString().contains('400')) {
        try {
          // Lấy lại các giá trị cần thiết
          final retryDescription = description.isNotEmpty ? description : null;
          String? retryFinalDescription = retryDescription;
          if (_selectedType == ReportTypeEnum.refundRequest) {
            final bankName = _bankNameController.text.trim();
            final accountHolder = _accountHolderController.text.trim();
            final bankAccount = _bankAccountController.text.trim();
            
            final bankInfo = "\n\n--- THÔNG TIN NGÂN HÀNG ĐỂ HOÀN TIỀN ---\n" +
                            "Tên ngân hàng: $bankName\n" +
                            "Tên chủ tài khoản: $accountHolder\n" +
                            "Số tài khoản: $bankAccount";
            
            retryFinalDescription = retryFinalDescription != null 
                ? retryFinalDescription + bankInfo 
                : bankInfo.trim();
          }
          
          final retryImagePaths = _selectedImages.map((f) => f.path).toList();
          
          // Thử lại với Other nhưng vẫn giữ thông tin ngân hàng
          final retryDto = CreateReportDTO(
            bookingId: widget.bookingDetail.bookingId,
            reportType: ReportTypeEnum.other,
            title: title,
            description: retryFinalDescription,
            providerId: widget.bookingDetail.provider.providerId,
            imagePaths: retryImagePaths.isNotEmpty ? retryImagePaths : null,
            bankName: _bankNameController.text.trim(),
            accountHolderName: _accountHolderController.text.trim(),
            bankAccountNumber: _bankAccountController.text.trim(),
          );
          
          final retryResult = await ref.read(reportViewModelProvider.notifier).submitReport(retryDto);
          
          if (mounted) {
            if (retryResult != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Báo cáo đã được gửi thành công!"),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop(true);
              return;
            }
          }
        } catch (retryError) {
          // Nếu vẫn lỗi, hiển thị lỗi gốc
        }
      }
      
      if (mounted) {
        String errorMessage = "Lỗi: ${e.toString()}";
        if (e.toString().contains("Booking đã được báo cáo")) {
          errorMessage = "Đơn hàng này đã được báo cáo trước đó. Mỗi đơn hàng chỉ được báo cáo 1 lần.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
            ),
          ),
        ),
        title: const Text(
          "Báo cáo",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: ThemeHelper.getScaffoldBackgroundColor(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loại báo cáo - Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ThemeHelper.getLightBlueBackgroundColor(context),
                    ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.category_rounded,
                      color: ThemeHelper.getPrimaryDarkColor(context),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Loại báo cáo *",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: ThemeHelper.getTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ReportTypeEnum>(
              value: _selectedType,
              decoration: InputDecoration(
                hintText: "Chọn loại báo cáo",
                hintStyle: TextStyle(
                  color: ThemeHelper.getTertiaryTextColor(context),
                ),
                prefixIcon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: ThemeHelper.getPrimaryColor(context),
                ),
                filled: true,
                fillColor: ThemeHelper.getInputBackgroundColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeHelper.getBorderColor(context),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeHelper.getBorderColor(context),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeHelper.getPrimaryColor(context),
                    width: 2,
                  ),
                ),
                errorText: _reportTypeError,
                errorBorder: _reportTypeError != null
                    ? OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
              ),
              items: ReportTypeEnum.values.map((type) {
                return DropdownMenuItem<ReportTypeEnum>(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                  _reportTypeError = null;
                });
              },
            ),
            const SizedBox(height: 24),

            // Tiêu đề
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ThemeHelper.getLightBlueBackgroundColor(context),
                    ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.title_rounded,
                      color: ThemeHelper.getPrimaryDarkColor(context),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Tiêu đề *",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: ThemeHelper.getTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              style: TextStyle(
                color: ThemeHelper.getTextColor(context),
              ),
              decoration: InputDecoration(
                hintText: "Nhập tiêu đề báo cáo",
                hintStyle: TextStyle(
                  color: ThemeHelper.getTertiaryTextColor(context),
                ),
                prefixIcon: Icon(
                  Icons.edit_rounded,
                  color: ThemeHelper.getPrimaryColor(context),
                ),
                filled: true,
                fillColor: ThemeHelper.getInputBackgroundColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeHelper.getBorderColor(context),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeHelper.getBorderColor(context),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeHelper.getPrimaryColor(context),
                    width: 2,
                  ),
                ),
                errorText: _titleError,
                errorBorder: _titleError != null
                    ? OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
              ),
              maxLength: 100,
              onChanged: (_) {
                if (_titleError != null) {
                  setState(() {
                    _titleError = null;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Mô tả
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ThemeHelper.getLightBlueBackgroundColor(context),
                    ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      color: ThemeHelper.getPrimaryDarkColor(context),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Mô tả chi tiết *",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: ThemeHelper.getTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              style: TextStyle(
                color: ThemeHelper.getTextColor(context),
              ),
              decoration: InputDecoration(
                hintText: "Nhập mô tả chi tiết về vấn đề",
                hintStyle: TextStyle(
                  color: ThemeHelper.getTertiaryTextColor(context),
                ),
                prefixIcon: Icon(
                  Icons.notes_rounded,
                  color: ThemeHelper.getPrimaryColor(context),
                ),
                filled: true,
                fillColor: ThemeHelper.getInputBackgroundColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeHelper.getBorderColor(context),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeHelper.getBorderColor(context),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeHelper.getPrimaryColor(context),
                    width: 2,
                  ),
                ),
                errorText: _descriptionError,
                errorBorder: _descriptionError != null
                    ? OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
              ),
              maxLines: 5,
              maxLength: 1000,
              onChanged: (_) {
                if (_descriptionError != null) {
                  setState(() {
                    _descriptionError = null;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Thông tin ngân hàng - chỉ hiển thị khi chọn "Yêu cầu hoàn tiền"
            if (_selectedType == ReportTypeEnum.refundRequest) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeHelper.getLightBlueBackgroundColor(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.account_balance_rounded,
                            color: ThemeHelper.getPrimaryDarkColor(context),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Thông tin ngân hàng để hoàn tiền",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                            color: ThemeHelper.getTextColor(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Điền đầy đủ để nhận hoàn tiền",
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeHelper.getSecondaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tên ngân hàng
                    TextField(
                      controller: _bankNameController,
                      style: TextStyle(
                        color: ThemeHelper.getTextColor(context),
                      ),
                      decoration: InputDecoration(
                        labelText: "Tên ngân hàng *",
                        labelStyle: TextStyle(
                          color: ThemeHelper.getSecondaryTextColor(context),
                        ),
                        hintText: "VD: Vietcombank, Techcombank, BIDV...",
                        hintStyle: TextStyle(
                          color: ThemeHelper.getTertiaryTextColor(context),
                        ),
                        prefixIcon: Icon(
                          Icons.account_balance_rounded,
                          color: ThemeHelper.getPrimaryColor(context),
                        ),
                        filled: true,
                        fillColor: ThemeHelper.getInputBackgroundColor(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ThemeHelper.getBorderColor(context),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ThemeHelper.getBorderColor(context),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ThemeHelper.getPrimaryColor(context),
                            width: 2,
                          ),
                        ),
                        errorText: _bankNameError,
                        errorBorder: _bankNameError != null
                            ? OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              )
                            : null,
                      ),
                      onChanged: (_) {
                        if (_bankNameError != null) {
                          setState(() {
                            _bankNameError = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Tên chủ tài khoản
                    TextField(
                      controller: _accountHolderController,
                      style: TextStyle(
                        color: ThemeHelper.getTextColor(context),
                      ),
                      decoration: InputDecoration(
                        labelText: "Tên chủ tài khoản *",
                        labelStyle: TextStyle(
                          color: ThemeHelper.getSecondaryTextColor(context),
                        ),
                        hintText: "VD: NGUYEN VAN A",
                        hintStyle: TextStyle(
                          color: ThemeHelper.getTertiaryTextColor(context),
                        ),
                        prefixIcon: Icon(
                          Icons.person_rounded,
                          color: ThemeHelper.getPrimaryColor(context),
                        ),
                        filled: true,
                        fillColor: ThemeHelper.getInputBackgroundColor(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ThemeHelper.getBorderColor(context),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ThemeHelper.getBorderColor(context),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ThemeHelper.getPrimaryColor(context),
                            width: 2,
                          ),
                        ),
                        errorText: _accountHolderError,
                        errorBorder: _accountHolderError != null
                            ? OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              )
                            : null,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (_) {
                        if (_accountHolderError != null) {
                          setState(() {
                            _accountHolderError = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Số tài khoản
                    TextField(
                      controller: _bankAccountController,
                      style: TextStyle(
                        color: ThemeHelper.getTextColor(context),
                      ),
                      decoration: InputDecoration(
                        labelText: "Số tài khoản *",
                        labelStyle: TextStyle(
                          color: ThemeHelper.getSecondaryTextColor(context),
                        ),
                        hintText: "Chỉ nhập số, từ 6–20 ký tự",
                        hintStyle: TextStyle(
                          color: ThemeHelper.getTertiaryTextColor(context),
                        ),
                        prefixIcon: Icon(
                          Icons.credit_card_rounded,
                          color: ThemeHelper.getPrimaryColor(context),
                        ),
                        filled: true,
                        fillColor: ThemeHelper.getInputBackgroundColor(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ThemeHelper.getBorderColor(context),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ThemeHelper.getBorderColor(context),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ThemeHelper.getPrimaryColor(context),
                            width: 2,
                          ),
                        ),
                        errorText: _bankAccountError,
                        errorBorder: _bankAccountError != null
                            ? OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        if (_bankAccountError != null) {
                          setState(() {
                            _bankAccountError = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ThemeHelper.isDarkMode(context)
                            ? Colors.green.shade900.withOpacity(0.3)
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.shade400,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shield_rounded,
                            color: Colors.green.shade400,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Thông tin ngân hàng được bảo mật và chỉ dùng để hoàn tiền.",
                              style: TextStyle(
                                fontSize: 12,
                                color: ThemeHelper.getSecondaryTextColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Hình ảnh
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ThemeHelper.getLightBlueBackgroundColor(context),
                    ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.image_rounded,
                      color: ThemeHelper.getPrimaryDarkColor(context),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Hình ảnh đính kèm (tối đa 5)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: ThemeHelper.getTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ThemeHelper.getBorderColor(context),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeHelper.getShadowColor(context),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImages[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: () => _removeImage(index),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 28,
                                  minHeight: 28,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _selectedImages.length >= 5 ? null : _pickImages,
              icon: Icon(
                Icons.add_photo_alternate_rounded,
                color: _selectedImages.length >= 5
                    ? ThemeHelper.getSecondaryIconColor(context)
                    : ThemeHelper.getPrimaryColor(context),
              ),
              label: Text(
                "Thêm hình ảnh (${_selectedImages.length}/5)",
                style: TextStyle(
                  color: _selectedImages.length >= 5
                      ? ThemeHelper.getSecondaryTextColor(context)
                      : ThemeHelper.getPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _selectedImages.length >= 5
                      ? ThemeHelper.getBorderColor(context)
                      : ThemeHelper.getPrimaryColor(context),
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Nút gửi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitReport,
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  _isSubmitting ? "Đang gửi..." : "Gửi báo cáo",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

