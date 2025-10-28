// Spacing sizes for unified spacing across screens
enum SpaceSize {
  xsmall,
  small,
  medium,
  large,
  xlarge;

  double get value {
    return switch (this) {
      SpaceSize.xsmall => 4.0,
      SpaceSize.small => 8.0,
      SpaceSize.medium => 16.0,
      SpaceSize.large => 24.0,
      SpaceSize.xlarge => 32.0,
    };
  }
}
