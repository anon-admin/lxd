define lxc::install (
  $vgname = $lxc::lxc_vgname,
  $interfaces = []
) {
  $service_name = $name

  $lxc_dir = $lxc::lxc_dir
  $lxc_service_name = "${hostname}_${service_name}"
  $lxc_service_dir = "${lxc_dir}/${lxc_service_name}"
  $lxc_service_preconfig = "${lxc_service_dir}.config"
  $lxc_service_config = "${lxc_service_dir}/config"

  file { "${lxc_service_preconfig}":
    content => template("lxc/config.erb.${lsbdistcodename}"),
    require => Package["lxc"],
  }

  case $lsbdistcodename {
    wheezy : {
      lxc::fstab_has_line { "${service_name}:proc proc proc nodev,noexec,nosuid 0 0": vgname => $vgname, }
    }
  }

  lxc::fstab_has_line { "${service_name}:/opt/${vgname}/${service_name} var/${service_name} none rw,bind 0 0": vgname => $vgname, }

  file { "${lxc_dir}/fstab.${service_name}": before => Exec["lxc-create -B lvm --vgname ${vgname} -f ${lxc_service_preconfig} -n ${lxc_service_name}"
      ] }

  # lxc-create -n experience_front -B lvm --vgname DATA -t raspbian -- -r jessie
  # deplacer /var/cache/lxc/raspbian dans storage

  # SUITE=jessie MIRROR=http://mirrordirector.raspbian.org/raspbian lxc-create -B lvm --vgname DATA2 --thinpool=LxdPool --fssize=1G --lvname bronco_front --fstype ext4 -n bronco_front -t debian
  # Checking cache download in /var/cache/lxc/debian/rootfs-jessie-armhf

  exec { "lxc-create -B lvm --vgname ${vgname} -f ${lxc_service_preconfig} -n ${lxc_service_name}":
    provider => shell,
    unless   => "/bin/grep ${lxc_service_name} /tmp/lxc.ls",
    #unless   => "/usr/bin/test -f ${lxc_service_dir}/rootfs.dev",
    require  => [ Exec["/usr/bin/lxc-ls >/tmp/lxc.ls"], File[$lxc_service_preconfig] ],
  }

  file { "${lxc_service_config}":
    source  => "${lxc_service_preconfig}",
    require => Exec["lxc-create -B lvm --vgname ${vgname} -f ${lxc_service_preconfig} -n ${lxc_service_name}"]
  }

#  file { "/tmp/${lxc_service_name}.ifconfig":
#    mode    => 700,
#    content => template("lxc/ifconfig.erb"),
#  }
#  Mount["/tmp"] -> File["/tmp/${lxc_service_name}.ifconfig"]
#
#  exec { "/tmp/${lxc_service_name}.ifconfig": require => File["/tmp/${lxc_service_name}.ifconfig"], }



}