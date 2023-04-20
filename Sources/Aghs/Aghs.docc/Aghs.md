# ``Aghs``

A pure SwiftUI toolkit to boost productivity.

## Overview

Aghs is composed of three parts:

- ax: Includes some Swift [Extensions](<doc:Extensions>) and SwiftUI [ViewModifiers](<doc:ViewModifiers>). 

  The majority of features in **Extensions** and **ViewModifiers** should be invoked in the `.ax` style. Such as `UIScreen.ax.width` or `content.ax.customNavBackButton`. Some APIs, however, do not require the `.ax`, like `content.ax_if`.

- [Components](<doc:Components>): A selection of commonly used UI components.

  UI components can be used directly, although their associated view modifiers might need to be applied using the `.ax` style. For instance, ``Hud`` can be used directly, but the ``Aghs/Ax/hud(_:)`` should be invoked using the `.ax` style.

- [Utils](<doc:Utils>): A collection of useful utilities.

  Utils are typically called using the `Aghs.` style , such as `Aghs.print` or `Aghs.AppInfo.version`.

> Tip: An example showcasing the primary features of Aghs can be found at [Aghs-example](https://github.com/woter-xyz/Aghs-example).

![Aghs logo](aghs-logo.png)

## Topics

### ax

- <doc:Extensions>
- <doc:ViewModifiers>

### Components

- <doc:Components>

### Utils

- <doc:Utils>

### Others

- <doc:Others>

