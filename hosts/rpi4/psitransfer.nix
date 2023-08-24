{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.psitransfer;
in {
  options.services.psitransfer = {
    enable = mkEnableOption "If enabled, PsiTransfer will run.";

    package = mkOption {
      default = pkgs.psitransfer;
      defaultText = literalExpression "pkgs.psitransfer";
      type = types.package;
      description = ''
        PsiTransfer package to use.
        '';
    };

    listenAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = ''
        Address to listen on (use 0.0.0.0 to allow access from any address).
        '';
    };

    port = mkOption {
      type = types.port;
      default = 3000;
      description = ''
        Port to bind to.
        '';
    };

    uploadDirectory = mkOption {
      type = types.path;
      description = ''
        Specifies which directory PsiTransfer will store uploaded files.
        '';
    };

    uploadPasswordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/keys/psitransfer-upload-password";
      description = ''
        A path to a file containing the upload password.
        '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.psitransfer = {
      description = "PsiTransfer Service";
      wantedBy    = [ "multi-user.target" ];
      after       = [ "network.target" ];
      environment = {
        NODE_ENV           	    = "production";
        PSITRANSFER_IFACE           = toString cfg.listenAddress;
        PSITRANSFER_PORT            = toString cfg.port;
        PSITRANSFER_UPLOAD_DIR      = toString cfg.uploadDirectory;

	# TODO other possible options that are yet to be implemented
        # PSITRANSFER_UPLOAD_PASS     = optionalString (cfg.uploadPasswordFile != null) "$(head -n1 ${toString cfg.uploadPasswordFile})";
	# PSITRANSFER_BASE_URL = "/";
	# PSITRANSFER_ADMIN_PASS = false;
	# PSITRANSFER_UPLOAD_APP_PATH = "/";
	# PSITRANSFER_REQUIRE_BUCKET_PASSWORD = false;
	# PSITRANSFER_MAX_AGE = 0; # in seconds
	# The following are in in bytes
	# PSITRANSFER_MAX_PREVIEW_SIZE = 0; # 2 MB
	# PSITRANSFER_MAX_FILE_SIZE = 0; # 2 GB
	# PSITRANSFER_MAX_BUCKET_SIZE = 0; # 10 GB
      };

      serviceConfig = {
        DynamicUser    = true;
        Restart        = "always";
        StateDirectory = "psitransfer";
      };

      #preStart    = ''
      #  ${optionalString (cfg.uploadPasswordFile != null) ''
      #    PSITRANSFER_UPLOAD_PASS="$(<${lib.escapeShellArg cfg.uploadPasswordFile})"
      #    export PSITRANSFER_UPLOAD_PASS
      #  ''}
      #'';
      script = ''
        export PSITRANSFER_UPLOAD_PASS="$(head -n1 ${toString cfg.uploadPasswordFile})"
        exec ${cfg.package}/bin/psitransfer
      '';
    };
  };
}
