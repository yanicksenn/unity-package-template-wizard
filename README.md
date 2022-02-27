# Unity Package Wizard

This simple wizard prepares an empty unity package according to your preferences.

## Requirements

- `git` installation
- Able to clone repositories from GitHub

## Usage

Clone this repository into your project and run `setup.sh` to start the wizard.

```
$ ./setup.sh
Unity-Version (2021.2.12f1):
Name: MyPackage
Version: 1.0.0
Display Name (MyPackage): My Package
Description (MyPackage): This is the description to my package.
Author Name: John Doe
Author Email: info@johndoe.com
Assembly Name (MyPackage): MyPackage
Assembly Namespace (MyPackage): MyPackage.Core
Continue with setup? [y/N]: y
```

Afterwards you should find the files in the following structure:

```
MyPackage
  |
  |--- Runtime
  |  |--- MyPackage.asmdef
  |
  |--- Editor
  |  |--- MyPackage.Editor.asmdef
  |
  |--- Tests
  |  |--- Runtime
  |  |  |--- MyPackage.Tests.asmdef
  |  |
  |  |--- Editor
  |     |--- MyPackage.Editor.Tests.asmdef
  |
  |--- package.json
  |--- README.md
```

I recommend initialising a local git repository inside the newly created package folder and pushing it to a public repository which will allow you to distribute your package through the internet.

## References

- [Unity Package Layout](https://docs.unity3d.com/Manual/cus-layout.html)
- [Unity Package Template](https://github.com/yanicksenn/unity-package-template)
- [Sharing you package](https://docs.unity3d.com/Manual/cus-share.html)
