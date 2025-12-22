enum Flavor {
  production,
  dev,
  stg,
  uat,
}

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.production:
        return 'Home Repair';
      case Flavor.dev:
        return 'Home Repair (DEV)';
      case Flavor.stg:
        return 'Home Repair (STG)';
      case Flavor.uat:
        return 'Home Repair (UAT)';
    }
  }

}
