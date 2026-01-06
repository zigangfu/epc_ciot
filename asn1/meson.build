srslte_asn1_srcs = files([
  'liblte_common.cc',
  'liblte_mme.cc',
  'gtpc.cc'
])

srslte_asn1 = static_library('srslte_asn1', srslte_asn1_srcs,
  include_directories : srsepc_ciot_inc
)

srslte_asn1_utils = static_library('srslte_asn1_utils', 'asn1_utils.cc',
  include_directories : srsepc_ciot_inc,
  cpp_args : ['-Os'],
  link_with : srslte_common
)

srslte_s1ap_asn1 = static_library('srslte_s1ap_asn1', 's1ap_asn1.cc',
  include_directories : srsepc_ciot_inc,
  cpp_args : ['-Os'],
  link_with : [srslte_common, srslte_asn1_utils]
)
