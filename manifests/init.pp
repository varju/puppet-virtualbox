class virtualbox {
  package { 'VirtualBox-4.2.10':
    provider => 'pkgdmg',
    source   => 'http://download.virtualbox.org/virtualbox/4.2.10/VirtualBox-4.2.10-84104-OSX.dmg'
  }
}

class virtualbox::extensions {
  virtualbox::extension { 'extpack':
    source   => 'http://download.virtualbox.org/virtualbox/4.2.10/Oracle_VM_VirtualBox_Extension_Pack-4.2.10-84104.vbox-extpack',
    creates  => '/Applications/VirtualBox.app/Contents/MacOS/ExtensionPacks/Oracle_VM_VirtualBox_Extension_Pack/ExtPack.xml',
    require  => Package['VirtualBox-4.2.10']
  }
}

define virtualbox::extension($source, $creates) {
  $clean_source = strip($source)
  $basename = inline_template('<%= File.basename(clean_source) %>')

  Exec {
    creates => $creates
  }

  exec {
    "extension-download-${name}":
      command => "/usr/bin/curl -L ${clean_source} > '/tmp/$basename'",
      notify  => Exec["extension-install-${name}"];
    "extension-install-${name}":
      command     => "VBoxManage extpack install '/tmp/$basename'",
      user        => 'root',
      require     => Exec["extension-download-${name}"];
  }
}
