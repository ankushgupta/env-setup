# Class: jenkins::install

class jenkins::install {
  include repos::jenkins
  include java::sun_jdk

  package { 'jenkins':
    ensure  =>  'present',
    require => [Class['repos::jenkins'],
                Class['java::sun_jdk']]
  }
}