{
  # Source of liquid haskell repository
  liquidSource ? (import ./liquid-src.nix)
, compiler ? "ghc8102"
}:
self: super:
let haskellOld = super.haskell;
    pkgs = self;
    lib  = self.haskell.lib;
    liquidPath = self.fetchgit liquidSource;
    addSystemLibs = drv: xs: lib.overrideCabal drv (drv: { librarySystemDepends = (drv.librarySystemDepends or []) ++ xs; });
    addSolver = drv: addSystemLibs drv [self.z3];
    callLiquid = self: name: self.callCabal2nixWithOptions name liquidPath "--no-check --no-haddock --subpath ${name}" {};
    callLiquidRoot = self: name: self.callCabal2nixWithOptions name liquidPath "--no-check" {};
in rec {
  addLiquidSolver = addSolver;
  addLiquidSolverHook = "configureFlags=--extra-lib-dirs=${self.z3.lib}/lib$configureFlags";
  haskell = haskellOld // {
    packages = haskellOld.packages // {
      "${compiler}" = haskellOld.packages."${compiler}".extend (self: super:
        let dirOverrides = lib.packagesFromDirectory {
                directory = ./pkgs;
              } self super;
            manualOverrides = {
              z3sys = pkgs.z3;
              liquid-base = addSolver (callLiquid self "liquid-base");
              liquid-bytestring = addSolver (callLiquid self "liquid-bytestring");
              liquid-containers = addSolver (callLiquid self "liquid-containers");
              liquid-fixpoint = callLiquid self "liquid-fixpoint";
              liquid-ghc-prim = addSolver (callLiquid self "liquid-ghc-prim");
              liquid-parallel = addSolver (callLiquid self "liquid-parallel");
              liquid-platform = callLiquid self "liquid-platform";
              liquid-prelude = addSolver (callLiquid self "liquid-prelude");
              liquid-vector = addSolver (callLiquid self "liquid-vector");
              liquidhaskell = callLiquidRoot self "liquidhaskell";
            };
        in dirOverrides // manualOverrides);
    };
  };
}
