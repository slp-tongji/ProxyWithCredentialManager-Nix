{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.proxy-with-credential-manager;
in
{
  options.services.proxy-with-credential-manager = {
    enable = lib.mkEnableOption "ProxyWithCredentialManager";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../package { };
      description = "The ProxyWithCredentialManager package to use.";
    };

    proxyPort = lib.mkOption {
      type = lib.types.port;
      description = "Port on which the proxy server listens (on loopback).";
    };

    credentialManagerPort = lib.mkOption {
      type = lib.types.port;
      description = "Port on which the credential manager API listens (on loopback).";
    };

    stateDirectory = lib.mkOption {
      type = lib.types.str;
      default = "proxy-with-credential-manager";
      description = "systemd `StateDirectory` (under `/var/lib`) where the credential database is stored.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "proxy-with-credential-manager";
      description = "User account under which the service runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "proxy-with-credential-manager";
      description = "Group under which the service runs.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
    };
    users.groups.${cfg.group} = { };

    systemd.services.proxy-with-credential-manager = {
      description = "ProxyWithCredentialManager";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = cfg.stateDirectory;
        ExecStart = lib.concatStringsSep " " [
          (lib.getExe cfg.package)
          "run"
          "--proxy-port"
          (toString cfg.proxyPort)
          "--credential-manager-port"
          (toString cfg.credentialManagerPort)
          "--credential-database"
          "/var/lib/${cfg.stateDirectory}/credentials.db"
        ];
        Restart = "on-failure";
      };
    };
  };
}
