{- https://github.com/dhall-lang/dhall-nethack/raw/master/Prelude.dhall
   This file provides a central `Prelude` import for the rest of the library to
   use so that the integrity check only needs to be updated in one place
   whenever upgrading the interpreter.

   This allows the user to provide their own Prelude import using the
   `DHALL_PRELUDE` environment variable, like this:

   ```
   $ export DHALL_PRELUDE='https://prelude.dhall-lang.org/package.dhall sha256:...'
   ```

   Note that overriding the Prelude in this way only works if this repository
   is imported locally.  Remote imports do not have access to environment
   variables and any attempt to import one will fall back to the next available
   import.  To learn more, read:

   * https://github.com/dhall-lang/dhall-lang/wiki/Safety-guarantees#cross-site-scripting-xss

   This file also provides an import without the integrity check as a slower
   fallback if the user is using a different version of the Dhall interpreter.
-}

  env:DHALL_PRELUDE
? https://raw.githubusercontent.com/dhall-lang/dhall-lang/v8.0.0/Prelude/package.dhall sha256:0c04cbe34f1f2d408e8c8b8cb0aa3ff4d5656336910f7e86190a6d14326f966d
? https://raw.githubusercontent.com/dhall-lang/dhall-lang/v8.0.0/Prelude/package.dhall
