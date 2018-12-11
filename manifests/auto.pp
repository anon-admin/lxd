class lxc::auto($lxc_dir = $lxc::lxc_dir) inherits lxc {

  file { "/etc/default/lxc":
    content => template("lxc/initd.default.erb")
  }
  
  file {  "/etc/lxc/auto": ensure => directory, }
  Package["lxc"] -> File["/etc/lxc/auto"]

  include lxc::service

  define install_auto($vgname = "DATA", $interfaces = []) {

    $service_name = $name

    $lxc_dir = $lxc::lxc_dir
    $lxc_service_name = "${hostname}_${service_name}"
    $lxc_service_dir = "${lxc_dir}/${lxc_service_name}"
    $lxc_service_preconfig = "${lxc_service_dir}.config"
    $lxc_service_config = "${lxc_service_dir}/config"

    lxc::install { "${service_name}":
      vgname     => $vgname,
      interfaces => $interfaces,
    }

    file { "/etc/lxc/auto/${hostname}_${service_name}.config":
      ensure => link,
      target => $lxc_service_config,
      notify => Service[lxc],
      before => Service[lxc],
    }

    File["${lxc_service_config}"] -> File["/etc/lxc/auto/${hostname}_${service_name}.config"]

  }


}