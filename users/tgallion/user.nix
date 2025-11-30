{ ... }:
{
  baseline = {
    users.tgallion = {
      username = "tgallion";
      fullName = "Timothy Gallion";
    };
    userModule = {

      fingerprints = (
        builtins.map
          (finger: {
            inherit (finger) name path;
            module = "uru4000";
            slot = "0";
          })
          [
            {
              name = "1";
              path = ./secrets/fingerprint/right-little-finger.age;
            }

            {
              name = "2";
              path = ./secrets/fingerprint/right-thumb.age;
            }
            {
              name = "4";
              path = ./secrets/fingerprint/right-index-finger.age;
            }
            {
              name = "9";
              path = ./secrets/fingerprint/right-middle-finger.age;
            }
            {
              name = "6";
              path = ./secrets/fingerprint/right-ring-finger.age;
            }
            {
              name = "7";
              path = ./secrets/fingerprint/left-index-finger.age;
            }
            {
              name = "8";
              path = ./secrets/fingerprint/left-ring-finger.age;
            }
            {
              name = "5";
              path = ./secrets/fingerprint/left-middle-finger.age;
            }
            {
              name = "a";
              path = ./secrets/fingerprint/left-little-finger.age;
            }
            {
              name = "3";
              path = ./secrets/fingerprint/left-thumb.age;
            }
          ]
      );
    };
  };
}
