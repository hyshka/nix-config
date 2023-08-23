{ inputs, config, ... }: {
  sops = {
    #age.keyFile = "/home/hyshka/.age-key.txt"; # must have no password!
    # It's also possible to use a ssh key, but only when it has no password:
    #age.sshKeyPaths = [ "/home/user/path-to-ssh-key" ];
    # TODO test on linux
    gnupg = with config.home; {
      home = "${homeDirectory}/.gnupg";
    };
    defaultSopsFile = ../secrets.yaml;
    secrets = {
      #test = {
      #  # sopsFile = ./secrets.yml.enc; # optionally define per-secret files

      #  # %r gets replaced with a runtime directory, use %% to specify a '%'
      #  # sign. Runtime dir is $XDG_RUNTIME_DIR on linux and $(getconf
      #  # DARWIN_USER_TEMP_DIR) on darwin.
      #  path = "%r/test.txt";
      #};
      # TODO move to cli/zsh.nix?
      mr_gemfury_deploy_token = {
        path = "%r/mr_gemfury_deploy_token.txt";
      };
      mr_pip_extra_index_url = {
        path = "%r/mr_pip_extra_index_url.txt";
      };
      mr_fontawesome_npm_auth_token = {
        path = "%r/mr_fontawesome_npm_auth_token.txt";
      };
    };
  };
}
