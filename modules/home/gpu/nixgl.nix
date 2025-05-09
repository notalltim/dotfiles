cfg: _: prev: {
  nixgl = prev.nixgl.override {
    nvidiaVersion = cfg.nvidia.driverVersion;
    nvidiaHash = cfg.nvidia.driverHash;
  };
}
