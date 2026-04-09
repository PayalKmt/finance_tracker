import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../models/transaction.dart';
import '../../utils/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;
  final TransactionType? initialType;

  const AddTransactionScreen({super.key, this.transaction, this.initialType});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late TransactionType _type;
  late TransactionCategory _category;
  late DateTime _date;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _type = t?.type ?? widget.initialType ?? TransactionType.expense;
    _category = t?.category ?? TransactionCategory.food;
    _date = t?.date ?? DateTime.now();
    if (t != null) {
      _titleController.text = t.title;
      _amountController.text = t.amount.toStringAsFixed(0);
      _notesController.text = t.notes ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final transaction = Transaction(
      id: widget.transaction?.id ?? const Uuid().v4(),
      amount: double.parse(_amountController.text),
      type: _type,
      category: _category,
      date: _date,
      title: _titleController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (widget.transaction == null) {
      context.read<TransactionBloc>().add(AddTransaction(transaction));
    } else {
      context.read<TransactionBloc>().add(UpdateTransaction(transaction));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Type Toggle
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : const Color(0xFFF0EEFF),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _TypeButton(
                    label: '💸 Expense',
                    selected: _type == TransactionType.expense,
                    color: AppTheme.accentRed,
                    onTap: () =>
                        setState(() => _type = TransactionType.expense),
                  ),
                  _TypeButton(
                    label: '💵 Income',
                    selected: _type == TransactionType.income,
                    color: AppTheme.accentGreen,
                    onTap: () => setState(() => _type = TransactionType.income),
                  ),
                ],
              ),
            ),
            const Gap(20),

            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                hintText: '0',
                prefixText: '₹ ',
                prefixStyle:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                hintStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.withValues(alpha: .4),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter amount';
                if (double.tryParse(v) == null) return 'Invalid amount';
                if (double.parse(v) <= 0) return 'Must be greater than 0';
                return null;
              },
            ),
            const Gap(16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Transaction title',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Enter a title' : null,
            ),
            const Gap(16),

            // Category
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const Gap(10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TransactionCategory.values.map((cat) {
                final selected = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primaryLight
                          : isDark
                              ? AppTheme.cardDark
                              : const Color(0xFFF0EEFF),
                      borderRadius: BorderRadius.circular(12),
                      border: selected
                          ? Border.all(color: AppTheme.primaryLight, width: 2)
                          : null,
                    ),
                    child: Text(
                      '${cat.emoji} ${cat.label}',
                      style: TextStyle(
                        color: selected ? Colors.white : null,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Gap(16),

            // Date
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : const Color(0xFFF0EEFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppTheme.primaryLight),
                    const Gap(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: .5),
                          ),
                        ),
                        Text(
                          '${_date.day}/${_date.month}/${_date.year}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
            const Gap(16),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes_rounded),
                alignLabelWithHint: true,
              ),
            ),
            const Gap(32),

            // Save Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditing ? 'Save Changes' : 'Add Transaction',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : null,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
