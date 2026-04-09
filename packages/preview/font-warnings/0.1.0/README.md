# font-warnings

A tiny Typst utility for package authors who want to surface custom warnings, while still allowing users to disable those warnings by namespace.

This package exposes three functions:

- `warning` to emit a warning message.
- `disable-warnings` to suppress warnings for one namespace.
- `enable-warnings` to re-enable warnings for one namespace.

## Why this exists

Typst currently has no package-level diagnostics hooks. `font-warnings` uses a small `set text(...)` trick to inject warning messages, and allows package users to opt out when they already understand the warning.

## Installation

If installed as a local package, import from the package root:

```typst
#import "@local/font-warnings:0.1.0": warning, disable-warnings, enable-warnings
```

Otherwise:

```typst
#import "@preview/font-warnings:0.1.0": warning, disable-warnings, enable-warnings
```

## Quick start

```typst
#import "@preview/font-warnings:0.1.0": *

#let ns = "mpkg"
#let pkg-warning = warning.with(namespace: ns, prefix: "[my-pkg] ")

// Visible by default
#pkg-warning("Unsupported option \"foo\"; falling back to default.")

// Disable all warnings in this namespace
#show: disable-warnings(ns)
#pkg-warning("This will not be shown.")

// Re-enable later
#show: enable-warnings(ns)
#pkg-warning("Warnings are visible again.")
```

## API

### `warning(namespace: "cstm", prefix: "[custom] ", message)`

Emits a warning-like message.

- `namespace` (`str`): Warning namespace used for on/off control. Must be at most 4 characters. And you cannot choose just any, see [here](#namespace-rules-and-caveats).
- `prefix` (`str`): Prefix prepended to the warning text.
- `message` (`str`): Warning body.
- returns: `content`

Use `warning.with(...)` to create a package-local warning function with fixed namespace and prefix.

### `disable-warnings(namespace)`

Returns a function to use in a show rule, that disables warnings for the given namespace.

- `namespace` (`str`): Must be at most 4 characters.
- returns: `function`

Usage:

```typst
#show: disable-warnings("fwrn")
```

### `enable-warnings(namespace)`

Returns a function to use in a show rule, that enables warnings for the given namespace.

- `namespace` (`str`): Must be at most 4 characters.
- returns: `function`

Usage:

```typ
#show: enable-warnings("fwrn")
```

## Namespace rules and other Caveats

- Namespaces must be strings of length `<= 4`.
- Namespace keys are stored in `text.features`; choose values that do not collide with real OpenType feature tags. Check https://learn.microsoft.com/en-us/typography/opentype/spec/featurelist before deciding on one.
- Warnings are enabled by default.
- The source location reported by Typst will generally point to the warning function internals, not the original call site. Include enough context in your message to make debugging easy.

## Best practices for package authors

- Reserve one namespace per package, for example `"mpkg"`.
- Bind the warning utils into your package:

```typst
//my-package/internals.typ
#import "@preview/font-warnings:0.1.0": warning, disable-warnings, enable-warnings
//use internally
#let warning = warning.with(namespace: "mpkg", prefix: "[my-package] ")
//expose these
#let disable-warnings = disable-warnings.with("mpkg")
#let enable-warnings = enable-warnings.with("mpkg")

//user-doc
#import "@preview/my-package:0.1.0" as mpkg
#show: mpkg.disable-warnings
```

- Keep warning messages actionable: explain what happened, where, and how to fix it.
- Explain how users should use the warning utils you expose.
## License

MIT

## Contribution
Some ideas also by `OrangeX4`.