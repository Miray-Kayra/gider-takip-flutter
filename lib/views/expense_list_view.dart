import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../models/expense_model.dart';

class ExpenseListView extends StatelessWidget {
  const ExpenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harcama Takip'),
      ),
      body: Consumer<ExpenseViewModel>(
        builder: (context, viewModel, child) {
          // 1. Durum: Yükleniyor
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Durum: Liste Boş
          if (viewModel.expenses.isEmpty) {
            return const Center(
              child: Text(
                'Henüz harcama eklenmedi.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // 3. Durum: Liste Dolu (Toplam Harcama Kartı + Harcama Listesi)
          return Column(
            children: [
              // --- YENİ EKLENEN: TOPLAM HARCAMA KARTI ---
              Card(
                margin: const EdgeInsets.all(12),
                color: Theme.of(context).primaryColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam Harcama:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${viewModel.totalExpense.toStringAsFixed(2)} ₺',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- HARCAMA LİSTESİ ---
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = viewModel.expenses[index];
                    return Dismissible(
                      key: Key(expense.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        if (expense.id != null) {
                          viewModel.deleteExpense(expense.id!);
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              expense.category.isNotEmpty
                                  ? expense.category[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(expense.title),
                          subtitle: Text(
                            DateFormat('dd.MM.yyyy').format(expense.date),
                          ),
                          trailing: Text(
                            '${expense.amount.toStringAsFixed(2)} ₺',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext mainContext) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Market';
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: mainContext,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext dialogContext, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Yeni Harcama Ekle',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),

                  // 1. Başlık Girişi
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Harcama Adı',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Tutar Girişi
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Tutar (₺)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Kategori Seçimi
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Market', 'Ulaşım', 'Eğlence', 'Fatura', 'Diğer']
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // 4. Tarih Seçimi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tarih: ${DateFormat('dd.MM.yyyy').format(selectedDate)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Tarih Seç'),
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: sheetContext,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 5. Kaydet Butonu
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      final title = titleController.text.trim();
                      final amountText = amountController.text.trim();
                      final amount = double.tryParse(amountText);

                      if (title.isEmpty || amount == null || amount <= 0) {
                        ScaffoldMessenger.of(mainContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Lütfen geçerli bir başlık ve tutar girin!',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final newExpense = ExpenseModel(
                        title: title,
                        amount: amount,
                        category: selectedCategory,
                        date: selectedDate,
                      );

                      Provider.of<ExpenseViewModel>(
                        mainContext,
                        listen: false,
                      ).addExpense(newExpense);

                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Kaydet', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}