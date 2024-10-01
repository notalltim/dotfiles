pkgs: {
  version = "2.1";
  src = pkgs.fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "xdg";
    repo = "shared-mime-info";
    rev = "2.1";
    sha256 = "sha256-Ze2Bv2LBziyIspRtWD1unJ5IPSjeW1c9wfgOcgnZfR0=";
  };

  patches = [
    (pkgs.fetchpatch {
      name = "xmlto-optional.patch";
      url = "https://gitlab.freedesktop.org/xdg/shared-mime-info/-/merge_requests/110.patch";
      sha256 = "sha256-nVJ1tqrG5kGkT91RJFpQHFMFgy4gtHvYKlEiWxntr1w=";
    })
    (pkgs.fetchpatch {
      name = "itstool.patch";
      url = "https://git.adelielinux.org/-/project/45/uploads/9947706ea17fbac35d47ebed689cfa3c/shared-mime-info-2.1-itstool.patch";
      sha256 = "sha256-lGxpLwgeqW4QQQbDWnNxtmPswihSB0eggs2rE2RLmNw=";
    })
  ];

}
