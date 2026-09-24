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
      defaultText = lib.literalExpression "pkgs.callPackage ../package { }";
      description = "The ProxyWithCredentialManager package to use.";
    };

    proxyPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port on which the proxy server listens (on loopback).";
    };

    credentialManagerPort = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Port on which the credential manager API listens (on loopback).";
    };

    credentialDatabase = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/proxy-with-credential-manager/credentials.db";
      description = "Path to the credential database (LiteDB).";
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
        StateDirectory = "proxy-with-credential-manager";
        ExecStart = lib.concatStringsSep " " [
          (lib.getExe cfg.package)
          "run"
          "--proxy-port"
          (toString cfg.proxyPort)
          "--credential-manager-port"
          (toString cfg.credentialManagerPort)
          "--credential-database"
          (toString cfg.credentialDatabase)
        ];
        Restart = "on-failure";
      };
    };
  };
}
