import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/payment_method.dart';
import '../state/expense_providers.dart';
import '../state/dashboard_provider.dart';
import '../widgets/category_chip.dart';
import '../core/constants/app_constants.dart';

class AddExpenseBottomSheet extends ConsumerStatefulWidget {
  final ExpenseModel? initialExpense;

  const AddExpenseBottomSheet({
    super.key,
    this.initialExpense,
  });

  @override
  ConsumerState<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends ConsumerState<AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  DateTime _selectedDate = DateTime.now();
  int? _selectedCategoryId;
  int? _selectedPaymentMethodId;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialExpense != null ? widget.initialExpense!.amount.toString() : '',
    );
    _noteController = TextEditingController(
      text: widget.initialExpense?.note ?? '',
    );

    if (widget.initialExpense != null) {
      try {
        _selectedDate = DateTime.parse(widget.initialExpense!.expenseDate);
      } catch (_) {}
      _selectedCategoryId = widget.initialExpense!.categoryId;
      _selectedPaymentMethodId = widget.initialExpense!.paymentMethodId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      setState(() => _errorMessage = 'Please select a category');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Please enter a valid amount');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final expense = ExpenseModel(
      id: widget.initialExpense?.id,
      userId: 1,
      categoryId: _selectedCategoryId!,
      paymentMethodId: _selectedPaymentMethodId,
      amount: amount,
      expenseDate: formattedDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    try {
      final service = ref.read(expenseServiceProvider);
      if (widget.initialExpense == null) {
        await service.createExpense(expense);
      } else {
        await service.updateExpense(widget.initialExpense!.id!, expense);
      }

      // Refresh list & dashboard
      ref.invalidate(expensesListProvider);
      ref.invalidate(dashboardDataProvider);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _showAddCategoryDialog() {
    final nameCtrl = TextEditingController();
    String selectedIcon = 'tag';
    String selectedColor = '#4D96FF';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              try {
                final service = ref.read(expenseServiceProvider);
                final newCat = await service.createCategory(nameCtrl.text.trim(), selectedIcon, selectedColor);
                ref.invalidate(categoriesProvider);
                setState(() => _selectedCategoryId = newCat.id);
                if (mounted) Navigator.pop(ctx);
              } catch (e) {
                // handle
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final paymentMethodsAsync = ref.watch(paymentMethodsProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initialExpense == null ? 'Add Expense' : 'Edit Expense',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Theme.of(context).colorScheme.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: '${AppConstants.currencySymbol} ',
                  prefixStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  hintText: '0.00',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter an amount';
                  if (double.tryParse(val) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Category Selection
              Text('Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              categoriesAsync.when(
                data: (categories) {
                  return SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        if (i == categories.length) {
                          return ActionChip(
                            avatar: const Icon(Icons.add, size: 16),
                            label: const Text('Add New'),
                            onPressed: _showAddCategoryDialog,
                          );
                        }
                        final cat = categories[i];
                        final isSel = cat.id == _selectedCategoryId;
                        return CategoryChip(
                          name: cat.name,
                          iconKey: cat.iconKey,
                          colorHex: cat.colorHex,
                          isSelected: isSel,
                          onTap: () => setState(() => _selectedCategoryId = cat.id),
                        );
                      },
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => Text('Failed to load categories: $err'),
              ),
              const SizedBox(height: 20),
              // Date Picker & Payment Method Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 1)),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).dividerColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18),
                                const SizedBox(width: 8),
                                Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Method', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        paymentMethodsAsync.when(
                          data: (methods) {
                            if (_selectedPaymentMethodId == null && methods.isNotEmpty) {
                              _selectedPaymentMethodId = methods.first.id;
                            }
                            return DropdownButtonFormField<int>(
                              value: _selectedPaymentMethodId,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: methods.map((m) {
                                return DropdownMenuItem<int>(
                                  value: m.id,
                                  child: Text(m.name, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedPaymentMethodId = val),
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (err, _) => const Text('Error'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Note input
              Text('Note (Optional)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLength: 255,
                decoration: InputDecoration(
                  hintText: 'e.g. Lunch with friends',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.initialExpense == null ? 'Save Expense' : 'Update Expense',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
