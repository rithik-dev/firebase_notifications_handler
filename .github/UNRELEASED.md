<!-- Pending release notes. The release workflow moves these into CHANGELOG.md under the new version heading, then clears this file. Write them for the people who use this package, using the same `* entry` bullet style as CHANGELOG.md. This file lives under .github/ so it never ships to pub.dev. -->

* Declared `timezone` and `path` as direct dependencies; both were imported by the package but resolved only transitively.
* Added GitHub Actions CI to automate version bumps, changelog updates, tagging and pub.dev publishing.
