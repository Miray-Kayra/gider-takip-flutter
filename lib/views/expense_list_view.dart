import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/expense_viewmodel.dart';

class ExpenseListView extends StatelessWidget {
  const ExpenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harcama Takip'),
        centerTitle: true,
      ),
      body: Consumer<ExpenseViewModel>(
        builder: (context, viewModel, child) {
          // 1. Durum: Veriler yükleniyor
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 2. Durum: Liste boş
          if (viewModel.expenses.isEmpty) {
            return const Center(
              child: Text(
                'Henüz harcama eklenmedi.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // 3. Durum: Harcamalar listeleniyor
          return ListView.builder(
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
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        expense.category.isNotEmpty
                            ? expense.category[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(
                      expense.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateFormat('dd.MM.yyyy').format(expense.date),
                    ),
                    trailing: Text(
                      '${expense.amount.toStringAsFixed(2)} ₺',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddExpenseDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Yeni Harcama Ekle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }
}