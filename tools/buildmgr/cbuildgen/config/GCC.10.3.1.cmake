# This file maps the CMSIS project options to toolchain settings.
#
#   - Applies to toolchain: GNU Toolchain for the Arm Architecture 10.3.1 and greater

############### EDIT BELOW ###############
# Set base directory of toolchain
set(TOOLCHAIN_ROOT)
set(TOOLCHAIN_VERSION "10.3.1")

############ DO NOT EDIT BELOW ###########

set(AS "as")
set(CC "gcc")
set(CXX "g++")
set(CPP "gcc")
set(OC "objcopy")

if(DEFINED REGISTERED_TOOLCHAIN_ROOT)
  set(TOOLCHAIN_ROOT "${REGISTERED_TOOLCHAIN_ROOT}")
endif()
if(DEFINED REGISTERED_TOOLCHAIN_VERSION)
  set(TOOLCHAIN_VERSION "${REGISTERED_TOOLCHAIN_VERSION}")
endif()

if(DEFINED TOOLCHAIN_ROOT)
  set(PREFIX arm-none-eabi-)
  set(EXT)
  set(AS ${TOOLCHAIN_ROOT}/${PREFIX}${AS}${EXT})
  set(CC ${TOOLCHAIN_ROOT}/${PREFIX}${CC}${EXT})
  set(CXX ${TOOLCHAIN_ROOT}/${PREFIX}${CXX}${EXT})
  set(CPP ${TOOLCHAIN_ROOT}/${PREFIX}${CPP}${EXT})
  set(OC ${TOOLCHAIN_ROOT}/${PREFIX}${OC}${EXT})
endif()

# Helpers

function(cbuild_set_defines lang defines)
  set(TMP_DEFINES)
  foreach(DEFINE ${${defines}})
    string(REPLACE "\"" "\\\"" ENTRY ${DEFINE})
    string(REGEX REPLACE "=.*" "" KEY ${ENTRY})
    if (KEY STREQUAL ENTRY)
      set(VALUE "1")
    else()
      string(REGEX REPLACE ".*=" "" VALUE ${ENTRY})
    endif()
    if(${lang} STREQUAL "AS_LEG")
      string(APPEND TMP_DEFINES "--defsym ${KEY}=${VALUE} ")
    elseif(${lang} STREQUAL "AS_GNU")
      string(APPEND TMP_DEFINES "-Wa,-defsym,\"${KEY}=${VALUE}\" ")
    else()
      string(APPEND TMP_DEFINES "-D${ENTRY} ")
    endif()
  endforeach()
  set(${defines} ${TMP_DEFINES} PARENT_SCOPE)
endfunction()

set(OPTIMIZE_VALUES       "debug" "none" "balanced" "size" "speed")
set(OPTIMIZE_CC_FLAGS     "-Og"   "-O0"  "-O2"      "-Os" "-O3")
set(OPTIMIZE_AS_GNU_FLAGS ${OPTIMIZE_CC_FLAGS})
set(OPTIMIZE_ASM_FLAGS    ${OPTIMIZE_CC_FLAGS})
set(OPTIMIZE_CXX_FLAGS    ${OPTIMIZE_CC_FLAGS})
set(OPTIMIZE_LD_FLAGS     ${OPTIMIZE_CC_FLAGS})

set(DEBUG_VALUES          "on"      "off")
set(DEBUG_CC_FLAGS        "-g3"     "-g0")
set(DEBUG_CXX_FLAGS       ${DEBUG_CC_FLAGS})
set(DEBUG_LD_FLAGS        ${DEBUG_CC_FLAGS})
set(DEBUG_AS_GNU_FLAGS    ${DEBUG_CC_FLAGS})
set(DEBUG_ASM_FLAGS       ${DEBUG_CC_FLAGS})

set(WARNINGS_VALUES       "on"     "off")
set(WARNINGS_AS_LEG_FLAGS "--warn" "--no-warn")
set(WARNINGS_CC_FLAGS     ""       "-w")
set(WARNINGS_ASM_FLAGS    ""       "-w")
set(WARNINGS_AS_GNU_FLAGS ""       "-w")
set(WARNINGS_CXX_FLAGS    ""       "-w")
set(WARNINGS_LD_FLAGS     ""       "-w")

function(cbuild_set_option_flags lang option value flags)
  if(NOT DEFINED ${option}_${lang}_FLAGS)
    return()
  endif()
  list(FIND ${option}_VALUES "${value}" _index)
  if (${_index} GREATER -1)
    list(GET ${option}_${lang}_FLAGS ${_index} flag)
    set(${flags} "${flag} ${${flags}}" PARENT_SCOPE)
  elseif(NOT value STREQUAL "")
    string(TOLOWER "${option}" _option)
    message(FATAL_ERROR "unkown '${_option}' value '${value}' !")
  endif()
endfunction()

function(cbuild_set_options_flags lang optimize debug warnings flags)
  set(opt_flags)
  # GCC provide a better optimization level for debug
  if ((debug STREQUAL "on") AND (optimize STREQUAL ""))
    set(optimize "debug")
  endif()
  cbuild_set_option_flags(${lang} OPTIMIZE "${optimize}" opt_flags)
  cbuild_set_option_flags(${lang} DEBUG    "${debug}"    opt_flags)
  cbuild_set_option_flags(${lang} WARNINGS "${warnings}" opt_flags)
  set(${flags} "${opt_flags} ${${flags}}" PARENT_SCOPE)
endfunction()

# Assembler

if(CPU STREQUAL "Cortex-M0")
  set(GNUASM_CPU "-mcpu=cortex-m0")
elseif(CPU STREQUAL "Cortex-M0+")
  set(GNUASM_CPU "-mcpu=cortex-m0plus")
elseif(CPU STREQUAL "Cortex-M1")
  set(GNUASM_CPU "-mcpu=cortex-m1")
elseif(CPU STREQUAL "Cortex-M3")
  set(GNUASM_CPU "-mcpu=cortex-m3")
elseif(CPU STREQUAL "Cortex-M4")
  if(FPU STREQUAL "SP_FPU")
    set(GNUASM_CPU "-mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard")
  else()
    set(GNUASM_CPU "-mcpu=cortex-m4")
  endif()
elseif(CPU STREQUAL "Cortex-M7")
  if(FPU STREQUAL "DP_FPU")
    set(GNUASM_CPU "-mcpu=cortex-m7 -mfpu=fpv5-d16 -mfloat-abi=hard")
  elseif(FPU STREQUAL "SP_FPU")
    set(GNUASM_CPU "-mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=hard")
  else()
    set(GNUASM_CPU "-mcpu=cortex-m7")
  endif()
elseif(CPU STREQUAL "Cortex-M23")
  set(GNUASM_CPU "-mcpu=cortex-m23")
elseif(CPU STREQUAL "Cortex-M33")
  if(FPU STREQUAL "SP_FPU")
    if(DSP STREQUAL "DSP")
      set(GNUASM_CPU "-mcpu=cortex-m33 -mfpu=fpv5-sp-d16 -mfloat-abi=hard")
    else()
      set(GNUASM_CPU "-mcpu=cortex-m33+nodsp -mfpu=fpv5-sp-d16 -mfloat-abi=hard")
    endif()
  else()
    if(DSP STREQUAL "DSP")
      set(GNUASM_CPU "-mcpu=cortex-m33")
    else()
      set(GNUASM_CPU "-mcpu=cortex-m33+nodsp")
    endif()
  endif()
elseif(CPU STREQUAL "Cortex-M35P")
  if(FPU STREQUAL "SP_FPU")
    if(DSP STREQUAL "DSP")
      set(GNUASM_CPU "-mcpu=cortex-m35p -mfpu=fpv5-sp-d16 -mfloat-abi=hard")
    else()
      set(GNUASM_CPU "-mcpu=cortex-m35p+nodsp -mfpu=fpv5-sp-d16 -mfloat-abi=hard")
    endif()
  else()
    if(DSP STREQUAL "DSP")
      set(GNUASM_CPU "-mcpu=cortex-m35p")
    else()
      set(GNUASM_CPU "-mcpu=cortex-m35p+nodsp")
    endif()
  endif()
elseif(CPU STREQUAL "Cortex-M55")
  if(FPU STREQUAL "NO_FPU")
    if(MVE STREQUAL "NO_MVE")
      set(GNUASM_CPU "-mcpu=cortex-m55+nofp+nomve")
    else()
      set(GNUASM_CPU "-mcpu=cortex-m55+nofp")
    endif()
  else()
    if(MVE STREQUAL "NO_MVE")
      set(GNUASM_CPU "-mcpu=cortex-m55+nomve -mfloat-abi=hard")
    elseif(MVE STREQUAL "MVE")
      set(GNUASM_CPU "-mcpu=cortex-m55+nomve.fp -mfloat-abi=hard")
    else()
      set(GNUASM_CPU "-mcpu=cortex-m55 -mfloat-abi=hard")
    endif()
  endif()
elseif(CPU STREQUAL "Cortex-M85")
  if(FPU STREQUAL "NO_FPU")
    if(MVE STREQUAL "NO_MVE")
      set(GNUASM_CPU "-mcpu=cortex-m85+nofp+nomve")
    else()
      set(GNUASM_CPU "-mcpu=cortex-m85+nofp")
    endif()
  else()
    if(MVE STREQUAL "NO_MVE")
      set(GNUASM_CPU "-mcpu=cortex-m85+nomve -mfloat-abi=hard")
    elseif(MVE STREQUAL "MVE")
      set(GNUASM_CPU "-mcpu=cortex-m85+nomve.fp -mfloat-abi=hard")
    else()
      set(GNUASM_CPU "-mcpu=cortex-m85 -mfloat-abi=hard")
    endif()
  endif()
elseif(CPU STREQUAL "Cortex-A5")
  if(FPU STREQUAL "DP_FPU")
    set(GNUASM_CPU "-mcpu=cortex-a5+nosimd -mfpu=auto -mfloat-abi=hard")
  else()
    set(GNUASM_CPU "-mcpu=cortex-a5+nosimd+nofp")
  endif()
elseif(CPU STREQUAL "Cortex-A7")
  if(FPU STREQUAL "DP_FPU")
    set(GNUASM_CPU "-mcpu=cortex-a7+nosimd -mfpu=auto -mfloat-abi=hard")
  else()
    set(GNUASM_CPU "-mcpu=Cortex-a7+nosimd+nofp")
  endif()
elseif(CPU STREQUAL "Cortex-A9")
  if(FPU STREQUAL "DP_FPU")
    set(GNUASM_CPU "-mcpu=cortex-a9+nosimd -mfpu=auto -mfloat-abi=hard")
  else()
    set(GNUASM_CPU "-mcpu=cortex-a9+nosimd+nofp")
  endif()
endif()
if(NOT DEFINED GNUASM_CPU)
  message(FATAL_ERROR "Error: CPU is not supported!")
endif()

# Supported Assembly Variants:
#   AS_LEG: gas
#   AS_GNU: gcc + GNU syntax
#   ASM: gcc + pre-processing

set(AS_LEG_CPU ${GNUASM_CPU})
set(AS_GNU_CPU ${GNUASM_CPU})
set(ASM_CPU ${GNUASM_CPU})

set(AS_LEG_FLAGS)
set(AS_GNU_FLAGS "-c")
set(ASM_FLAGS "-c")

set(AS_LEG_DEFINES ${DEFINES})
cbuild_set_defines(AS_LEG AS_LEG_DEFINES)
set(AS_GNU_DEFINES ${DEFINES})
cbuild_set_defines(AS_GNU AS_GNU_DEFINES)
set(ASM_DEFINES ${DEFINES})
cbuild_set_defines(ASM ASM_DEFINES)

set(AS_LEG_OPTIONS_FLAGS)
cbuild_set_options_flags(AS_LEG "${OPTIMIZE}" "${DEBUG}" "${WARNINGS}" AS_LEG_OPTIONS_FLAGS)
set(AS_GNU_OPTIONS_FLAGS)
cbuild_set_options_flags(AS_GNU "${OPTIMIZE}" "${DEBUG}" "${WARNINGS}" AS_GNU_OPTIONS_FLAGS)
set(ASM_OPTIONS_FLAGS)
cbuild_set_options_flags(ASM "${OPTIMIZE}" "${DEBUG}" "${WARNINGS}" ASM_OPTIONS_FLAGS)

if(BYTE_ORDER STREQUAL "Little-endian")
  set(ASM_BYTE_ORDER "-mlittle-endian")
elseif(BYTE_ORDER STREQUAL "Big-endian")
  set(ASM_BYTE_ORDER "-mbig-endian")
endif()
set(AS_LEG_BYTE_ORDER "${AS_BYTE_ORDER}")
set(AS_GNU_BYTE_ORDER "${AS_BYTE_ORDER}")

# C Pre-Processor

set(CPP_FLAGS "-E -P -xc")
set(CPP_ARGS_LD_SCRIPT "${CPP_FLAGS} -include \"${LD_REGIONS}\" \"${LD_SCRIPT}\" -o \"${LD_SCRIPT_PP}\"")
separate_arguments(CPP_ARGS_LD_SCRIPT NATIVE_COMMAND ${CPP_ARGS_LD_SCRIPT})

# C Compiler

set(CC_CPU "${GNUASM_CPU}")
set(CC_DEFINES ${ASM_DEFINES})
set(CC_BYTE_ORDER ${ASM_BYTE_ORDER})
set(CC_FLAGS)
set(_PI "-include ")
set(_ISYS "-isystem ")
set(CC_OPTIONS_FLAGS)
cbuild_set_options_flags(CC "${OPTIMIZE}" "${DEBUG}" "${WARNINGS}" CC_OPTIONS_FLAGS)

if(SECURE STREQUAL "Secure")
  set(CC_SECURE "-mcmse")
else()
  set(CC_SECURE "")
endif()

if(BRANCHPROT STREQUAL "NO_BRANCHPROT")
  set(CC_BRANCHPROT "-mbranch-protection=none")
elseif(BRANCHPROT STREQUAL "BTI")
  set(CC_BRANCHPROT "-mbranch-protection=bti")
elseif(BRANCHPROT STREQUAL "BTI_SIGNRET")
  set(CC_BRANCHPROT "-mbranch-protection=bti+pac-ret")
endif()

set (CC_SYS_INC_PATHS_LIST
  "$\{TOOLCHAIN_ROOT}/../lib/gcc/arm-none-eabi/\${TOOLCHAIN_VERSION}/include"
  "$\{TOOLCHAIN_ROOT}/../lib/gcc/arm-none-eabi/\${TOOLCHAIN_VERSION}/include-fixed"
  "$\{TOOLCHAIN_ROOT}/../arm-none-eabi/include"
)
function(cbuild_get_c_system_includes includes)
  cbuild_get_system_includes(CC_SYS_INC_PATHS_LIST ${includes})
  set(${includes} ${${includes}} PARENT_SCOPE)
endfunction()

# C++ Compiler

set(CXX_CPU "${CC_CPU}")
set(CXX_DEFINES "${CC_DEFINES}")
set(CXX_BYTE_ORDER "${CC_BYTE_ORDER}")
set(CXX_SECURE "${CC_SECURE}")
set(CXX_BRANCHPROT "${CC_BRANCHPROT}")
set(CXX_FLAGS "${CC_FLAGS}")
set(CXX_OPTIONS_FLAGS)
cbuild_set_options_flags(CXX "${OPTIMIZE}" "${DEBUG}" "${WARNINGS}" CXX_OPTIONS_FLAGS)

set (CXX_SYS_INC_PATHS_LIST
  "$\{TOOLCHAIN_ROOT}/../arm-none-eabi/include/c++/\${TOOLCHAIN_VERSION}"
  "$\{TOOLCHAIN_ROOT}/../arm-none-eabi/include/c++/\${TOOLCHAIN_VERSION}/arm-none-eabi"
  "$\{TOOLCHAIN_ROOT}/../arm-none-eabi/include/c++/\${TOOLCHAIN_VERSION}/backward"
  "${CC_SYS_INC_PATHS_LIST}"
)
function(cbuild_get_cxx_system_includes includes)
  cbuild_get_system_includes(CXX_SYS_INC_PATHS_LIST ${includes})
  set(${includes} ${${includes}} PARENT_SCOPE)
endfunction()

# Linker

set(LD_CPU ${GNUASM_CPU})
set(_LS "-T ")

if(SECURE STREQUAL "Secure")
  set(LD_SECURE "-Wl,--cmse-implib -Wl,--out-implib=\"${OUT_DIR}/${OUT_NAME}_CMSE_Lib.o\"")
endif()

set(LD_FLAGS)
set(LD_OPTIONS_FLAGS)
cbuild_set_options_flags(LD "${OPTIMIZE}" "${DEBUG}" "${WARNINGS}" LD_OPTIONS_FLAGS)

# Target Output

set (LIB_PREFIX "lib")
set (LIB_SUFFIX ".a")
set (EXE_SUFFIX ".elf")

# ELF to HEX conversion
set (ELF2HEX -O ihex "${OUT_DIR}/$<TARGET_PROPERTY:${TARGET},OUTPUT_NAME>$<TARGET_PROPERTY:${TARGET},SUFFIX>" "${OUT_DIR}/${HEX_FILE}")

# ELF to BIN conversion
set (ELF2BIN -O binary "${OUT_DIR}/$<TARGET_PROPERTY:${TARGET},OUTPUT_NAME>$<TARGET_PROPERTY:${TARGET},SUFFIX>" "${OUT_DIR}/${BIN_FILE}")

# Set CMake variables for toolchain initialization
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_CROSSCOMPILING TRUE)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_ASM_COMPILER "${CC}")
set(CMAKE_AS_LEG_COMPILER "${AS}")
set(CMAKE_AS_GNU_COMPILER "${CC}")
set(CMAKE_C_COMPILER "${CC}")
set(CMAKE_CXX_COMPILER "${CXX}")
set(CMAKE_OBJCOPY "${OC}")
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/CMakeASM")
