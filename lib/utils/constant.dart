enum FileCount { SINGLE, MULTIPLE }

class Constant {
  // API links
  static const String baseUrl = "https://pos-api.willvin.com/"; // TEMP HOST
  // static const String baseUrl = "http://192.168.8.143:8001/"; // MTN ROUTER
  // static const String baseUrl = "http://192.168.42.29:8001/"; // VODAFONE ROUTER
  static const String api = baseUrl;
  static const String login_store_owner = 'store-owner/login/';
  static const String verify = 'store-owner/verify_number/';
  static const String resend_code = 'store-owner/resend_code/';
  static const String register = 'store-owner/register/';
  static const String login_agent = 'sales-agent/login';
  static const String recover = 'recover/';
  static const String feedback = 'feedback/';

  static const String get_stores = 'store-owner/get-stores/';
  static const String get_sales = 'store-owner/get-sales/';

  static const String get_inventory = 'store-owner/inventory/';
  static const String add_inventory = 'store-owner/inventory/add/';
  static const String update_inventory = 'store-owner/inventory/update/';
  static const String delete_inventory = 'store-owner/inventory/delete/';

  static const String add_store = 'store-owner/add-store/';
  static const String update_store = 'store-owner/update-store/';
  static const String delete_store = 'store-owner/delete-store/';
  static const String store_owner_user_details = 'store-owner/user-details/';
  static const String store_owner_update_user = 'store-owner/update-user/';
  static const String store_owner_change_user_password = 'store-owner/change-user-password/';
  static const String getCustomers = 'store-owner/get-customers/';
  static const String getAgents = 'store-owner/get-agents/';
  static const String addAgents = 'store-owner/add-agent/';
  static const String updateAgents = 'store-owner/update-agent/';
  static const String updateAgentPassword = 'store-owner/update-agent-password/';
  static const String salesPaidFor = 'store-owner/sale-paid/';

  static const String sales_agent_user_details = 'sales-agent/user-details/';
  static const String sales_agent_update_user = 'sales-agent/update-user/';
  static const String get_sales_agent_sales = 'sales-agent/get-sales/';
  static const String sales_agent_change_user_password = 'sales-agent/change-user-password/';

  static const String saleRequest = 'sale-order/';
  static const String syncSaleRequest = 'sync-sales/';
  static const String getItemCatalogs = 'get-inventory/';

  static const String terms_and_condition = baseUrl + "policy/terms/";
  static const privacy_policy = baseUrl + "policy/privacy/";
  static const help = baseUrl + "policy/terms/";

  static const String appIcon = "assets/images/icon.png";
  static const String navBarBg = "assets/images/bg.jpg";
  static const String splashBg = "assets/images/splash_screen.png";
  static const String todays_sales_splash = "assets/images/todays_sales_spalsh.png";
  static const String todays_sales_icon_white = "assets/images/todays_sales_icon_white.png";
  static const String card_bottom_left = "assets/images/card-bottom.png";
  static const String card_top_right = "assets/images/card-top-right.png";
  static const String doneSVG = "assets/images/done.png";

  static const String regExpEmail = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
      "\\@" +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
      "(" +
      "\\." +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
      ")+";

  static const String app_dir = "todays_sales";
  static const String temp_dir = ".todays_sales_temp";

  static var imagePath  = "$baseUrl/library/image.php?path=";
  static var imageFormat  = "&format=";


  static var gestuser  = "guest user";
  static var gestuserEmail  = "guestuser@todays_sales.com";
  static var gestuserPhone  = "0000000000";
  static var gestuserPassword  = "null";


  static var storesPrefs  = "stores";
  static var salesPrefs  = "_sales";
  static var salesStatsPrefs  = "_sales_stats";
  static var storeDataPrefs  = "_store_data";
  static var customersPrefs  = "_customers_phone";
  static var agentsPrefs  = "_store_agents";
  static var storeCodePrefs  = "_store_code";
  static var itemListPrefs  = "_drugList";
  static var itemsListPrefs  = "items.json";
}
