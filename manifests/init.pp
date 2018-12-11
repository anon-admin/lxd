# Class: lxc
#
# This module manages lxc
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class lxc(
  $lxc_dir,
  $lxc_mountpoint,
  $lxc_lvname,
  $lxc_vgname,
  $lxc_tpsize,
  $lxc_container_size,
  $lxc_lvsize,
  $lxc_lvfs
) {

  $lxc_pkgname = "lxc"

  contain lxc::config

  file { ["/var/cache/lxc", "/etc/lxc", "/etc/lxc/lxc.conf", "/etc/default/lxc.conf", "${lxc_dir}"]: }

  define fstab_has_line ($vgname = $lxc::lxc_vgname) {
    $service_fstab_content = $name
    $service_fstab_content_array = split($service_fstab_content, ":")
    $service_name = $service_fstab_content_array[0]
    $fstab_content = $service_fstab_content_array[1]

    $lxc_dir = $lxc::lxc_dir
    $lxc_service_name = "${hostname}_${service_name}"
    $lxc_service_dir = "${lxc_dir}/${lxc_service_name}"
    $lxc_service_preconfig = "${lxc_service_dir}.config"
    $lxc_service_config = "${lxc_service_dir}/config"

    exec { "echo \"${fstab_content}\" >>${lxc_dir}/fstab.${service_name}":
      provider => shell,
      unless   => "/bin/grep \"${fstab_content}\" ${lxc_dir}/fstab.${service_name}",
    }
    File["${lxc_dir}"] -> Exec["echo \"${fstab_content}\" >>${lxc_dir}/fstab.${service_name}"]
    Exec["echo \"${fstab_content}\" >>${lxc_dir}/fstab.${service_name}"] -> File["${lxc_dir}/fstab.${service_name}"]

  }



}
