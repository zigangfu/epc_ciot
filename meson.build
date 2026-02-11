project('epc_ciot', ['c', 'cpp'],
  default_options : ['buildtype=debug'])
add_global_arguments(language : ['c','cpp'])
add_global_arguments('-Wno-reorder', '-Wno-non-virtual-dtor', language : ['cpp'])

pthread = dependency('threads')

boost = dependency('boost', modules : ['program_options'])

# libsctp = dependency('libsctp')

# get host architecture
arch = host_machine.cpu_family()

# architecture specific virables
sctp_lib_dirs = []
extra_link_args = []
extra_include_dirs = []
toolchain_path = []
sysroot_path = []

if arch == 'aarch64'
  message('Configuring for ARM64 target')

  sctp_lib_dirs = [
    '/usr/lib64',
    '/usr/aarch64-linux-gnu/lib'
  ]
 
  add_project_arguments('-DARCH_ARM64', language: ['c', 'cpp'])
  
elif arch == 'x86_64'
  message('Configuring for x86_64 target')
  
  sctp_lib_dirs = [
    '/usr/lib64',
    '/usr/lib/x86_64-linux-gnu'
  ]
  
  add_project_arguments('-DARCH_X86_64', language: ['c', 'cpp'])
  
else
  error('Unsupported architecture: ' + arch)
endif

# get the ARM64 toolchain path
toolchain_path = run_command('printenv', 'PATH_TOOLCHAIN_AARCH64', check: false).stdout().strip()
message('  Toolchain: ' + toolchain_path)
if toolchain_path.contains('aarch64')
  message('Configuring for cross extra paths')

  sysroot_path = toolchain_path / 'aarch64-linux-gnu' / 'libc'

  sctp_lib_dirs = [
    sysroot_path / 'usr' / 'lib',
    '/usr/lib64',
    '/usr/aarch64-linux-gnu/lib'
  ]
  
  extra_link_args = [
    '-Wl,-rpath-link=' + (sysroot_path / 'usr' / 'lib')
  ]

  extra_include_dirs = [
    sysroot_path / 'usr' / 'include'
  ]

  message('  Toolchain: ' + toolchain_path)
  message('  Sysroot: ' + sysroot_path)
endif

# SCTP dependency
sctp_dep = dependency('sctp', required: false)
if not sctp_dep.found()
  sctp_lib = meson.get_compiler('c').find_library('sctp',
    dirs: sctp_lib_dirs,
    required: true
  )
  sctp_dep = declare_dependency(dependencies: sctp_lib)
endif

# add extra include paths
if extra_include_dirs.length() > 0
  extra_includes = include_directories(extra_include_dirs)
  add_project_arguments('-I' + extra_include_dirs[0], language: ['c', 'cpp'])
endif

message('')
message('Build configuration:')
message('  Architecture: ' + arch)
message('')

# MbedTLS libraries
mbedtls_libs = [
  'mbedtls',
  'mbedcrypto', 
  'mbedx509'
]

mbedtls_deps = []
mbedtls_dir = meson.current_source_dir() / 'third_party/mbedtls-install'
mbedtls_lib_dir = mbedtls_dir / 'lib'

# find all MbedTLS ralated libraries
foreach lib_name : mbedtls_libs
  lib = meson.get_compiler('c').find_library(lib_name,
    dirs: [mbedtls_lib_dir],
    required: true
  )
  mbedtls_deps += lib
endforeach

# add include paths
mbedtls_include = include_directories('./third_party/mbedtls-install/include')

# create a single dependency item
mbedtls_dep = declare_dependency(
  dependencies: mbedtls_deps,
  include_directories: mbedtls_include
)

add_global_arguments('-DHAVE_MBEDTLS', language : ['c','cpp'])

srsepc_ciot_inc = include_directories('.')

subdir('common')
subdir('mme')
subdir('hss')
subdir('spgw')
subdir('gtpu')
subdir('asn1')

epc = executable('epc_ciot', 'main.cc',
  include_directories : [srsepc_ciot_inc, mbedtls_include],
  link_with : [
    srsepc_mme,
    srsepc_hss,
    srsepc_spgw,
    srsepc_gtpu,
    srslte_asn1,
    srslte_asn1_utils,
    srslte_s1ap_asn1
  ],
  dependencies : [
    pthread,
    boost,
    sctp_dep,
    mbedtls_dep
  ]
)
