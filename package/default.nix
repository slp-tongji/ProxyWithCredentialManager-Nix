{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
}:

buildDotnetModule (finalAttrs: {
  pname = "proxy-with-credential-manager";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "slp-tongji";
    repo = "ProxyWithCredentialManager";
    rev = "v${finalAttrs.version}";
    hash = "sha256-DSAK2HmE++fYJoA0bB6t/c3S9kXlsHl0wLsPBx0HORk=";
  };

  projectFile = "src/ProxyWithCredentialManager/ProxyWithCredentialManager.csproj";
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;

  nugetDeps = ./deps.nix;

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    description = "A proxy server with a credential manager API for creating, querying and revoking proxy credentials.";
    homepage = "https://github.com/slp-tongji/ProxyWithCredentialManager";
    license = lib.licenses.mit;
    mainProgram = "ProxyWithCredentialManager";
    maintainers = [ ];
  };
})
