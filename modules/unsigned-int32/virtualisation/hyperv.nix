{
  config,
  lib,
  pkgs,
  users,
  meanvoid-overlay,
  ...
}: let
  admins = ["ashuramaru" "meanrin"];
in {
  boot.extraModprobeConfig = "options kvm_intel kvm_amd nested=1";
  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [
      "br0"
      "virbr0"
      "virbr1"
      "vireth0"
    ];
    extraOptions = [
      "--verbose"
    ];
  };
  virtualisation.libvirtd.qemu = {
    ovmf = {
      enable = true;
      packages = [
        pkgs.OVMFFull.fd
      ];
    };
    verbatimConfig = ''
      cgroup_device_acl = [
        "/dev/null",
        "/dev/full",
        "/dev/zero",
        "/dev/random",
        "/dev/urandom",
        "/dev/ptmx",
        "/dev/kvm",
        "/dev/nvidiactl",
        "/dev/nvidia0",
        "/dev/nvidia-modeset",
        "/dev/dri/renderD128"
      ]
    '';
    swtpm.enable = true;
    runAsRoot = true;
  };
  virtualisation.spiceUSBRedirection.enable = true;
  services = {
    spice-webdavd.enable = true;
    spice-vdagentd.enable = true;
  };

  users.groups = {
    kvm.members = admins;
    libvirtd.members = admins;
    qemu.members = admins;
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    virt-top
    spice
    spice-gtk
    spice-protocol
    virtio-win
    virtiofsd
    win-spice
    swtpm
    looking-glass-client
  ];
  environment.etc = {
    "ovmf/edk2-x86_64-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-code.fd";
    };
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };
    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
    };
    "ovmf/edk2-i386-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-secure-code.fd";
    };
    "ovmf/edk2-aarch64-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-aarch64-code.fd";
    };
    "ovmf/edk2-arm-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-arm-code.fd";
    };
    "ovmf/edk2-arm-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-arm-vars.fd";
    };
  };
  virtualisation.kvmfr = {
    enable = false;
    shm = {
      enable = false;
      size = 128;
      user = "ashuramaru";
      group = "libvirtd";
      mode = "0660";
    };
  };
  systemd.services.libvirtd.path = with pkgs; [
    virtiofsd
    virtio-win
    mdevctl
    swtpm
    looking-glass-client
  ];
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
}
