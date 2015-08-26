include hadoop

group { "puppet":
  ensure => "present",
}
 
exec { "apt-get update":
    command => "/usr/bin/apt-get update",
}

package { "openjdk-6-jdk" :
  ensure => present,
  require => Exec['apt-get update']
}

file {"/root/.ssh":
	ensure => "directory",
}

file {
  "/root/.ssh/id_rsa":
  source => "puppet:///modules/hadoop/id_rsa",
  mode => 600,
  owner => root,
  group => root,
  require => Exec['apt-get update']
 }
 
file {
  "/root/.ssh/id_rsa.pub":
  source => "puppet:///modules/hadoop/id_rsa.pub",
  mode => 644,
  owner => root,
  group => root,
  require => Exec['apt-get update']
 }

ssh_authorized_key { "ssh_key":
    ensure => "present",
    key    => "AAAAB3NzaC1yc2EAAAADAQABAAACAQC1crIbWQP3TRapTLmZh+kmMbHxndnH+yZx4h71C3Zz92saYHefVoKbIFh86iSTOE+Cc6zRmkqy2qZd9duEScUPaG6vm1oGMC87xiqJXFB5DpRUfIIaipJb4Gq3FT0PA3k9BD0lsOH2FRnPADZaQNygEjTmd4NOWfQl18tyakaO3qF8g0KxDeSCIlL8T/x5mfKz/P8UAjD63fLuRVNEle3Xb3QaLQCRBSqyDKW4Z8AZf1unihkmDF0a6/7RIJjSxEG54CyfSFaD3UDuGuKXDjJOrXK4ll51K72+zIQSsf1vEmKIqvkltmqkXofnFqilzQoYpLhE0fgUYKF00HKxeRQuD9NFSBvo4B2BdZ0xkT1R8iGZgIZywaJr3s3vG5hnBKJoNoewBTMcrw+jC0YBmgatoZ4DDVXoEQWcI+zd6IIzpNif5J0LzoLUwuBda58m9vNssPcMZoMBC90+GDg99ySo521zbyACDslG/FzecnYeg9LUenOGr0/T6kxcAYUxqWj/gZS1w6jw0KwI1LRwacgOZKCp52DpjBod4Q2XHR6THryxuGwH+J258R/eOOvix04B2FOEYyGIv5hqDtvALlF5LPeVnrXzZgTrDLP4P9HeCJJh4mU4XDVERxb3K5x8ECEJey3XVuHK2wfjFkCcpYwya6A/UfrR2vCWn7rROQ9sjQ==",
    type   => "ssh-rsa",
    user   => "root",
    require => File['/root/.ssh/id_rsa.pub']
}


host { 'master':
    ip => "192.168.1.10",
}

host { 'slave-1':
    ip => "192.168.1.11",
}

host { 'slave-2':
    ip => "192.168.1.12",
}