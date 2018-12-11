class lxc::mounts (
  $lxc_lvname     = $lxc::lxc_lvname,
  $lxc_vgname     = $lxc::lxc_vgname,
  $lxc_lvfs       = $lxc::lxc_lvfs,
  $lxc_mountpoint = $lxc::lxc_mountpoint) inherits lxc {
    
    include lxc::create_lvm
    
  file { "${lxc_mountpoint}": ensure => directory, }

  mount { "${lxc_mountpoint}":
    device  => "LABEL=${lxc_vgname}-${lxc_lvname}",
    fstype  => "${lxc_lvfs}",
    options => "defaults",
    pass    => 2,
    atboot  => true,
    ensure  => mounted,
    require => File["${lxc_mountpoint}"],
  }

  file { ["${lxc_mountpoint}/cache", "${lxc_mountpoint}/config", "${lxc_mountpoint}/lib"]:
    ensure  => directory,
    require => Mount["${lxc_mountpoint}"],
  }

  file { "${lxc_mountpoint}/etc":
    ensure => link,
    target => "${lxc_mountpoint}/config",
  }

  mount { "/etc/lxc":
    device  => "${lxc_mountpoint}/config",
    require => [File["/etc/lxc", "${lxc_mountpoint}/config"], Mount["${lxc_mountpoint}"]],
  }

  mount { "/var/cache/lxc":
    device  => "${lxc_mountpoint}/cache",
    require => [File["/var/cache/lxc", "${lxc_mountpoint}/cache"], Mount["${lxc_mountpoint}"]],
  }

  mount { "/var/lib/lxc":
    device  => "${lxc_mountpoint}/lib",
    require => [File["/var/lib/lxc", "${lxc_mountpoint}/lib"], Mount["${lxc_mountpoint}"]],
  }

  Mount[
    "/etc/lxc", "/var/cache/lxc", "/var/lib/lxc"] {
    fstype  => none,
    options => "bind,rw",
    before  => Package["lxc"],
    atboot  => true,
    ensure  => mounted,
  }

  contain lxc::clean
}
