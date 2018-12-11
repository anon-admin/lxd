class lxc::clean inherits lxc {
  tidy { ["/usr/tidy/var/cache/lxc", "/usr/tidy/etc/lxc", "/usr/tidy/var/lib/lxc"]:
    recurse => true,
    backup  => false,
    age     => "4w",
    require => Mount["/usr/tidy"],
  }

  Mount["/etc/lxc"] -> Tidy["/usr/tidy/etc/lxc"]
  Mount["/var/cache/lxc"] -> Tidy["/usr/tidy/var/cache/lxc"]
  Mount["/var/lib/lxc"] -> Tidy["/usr/tidy/var/lib/lxc"]
}
