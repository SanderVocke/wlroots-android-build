project('posix-shm', 'c',
  version : '0.1',
  license : 'Unknown')

posix_shm_lib = shared_library('posix-shm',
                            ['termux-extra-packages/packages/libposix-shm/posix-shm.c',
                             'termux-extra-packages/packages/libposix-shm/posix-shm.h'],
                            version : get_option('posix_shm_version'),
                            install : true)
install_headers('termux-extra-packages/packages/libposix-shm/posix-shm.h')

pkgconfig = import('pkgconfig')
pkgconfig.generate(
	libraries: posix_shm_lib,
	version: get_option('posix_shm_version'),
	filebase: meson.project_name(),
	name: meson.project_name(),
	description: 'POSIX-style SHM for Android (from Termux packages)',
)