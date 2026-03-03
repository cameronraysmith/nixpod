{
  programs.git = {
    enable = true;
    # userName = "John Doe";
    # userEmail = "johndoe@email.net";
    # signing = {
    #   key = "1234567890ABCDEF";
    #   signByDefault = true;
    # };
    settings = {
      core.editor = "nvim";
      credential.helper = "store --file ~/.git-credentials";
      color.ui = true;
      commit.gpgsign = false;
      diff.colorMoved = "zebra";
      fetch.prune = true;
      format.signoff = true;
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      push.autoSetupRemote = true;
      rebase.autoStash = true;
      alias = {
        a = "add";
        br = "branch";
        bra = "branch -a";
        c = "commit";
        ca = "commit --amend";
        can = "commit --amend --no-edit";
        cavm = "commit -a -v -m";
        cfg = "config --list";
        cl = "clone";
        cm = "commit -m";
        co = "checkout";
        cp = "cherry-pick";
        cpx = "cherry-pick -x";
        d = "diff";
        f = "fetch";
        fo = "fetch origin";
        fu = "fetch upstream";
        lease = "push --force-with-lease";
        lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
        lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
        pl = "pull";
        pr = "pull -r";
        ps = "push";
        psf = "push -f";
        rb = "rebase";
        rbi = "rebase -i";
        r = "remote";
        ra = "remote add";
        rr = "remote rm";
        rv = "remote -v";
        rs = "remote show";
        st = "status";
        stn = "status -uno";
      };
    };
    ignores = [
      "*~"
      "*.swp"
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      side-by-side = true;
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --color-only --dark --paging=never";
          useConfig = false;
        };
        commit = {
          signOff = true;
        };
      };
    };
  };
}
