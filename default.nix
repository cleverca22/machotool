with import <nixpkgs> {};

haskellPackages.override {
  overrides = self: super: {
    machotool = self.callCabal2nix "machotool" ./. {};
    macho = self.callCabal2nix "macho" ./macho-0.22 {};
  };
}
