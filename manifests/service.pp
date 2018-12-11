class lxc::service inherits lxc {
  
  service { lxc:
    enable => true,
    ensure => running,
  }
  Package["lxc"] -> Service[lxc]
  Mount["/sys/fs/cgroup"] -> Service[lxc]
    
}