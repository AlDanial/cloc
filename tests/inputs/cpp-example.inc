#
# Copyright OpenEmbedded Contributors
#
# SPDX-License-Identifier: MIT
#

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS += "json-c"

PV = "1.0"

SRC_URI = "\
    file://cpp-example.cpp \
    file://cpp-example-lib.hpp \
    file://cpp-example-lib.cpp \
    file://test-cpp-example.cpp \
    file://run-ptest \
"

S = "${WORKDIR}"

inherit ptest
