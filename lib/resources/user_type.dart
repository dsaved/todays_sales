class UserType {
  static Map<String, dynamic> dataMap;

  static void setUp() {
    dataMap = new Map<String, dynamic>();
    dataMap["store_owner"] = "STORE OWNER";
    dataMap["sales_agent"] = "SALES AGENT";
  }

  static List<String> getUserTypeList() {
    setUp();
    List<String> list = [];
    // Get a set of the entries
    var keys = dataMap.keys.toList();

    for (String key in keys) {
      list.add(dataMap[key]);
    }
    return list;
  }

  static String getUserTypeCode(String country) {
    setUp();
    var keys = dataMap.keys.toList();
    // check if data match then return country code
    for (String key in keys) {
      if (country.trim() == dataMap[key]) {
        return key;
      }
    }
    return null;
  }

  static String getUserType(String code) {
    setUp();
    var keys = dataMap.keys.toList();
    // check if data match then return country name
    for (String key in keys) {
      if (code.trim() == key) {
        return dataMap[key];
      }
    }
    return null;
  }
}