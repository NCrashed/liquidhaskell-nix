# liquidhaskell-nix

This is auxiliary scripts that helps you to integrate [Liquid Haskell](https://ucsd-progsys.github.io/liquidhaskell-blog/) into your project.

# Usage

See example at [liquidhaskell-test](https://github.com/liquidhaskell-test).

The project provides you overlay with liquid haskell packages and script helpers:
``` nix
let nixpkgs = import <nixpkgs> {
      config = {
        overlays = [
          (import liquidOverlay {})
        ];
      };
    };
    liquidOverlay = nixpkgs.fetchFromGitHub {
      owner = "NCrashed";
      repo = "liquidhaskell-nix";
      rev = "417fe0fc17ab93b5fec43151511c7400f96afb18";
      sha256  = "1j9p6f9nyk0ynyvv92j71gbxz1c3ks2wy15pxrc1k5iicpssgjq0";
    };
in { /* .... */ }
```

The overlay contains two helpers. First, tool that adds `z3` solver as additional dependency to your package as liquid haskell plugin needs it:
``` nix
mypkg = pkgs.addLiquidSolver super.mypkg;
```

The second, helper that defines `configureFlags` env for shell as `z3` need to be found by plugin when you call cabal in shell:
``` nix
shellHook = ''
  ${pkgs.addLiquidSolverHook}
'';
```
