enum StringCasing {
  Normal,
  Capitalize,
  CapitalizeWords,
  UpperCase,
  LowerCase,
}

extension StringExtensions on String {
  changeCasing(StringCasing casing) {
    if (this == null || this.isEmpty) {
      return this;
    }

    switch (casing) {
      case StringCasing.Capitalize:
        return this.capitalize;
      case StringCasing.CapitalizeWords:
        return this.capitalizeWords;
      case StringCasing.UpperCase:
        return this.toUpperCase();
      case StringCasing.LowerCase:
        return this.toLowerCase();
      case StringCasing.Normal:
      default:
        return this;
    }
  }

  get capitalize {
    if (this == null || this.isEmpty) {
      return this;
    }

    return this[0].toUpperCase() + this.substring(1);
  }

  get capitalizeWords {
    if (this == null || this.isEmpty) {
      return this;
    }

    return this.split(' ').map((word) => word.capitalize).join(' ');
  }
}
