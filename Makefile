BUILD_DIR = bin
SOURCE_DIR = src
EXT_LIBS = libs
JAVA_BIN = java
JAVAC_BIN = javac

all: clean build ${BUILD_DIR}/EmptyTemplate.class ${BUILD_DIR}/project.clp
	$(JAVA_BIN) -ea -cp "$(EXT_LIBS)/*:${BUILD_DIR}" "app/Main"

clean:
	rm -rf "$(BUILD_DIR)/"

help:
	@echo "make clean      - to clean up the build process"
	@echo "make fname.java - to compile and run specific JAVA code"
	@echo "make fname.clp  - to compile and run specific CLIPS file"
	@echo "make zip        - to compress the project into single zip file"

zip:
	rm -rf "compress.zip"
	zip "compress.zip" -r "${BUILD_DIR}" "${SOURCE_DIR}" "${EXT_LIBS}" ".editorconfig" "Makefile"

.PHONY: all clean help zip   build

.PRECIOUS: ${BUILD_DIR}/%.class ${BUILD_DIR}/%.clp

%.java: ${BUILD_DIR}/%.clp ${BUILD_DIR}/%.class
	$(JAVA_BIN) -ea -cp "$(EXT_LIBS)/*:${BUILD_DIR}" "$(basename ${@})"

%.clp: ${BUILD_DIR}/%.clp
	$(JAVA_BIN) -ea -cp "$(EXT_LIBS)/*:${BUILD_DIR}" "jess.Main" "${@}"

# ==============================================================================
# additional recipes

build:
	mkdir -p "$(BUILD_DIR)/"

${BUILD_DIR}/%.class: ${SOURCE_DIR}/%.java build
	$(JAVAC_BIN) -cp "$(EXT_LIBS)/*:${SOURCE_DIR}" -d "$(BUILD_DIR)/" "${<}"

${BUILD_DIR}/%.clp: ${SOURCE_DIR}/%.clp build
	cp "${<}" "${@}"

# ==============================================================================
