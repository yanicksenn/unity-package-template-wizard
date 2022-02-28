# Unity Package Wizard

This simple wizard prepares an empty unity package according to your preferences.

## Requirements

- `bash`
- `git`
- Able to clone repositories from GitHub

## Usage

Clone this repository and run the `setup.sh` in the `Assets` folder inside of your unity project to start the wizard.

```
Assets $ ./unity-package-wizard/setup.sh
Unity Package Wizard (1.0.0)

Name: MyPackage
Version: 1.0.0
Display Name (MyPackage): My Package
Description (MyPackage): This is the description to my package.
Unity (2020.3): 2021.2
Unity Release (30f1): 12f1
Author Name: John Doe
Author Email: info@johndoe.com
Assembly Name (MyPackage): MyPackage
Assembly Namespace (MyPackage): MyPackage.Core

Empty package will be created at:
  /Users/myself/Documents/MyUnityProject/Assets/MyPackage

Continue with setup? [y/N]: y
```

This will create the following folders and files.
Notice that the editor as well as the test assemblies are created according to the [Unity Package Layout](https://docs.unity3d.com/Manual/cus-layout.html).

```
./MyPackage
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

To ensure that your package stays clean I recommend ...
- ... creating a separate unity project specifically for your package. This allows you to be sure that all script dependencies are met and that you do not have any compilation errors when when sharing it.
- ... initialising a local git repository inside of the newly created package folder and pushing it to a "public" repository. This allows you to simply depend on your package by passing the git url inside of you unity package manager.


Also keep in mind that you do not have to directly clone this repository into your unity project.

```
Assets $ ./Users/myself/Documents/somewhere/unity-package-wizard/setup.sh
```

## References

- [Unity Package Layout](https://docs.unity3d.com/Manual/cus-layout.html)
- [Unity Package Template](https://github.com/yanicksenn/unity-package-template)
- [Sharing you package](https://docs.unity3d.com/Manual/cus-share.html)
