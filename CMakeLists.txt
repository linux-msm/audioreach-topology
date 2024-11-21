# SPDX-License-Identifier: BSD-3-Clause
# With inspiration from SoF
cmake_minimum_required(VERSION 3.10)
# Array of "input-file-name;output-file-name;"
set(TPLGS
	"Qualcomm-RB5-WSA8815-Speakers-DMIC0\;Qualcomm-RB5-WSA8815-Speakers-DMIC0\;qcom/sm8250\;"
	"Qualcomm-RB5-WSA8815-Speakers-DMIC0-compress\;Qualcomm-RB5-WSA8815-Speakers-DMIC0-compress\;qcom/sm8250\;"
	"SM8250-MTP-WCD9380-WSA8810-VA-DMIC\;SM8250-MTP-WCD9380-WSA8810-VA-DMIC\;qcom/sm8250\;"
	"SM8450-HDK\;SM8450-HDK\;qcom/sm8450\;"
	"SM8550-HDK\;SM8550-HDK\;qcom/sm8550\;"
	"SM8550-QRD\;SM8550-QRD\;qcom/sm8550\;"
	"SM8650-QRD\;SM8650-QRD\;qcom/sm8650\;"
	"SM8650-MTP\;SM8650-MTP\;qcom/sm8650\;"
	"SC8280XP-LENOVO-X13S\;audioreach\;qcom/sc8280xp/LENOVO/21BX\;"
	"Google-SC7180-WSA-Speakers-SEC-I2S-VA-DMIC-WCD-TX3\;Google-SC7180-WSA-Speakers-SEC-I2S-VA-DMIC-WCD-TX3\;qcom/sc7180\;"
	"X1E80100-CRD\;X1E80100-CRD\;qcom/x1e80100\;"
	"X1E80100-LENOVO-Thinkpad-T14s\;X1E80100-LENOVO-Thinkpad-T14s\;qcom/x1e80100/LENOVO/21N1\;"
	"X1E80100-LENOVO-Yoga-Slim7x\;X1E80100-LENOVO-Yoga-Slim7x\;qcom/x1e80100/LENOVO/83ED\;"
)

add_custom_target(topologies ALL)

foreach(tplg ${TPLGS})
	list(GET tplg 0 input)
	list(GET tplg 1 output)
	list(GET tplg 2 outputdir)

	add_custom_command(
		OUTPUT  ${CMAKE_CURRENT_BINARY_DIR}/${outputdir}/${output}.conf
		COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/${outputdir}
		COMMAND m4 -I ${CMAKE_CURRENT_BINARY_DIR}
			-I ${CMAKE_CURRENT_SOURCE_DIR}
			 ${CMAKE_CURRENT_SOURCE_DIR}/${input}.m4
			 > ${CMAKE_CURRENT_BINARY_DIR}/${outputdir}/${output}.conf
		DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${input}.m4
		VERBATIM
		USES_TERMINAL
	)
	add_custom_command(
		OUTPUT  ${CMAKE_CURRENT_BINARY_DIR}/${output}-tplg.bin
		COMMAND alsatplg -c ${CMAKE_CURRENT_BINARY_DIR}/${outputdir}/${output}.conf -o ${CMAKE_CURRENT_BINARY_DIR}/${outputdir}/${output}-tplg.bin
		DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${outputdir}/${output}.conf
		VERBATIM
		USES_TERMINAL
	)

	add_custom_target(topology_${output} DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${output}-tplg.bin)
        add_dependencies(topologies topology_${output})
endforeach()
