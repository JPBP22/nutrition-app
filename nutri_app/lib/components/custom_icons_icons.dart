import 'package:flutter/widgets.dart'; // Importing necessary Flutter widgets.

class CustomIcons {
  // Constructor marked with ._() to indicate that this class is intended to be a singleton or a utility class.
  // This prevents instantiation of this class from outside.
  CustomIcons._();

  // Declaring a constant string to represent the font family name.
  // This is used to specify the font in which the icons are defined.
  static const _kFontFam = 'CustomIcons';

  // Declaring a constant for the font package, set to null since this is a local asset.
  static const String? _kFontPkg = null;

  // Defining a custom icon named 'gpt_logo'. IconData is a class that holds information about a specific icon in a font.
  // 0xe800 is the Unicode value of the icon in the font file.
  // fontFamily is set to the previously defined font family name.
  // fontPackage is set to the previously defined font package name, which is null in this case since it's a local asset.
  static const IconData gpt_logo =
      IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
}
