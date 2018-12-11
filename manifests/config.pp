class lxc::config (
  $lxc_dir = $lxc::lxc_dir,
  $lxc_pkgname = $lxc::lxc_pkgname
) inherits lxc {
  # fstab entry: lxc /sys/fs/cgroup cgroup defaults 0 0

  include lxc::mounts

  mount { "/sys/fs/cgroup":
    atboot  => true,
    ensure  => mounted,
    fstype  => "cgroup",
    options => "defaults",
    dump    => 0,
    pass    => 0,
    device  => "lxc",
  }
  Package["${lxc_pkgname}"] -> Mount["/sys/fs/cgroup"]

  package { ["${lxc_pkgname}", "lxctl", "thin-provisioning-tools"]: ensure => latest, }
  Package["${lxc_pkgname}"] -> Package["lxctl"]

  Package["lvm2"] -> Package["thin-provisioning-tools"]
  Package["thin-provisioning-tools"] -> Package["${lxc_pkgname}"]

  File[
    "/var/cache/lxc", "/etc/lxc", "${lxc_dir}"] {
    ensure => directory,
  # require => Package["lxc"],
  }

  exec { "/usr/bin/lxc-ls >/tmp/lxc.ls":
    provider => shell,
    require  => [Mount["/tmp"], Package["lxc"]],
  }

  $clean_command = "cd ${lxc_dir} && find . -name \'*~\' -delete"

  exec { "${clean_command}":
    provider => shell,
    cwd      => "${lxc_dir}",
  }

  File["/etc/lxc/lxc.conf"] {
    ensure => present,
  }

  File["/etc/default/lxc.conf"] {
    ensure => link,
    target => "/etc/lxc/lxc.conf",
  }
  File["/etc/lxc/lxc.conf"] -> File["/etc/default/lxc.conf"]


}