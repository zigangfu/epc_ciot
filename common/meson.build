sources = files([
  'arch_select.cc',
  'backtrace.c',
  'buffer_pool.cc',
  'crash_handler.c',
  'log_filter.cc',
  'logmap.cc',
  'logger_file.cc',
  'pcap.c',
  's1ap_pcap.cc',
  'threads.c',
  'security.cc',
  'liblte_security.cc',
  'zuc.cc',
  'snow_3g.cc'
])

srslte_common = static_library('srslte_common', sources,
  include_directories : [srsepc_ciot_inc, mbedtls_include],
  dependencies : [
    mbedtls_dep
  ]
)
