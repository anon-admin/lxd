class lxc::create_lvm($vgname = $lxc::lxc_vgname) inherits lxc {
  
    $lxc_lvname = $lxc::lxc_lvname
    $lxc_lvsize = $lxc::lxc_lvsize
    $lxc_lvfs = $lxc::lxc_lvfs
    $lxc_mountpoint = $lxc::lxc_mountpoint

    storage::lvm::createlv { "${lxc_lvname}":
      vgname     => $vgname,
      size       => "${lxc_lvsize}",
      fstype     => "${lxc_lvfs}",
      mountpoint => "${$lxc_mountpoint}"
    }

    include lxc::clean

}
