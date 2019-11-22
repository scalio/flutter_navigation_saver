# Flutter navigation saver library (shared preferences module)

This library will help to restore navigation stack after application kill.

## Overview

This library should be used if you have some special way of serializing arguments into the string and back. Also do not forget to check [general readme](../../../).


## How does this module work:

1. It uses the [core module](../../../navigation_saver) and extends it to save routes to the [shared preferences](https://pub.dev/packages/shared_preferences).
2. All the controll of converting routes to string is up to the application user code.
3. `maximumDurationBetweenRestoration` is used to understand if we need to restore routes or too much time was passed. Default is 5 minutes.