import'../models/expense_model.dart';
import '../services/database_helper.dart';

class ExpenseRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insertExpense(ExpenseModel expense) async {
    return await _databaseHelper.insertExpense(expense);
  }

  Future<List<ExpenseModel>> getAllExpenses() async {
    return await _databaseHelper.getAllExpenses();
  }

  Future<int> deleteExpense(int id) async {
    return await _databaseHelper.deleteExpense(id);
  }
}