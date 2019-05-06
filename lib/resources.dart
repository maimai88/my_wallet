class string {
  // dashboard
  static const accounts = "Accounts";
  static const budgets = "Budgets";
  static const more = "More";

  // Sign Up/Sign in page
  static const sign_up = "Sign Up";
  static const display_name = "Display name";
  static const email_address = "Email Address";
  static const password = "Password";
  static const confirm_password = "Confirm password";
  static const register = "Register";
  static const not_the_first_time_here = "Not the first time here? ";
  static const sign_in = "Sign In";
  static const name_must_not_be_empty = "Name must not be empty";
  static const email_must_not_be_empty = "Email must not empty";
  static const invalid_email_format = "Invalid Email format";
  static const password_is_empty = "Password is empty";
  static const password_is_too_short = "Password is too short";
  static const start_managing_your_budget = "Start managing your budget";
  static const you_do_not_have_an_account = "You do not have an account? ";
  static const sign_up_here = "Sign up here";

  // About
  static const about = "About";
  static const app_version = "App Version";

  // Account
  static const create_account = "Create Account";
  static created_on(String date) => "Created on $date";
  static const save = "Save";
  static const create_new = "Create new";
  static const with_name = "with name";
  static const and_initial_amount = "and intial amount";
  static const select_account_type = "Select Account Type";
  static const account_name = "Account Name";
  static const enter_account_name = "Enter Account Name";
  static const error = "Error";
  static const ok = "OK";
  static const account = "Account";
  static const created = "Created";
  static const type = "Type";
  static const balance = "Balance";
  static const spent = "Spent";
  static const earn = "Earned";
  static const view_transactions = "View Transactions";
  static const make_a_transfer = "Make a transfer";
  static const total_liability = "Total Liability";
  static const make_a_payment = "Make a payment";
  static const pay_to = "Pay to";
  static const from = "From ";
  static const select_account = "Select Account";
  static const txt_in = "in";
  static const select_category = "Select category";
  static const on = "on";
  static const at = "at";
  static const discharge_liability = "Discharge liability";
  static const interest = "Interest";
  static const additional_payment = "Additional payment";
  static const no_account_available = "No account is available. Please create your account to continue.";
  static const add_account = "Add Account";
  static const no_category_available = "No Category available. Please create new Category to make payment.";
  static const create_category = "Create Category";
  static const add_budget = "Add Budget";
  static const failed_to_save_payment = "Failed to save payment";
  static const enter_amount = "Enter amount";
  static const done = "Done";
  static const edit = "Edit";
  static const delete_account = "Delete account";
  static const delete_account_warning = "Warning: All transactions related to this account will be remove, that includes payment transactions as well as money transfer in and out of this account. Are you sure to delete this account?";
  static const delete = "Delete";
  static const cancel = "Cancel";
  static const transfer = "Transfer";
  static const failed_to_query_account_info = "Failed to query account info.";
  static const error_while_making_transfer = "Error while making transfer. Please try again later";
  static const select_account_to_transfer_to = "Select Account to transfer to";
  static const transfer_to_account = "Transfer to account";
  static const amount = "amount";
  static const confirm = "Confirm";
  static const confirm_transfer_to_account = "Confirm transfer to account";
  static const after_transfer_is_done_balance_is = "After transfer is done, balance is";
  static const has = "has";
  static const and_account = "and Account";
  static const confirm_transfer_now = "Confirmed! Transfer Now!";

  // category
  static const category_name = "Category Name";
  static const enter_category_name = "Enter category name";

  // budget
  static const a_monthly_budget_for = "A monthly budget for";
  static const to = "to";
  static const forever = "Forever";
  static const at_max = "at max";
  static const saving = "Saving...";
  static const failed_to_save_budget = "Failed to save budget";
  static const try_again = "Try Again";
  static const expenses = "Expenses";
  static const income = "Income";
  static const categories = "Categories";
  static const add = "Add";

  // home
  static const add_transaction = "Add Transaction";
  static const transactions = "Transactions";
  static const syncing = "Syncing...";
  static const saving_this_month = "Saving this month";
  static const budget = "Budget";
  static const no_transaction_found = "No Transaction found";

  // splash
  static const auto_login_failed = "Error happens while starting the app. Please try again later";
  static const loading_data = "Loading data...";

  // transaction
  static const create_transaction = "Create Transaction";
  static const an = "An";
  static const of = "of";
  static const value_of = "valued of";
  static const was_made = "was made ";
  static const into = "into";
  static const by = "by ";
  static const unknown = "Unknown";
  static const txt_for = "for";
  static const enter_note = "Enter Note";
  static const add_your_note = "Add your Note";
  static const select_transaction_type = "Select Transaction Type";
  static const no_category_for_transaction_type = "No Category available for transaction type ";
  static const please_create_new_category_for_transaction_type = ".\n Please create new category for transaction type ";
  static const or_change_transaction_type = ", or change transaction type";
  static const total_expenses = "TOTAL EXPENSES";
  static transaction_not_found(id) => "Transaction with id $id not found";
  static const please_select_transaction_type = "Please Select Transaction Type";
  static const please_select_an_account = "Please select an Account";
  static const please_select_category = "Please select a Category";
  static const please_select_date = "Please select a Date";
  static const please_add_description = "Please add a description for this transaction";
  static const please_enter_transaction_amount = "Please enter your transaction amount";
  static const discharge_of_liability = "Discharge of Liability";

  // profile
  static const your_profile = "Your Profile";
  static const home = "Home";
  static const host = "Host";
  static const host_email = "Host Email";

  // home profile
  static const found_your_home = "Found your home";
  static const and_host_is = "and host is";
  static const go_home = "Go Home";
  static const setting_up_your_home_profile = "Set up your home profile";
  static const join_a_home = "Join a home";
  static const enter_your_host_email_address = "Enter host's email address";
  static const request_to_join_this_home = "Request to join this home";
  static const or = "OR";
  static const create_a_new_home = "Create a new home";
  static const enter_your_home_name = "Enter your home name";
  static const create_home = "Create home";
  static const failed_to_create_home = "Failed to create home";
  static create_home_error(String homeName, String reason) => "Your home $homeName is not created because $reason";
  static const failed_to_join_home = "Failed to join Home";
  static join_home_error(String homeName, String reason) => "Failed to join home of $homeName because $reason";
  static const failed_to_create_this_new_home = "Failed to create this new home";
  static host_has_no_home(host) => "This host $host does not have any home right now";
  static failed_to_join_home_with_host(host) => "Failed to join home with $host";


  // sign in
  static const first_time_here = "First time here? ";
  static const validate_account = "Validate account";
  static const validate_account_message = "Please click on the link sent to your email to validate your account. To request new validation email, click the button below";
  static const send_new_validation_email = "Send new validation email";
  static const change_email_address = "Change email address";
  static const validate_email_processing = "An email is sent to your email address. Please click on the link in that email to validate your account. Click below button after you have validated your email";
  static const validated = "Validated";
}


class font {
  static const raleway = "Raleway";
}

class asset {
  static const nartus = "assets/nartus.png";
}

class menu {
  // drawer menu
  static const finance = "Finance";
  static const accounts = "Accounts";
  static const budgets = "Budgets";
  static const profile = "Profile";
  static const your_profile = "Your profile";
  static const about = "About";
  static const about_us = "About Us";

  static const sign_out = "Sign Out";
}