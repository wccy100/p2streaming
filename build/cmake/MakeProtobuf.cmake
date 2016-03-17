IF(MSVC)
	  UNSET(PROTOBUF_SLN CACHE)
	  UNSET(PROTOBUF_VSPROJECTS_DIR CACHE)
	  FIND_FILE(PROTOBUF_SLN NAMES protobuf.sln PATHS ${PROTOBUF_SOURCE_DIR}/vsprojects NO_DEFAULT_PATH)
	  IF(NOT PROTOBUF_SLN)
		SET(ERROR_MESSAGE "\nCould not find Google Protocol Buffers source.\n")
		SET(ERROR_MESSAGE "${ERROR_MESSAGE}Using -DPROTOBUF_SOURCE_DIR=\"the protobuf source\".")
		SET(ERROR_MESSAGE "${ERROR_MESSAGE}You can download it at http://code.google.com/p/protobuf\n")
		MESSAGE(FATAL_ERROR "${ERROR_MESSAGE}")
	  ENDIF()
	  GET_FILENAME_COMPONENT(PROTOBUF_VSPROJECTS_DIR ${PROTOBUF_SLN} PATH)
	  MESSAGE("-- Upgrading Google Protocol Buffers solution")
	  EXECUTE_PROCESS(COMMAND devenv ${PROTOBUF_SLN} /Upgrade OUTPUT_VARIABLE OUTVAR RESULT_VARIABLE RESVAR)
	  IF(NOT ${RESVAR} EQUAL 0)
		MESSAGE("${OUTVAR}")
	  ENDIF()
	  MESSAGE("-- Building Google Protocol Buffers debug libraries")
	  EXECUTE_PROCESS(COMMAND devenv ${PROTOBUF_SLN} /Build "Debug|Win32" /Project libprotobuf OUTPUT_VARIABLE OUTVAR RESULT_VARIABLE RESVAR)
	  IF(NOT ${RESVAR} EQUAL 0)
		MESSAGE("${OUTVAR}")
	  ENDIF()
		MESSAGE("-- Building Google Protocol Buffers release libraries and compiler")
	  EXECUTE_PROCESS(COMMAND devenv ${PROTOBUF_SLN} /Build "Release|Win32" /Project protoc OUTPUT_VARIABLE OUTVAR RESULT_VARIABLE RESVAR)
	  IF(NOT ${RESVAR} EQUAL 0)
		MESSAGE("${OUTVAR}")
	  ENDIF()
	  EXECUTE_PROCESS(COMMAND CMD /C CALL extract_includes.bat WORKING_DIRECTORY ${PROTOBUF_VSPROJECTS_DIR} OUTPUT_VARIABLE OUTVAR RESULT_VARIABLE RESVAR)
	  IF(NOT ${RESVAR} EQUAL 0)
		MESSAGE("${OUTVAR}")
	  ENDIF()
	  GET_FILENAME_COMPONENT(PROTOBUF_ROOT_DIR ${PROTOBUF_VSPROJECTS_DIR} PATH)
ELSE()
	  UNSET(PROTOBUF_CONFIGURE CACHE)
	  SET(PROTOBUF_SRC_DIR ${PROTOBUF_SOURCE_DIR})
	  FIND_FILE(PROTOBUF_MESSAGE src/google/protobuf/message.h PATHS ${PROTOBUF_SRC_DIR} NO_DEFAULT_PATH)
	  IF(NOT PROTOBUF_MESSAGE)
		SET(ERROR_MESSAGE "\nCould not find Google Protocol Buffers source.\n")
		SET(ERROR_MESSAGE "${ERROR_MESSAGE} Using -DPROTOBUF_SOURCE_DIR=\"the protobuf source\".")
		SET(ERROR_MESSAGE "${ERROR_MESSAGE} You can download it at http://code.google.com/p/protobuf\n")
		MESSAGE(FATAL_ERROR "${ERROR_MESSAGE}")
	  ENDIF()

	if(PROTOBUF_SRC_DIR)
		MESSAGE("-- Generating configure file for Google Protocol Buffers")
	
		set(PROTOBUF_SRC_PATH_DESCRIPTION "The Directory containing the protobuf src files was not found. Please Use cmake -DPROTOBUF_SOURCE_DIR=\"your_boost_dir\" ...")  
		
		if(MSVC)
			set(PROTOBUF_LITE_LIB libprotobuf-lite.lib)
		else()
			set(PROTOBUF_LITE_LIB libprotobuf-lite.a)
		endif(MSVC)
		find_path(PROTOBUF_LIB_DIR ${PROTOBUF_LITE_LIB}
		      ${PREFIX}/lib
			NO_DEFAULT_PATH
		  )
	     MESSAGE("PROTOBUF_LIB_DIR:"${PROTOBUF_LIB_DIR})
		 MESSAGE("     This may take a few minutes...")
		if(NOT PROTOBUF_LIB_DIR)
			execute_process(COMMAND make distclean WORKING_DIRECTORY ${PROTOBUF_SRC_DIR})
			if(${CMAKE_C_COMPILER} EQUAL gcc)
				execute_process(COMMAND ${PROTOBUF_SRC_DIR}/configure 
					--prefix=${PREFIX}
					 WORKING_DIRECTORY ${PROTOBUF_SRC_DIR}
				) 
			else(${CMAKE_C_COMPILER} EQUAL gcc)
				execute_process(COMMAND ${PROTOBUF_SRC_DIR}/configure 
					CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER}
					--host=${PLATFORM} --prefix=${PREFIX}
					--with-protoc=protoc
					 WORKING_DIRECTORY ${PROTOBUF_SRC_DIR}
				) 
			endif(${CMAKE_C_COMPILER} EQUAL gcc)
			execute_process(COMMAND make  WORKING_DIRECTORY ${PROTOBUF_SRC_DIR}) 		
			execute_process(COMMAND make install WORKING_DIRECTORY ${PROTOBUF_SRC_DIR}) 
		endif()
	else(PROTOBUF_SRC_DIR)
		message(SEND_ERROR ${PROTOBUF_SRC_PATH_DESCRIPTION})
	endif(PROTOBUF_SRC_DIR)
ENDIF()