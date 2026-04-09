#let seed = (
  "font-warning-seed"
    .codepoints()
    .map(str.to-unicode)
    .fold(0, (a, b) => calc.rem-euclid((a * 31 + b), calc.pow(2, 31) - 1))
)
#let hash(value) = {
  value
    .codepoints()
    .map(str.to-unicode)
    .fold(seed, (a, b) => calc.rem-euclid((a * 31 + b), calc.pow(2, 31) - 1))
}

#let max-value = calc.pow(2, 32) - 1
/// Disables warnings emitted under the namespace `namespace`.
/// Use like: `show: disable-warnings("cstm")`
/// To enable warnings, use the `enable-warnings` function with the same namespace.
///
/// Note that only 4 characters may be used for the namespace. And the namespace has restrictions, see the `warning` function for details.
///
/// - namespace (str): The namespace for which to disable warnings. Only 4 characters may be used.
/// -> function
#let disable-warnings(namespace) = {
  assert(
    type(namespace) == str and namespace.len() <= 4,
    message: "Namespace passed to `disable-warnings` must be a 4-character string.",
  )
  let ret(namespace, body) = {
    let d = (:)
    d.insert(namespace, max-value)
    set text(features: d)
    body
  }
  ret.with(namespace)
}
/// Enables warnings emitted under the namespace `namespace`.
/// Use like: `show: enable-warnings("cstm")`
/// To disable warnings, use the `disable-warnings` function with the same namespace.
///
/// Note that only 4 characters may be used for the namespace. And the namespace has restrictions, see the `warning` function for details.
///
/// - namespace (str): The namespace for which to enable warnings. Only 4 characters may be used.
/// -> function
#let enable-warnings(namespace) = {
  assert(
    type(namespace) == str and namespace.len() <= 4,
    message: "Namespace passed to `enable-warnings` must be a 4-character string.",
  )
  let rnd = hash(namespace)
  let ret(namespace, rnd, body) = {
    let d = (:)
    d.insert(namespace, rnd)
    set text(features: d)
    body
  }
  ret.with(namespace, rnd)
}

#let delete-font-warning = range(21).map(i => "\u{0008}").sum()
/// Display a warning message with `set text(font: ..)` magic.
/// By default, warnings are enabled. To disable warnings, use the `disable-warnings` function.
///
/// Note that this won't show the real location where the warning occured, but this function body instead. As such you should put some info about the cause, location and how to fix it in the message.
///
/// - namespace (str): The warning namespace. Only 4 characters may be used. This allows all your packages to use warnings side-by-side without interfering with each other. Note that this interferes with the text features map, so the namespace should be chosen carefully to avoid conflicts with real text features. Before deciding on anything, check https://learn.microsoft.com/en-us/typography/opentype/spec/featurelist (No guarantees for the content behind the link, visit at your own risk).
/// - prefix (str): The warning prefix.
/// - message (str): The warning message.
/// -> content
#let warning(namespace: "cstm", prefix: "[custom] ", message) = context {
  let rnd = hash(namespace)
  let message = if text.features.at(namespace, default: rnd) == rnd {
    delete-font-warning + prefix + message
  } else {
    "libertinus serif"
  }
  set text(font: message)
}
