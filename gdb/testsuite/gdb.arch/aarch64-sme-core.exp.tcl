# Copyright (C) 2023 Free Software Foundation, Inc.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Exercise core file reading/writing in the presence of SME support.
# This test exercises GDB's dumping/loading capability for Linux
# Kernel core files and for gcore core files.

load_lib aarch64-scalable.exp

#
# Validate that CORE_FILENAME can be read correctly and that the register
# state is sane.
#
proc check_sme_core_file { core_filename state vl svl } {
    # Load the core file.
    if [gdb_test "core $core_filename" \
	[multi_line \
	    "Core was generated by.*\." \
	    "Program terminated with signal SIGSEGV, Segmentation fault\." \
	    "#0  ${::hex} in main \\(.*\\) at .*" \
	    ".*p = 0xff;.* crash point .*"] \
	    "load core file"] {
	untested "failed to generate core file"
	return -1
    }

    check_state $state $vl $svl

    # Check the value of TPIDR2 in the core file.
    gdb_test "print/x \$tpidr2" " = 0xffffffffffffffff" \
	     "tpidr2 contents from core file"
}

#
# Generate two core files for EXECUTABLE, BINFILE with a test id of ID.
# STATE is the register state, VL is the SVE vector length and SVL is the
# SME vector length.
# One of the core files is generated by the kernel and the other by the
# gcore command.
#
proc generate_sme_core_files { executable binfile id state vl svl} {
    # Run the program until the point where we need to adjust the
    # test id.
    set init_breakpoint "stop to initialize test_id"
    gdb_breakpoint [gdb_get_line_number $init_breakpoint]
    gdb_continue_to_breakpoint $init_breakpoint
    gdb_test_no_output "set test_id = $id"

    # Run the program until just before the crash.
    set crash_breakpoint "crash point"
    gdb_breakpoint [gdb_get_line_number $crash_breakpoint]
    gdb_continue_to_breakpoint $crash_breakpoint
    gdb_test_no_output "set print repeats 1" "adjust repeat count pre-crash"

    # Adjust the register to custom values that we will check later when
    # loading the core files.
    check_state $state $vl $svl

    # Continue until a crash.
    gdb_test "continue" \
	[multi_line \
	    "Program received signal SIGSEGV, Segmentation fault\." \
	    "${::hex} in main \\(.*\\) at .*" \
	    ".*p = 0xff;.* crash point .*"] \
	    "run to crash"

    # Generate the gcore core file.
    set gcore_filename [standard_output_file "${executable}-${id}-${state}-${vl}-${svl}.gcore"]
    set gcore_generated [gdb_gcore_cmd "$gcore_filename" "generate gcore file"]

    # Generate a native core file.
    set core_filename [core_find ${binfile} {} $id]
    set core_generated [expr {$core_filename != ""}]
    set native_core_name "${binfile}-${id}-${state}-${vl}-${svl}.core"
    remote_exec build "mv $core_filename ${native_core_name}"
    set core_filename ${native_core_name}

    # At this point we have a couple core files, the gcore one generated by GDB
    # and the native one generated by the Linux Kernel.  Make sure GDB can read
    # both correctly.
    if {$gcore_generated} {
	clean_restart ${binfile}
	gdb_test_no_output "set print repeats 1" \
	    "adjust repeat count post-crash gcore"

	with_test_prefix "gcore corefile" {
	    check_sme_core_file $gcore_filename $state $vl $svl
	}
    } else {
	fail "gcore corefile not generated"
    }

    if {$core_generated} {
	clean_restart ${binfile}

	gdb_test_no_output "set print repeats 1" \
	    "adjust repeat count post-crash native core"

	with_test_prefix "native corefile" {
	    check_sme_core_file $core_filename $state $vl $svl
	}
    } else {
	untested "native corefile not generated"
    }
}

#
# Exercise core file reading (kernel-generated core files) and writing
# (gcore command) for test id's ID_START through ID_END.
#
proc test_sme_core_file { id_start id_end } {
    set compile_flags {"debug" "macros" "additional_flags=-march=armv8.5-a+sve"}
    standard_testfile ${::srcdir}/${::subdir}/aarch64-sme-core.c
    set executable "${::testfile}"
    if {[prepare_for_testing "failed to prepare" ${executable} ${::srcfile} ${compile_flags}]} {
	return -1
    }
    set binfile [standard_output_file ${executable}]

    for {set id $id_start} {$id <= $id_end} {incr id} {
	set state [test_id_to_state $id]
	set vl [test_id_to_vl $id]
	set svl [test_id_to_svl $id]

	set skip_unsupported 0
	if {![aarch64_supports_sve_vl $vl]
	    || ![aarch64_supports_sme_svl $svl]} {
	    # We have a vector length or streaming vector length that
	    # is not supported by this target.  Skip to the next iteration
	    # since it is no use running tests for an unsupported vector
	    # length.
	    if {![aarch64_supports_sve_vl $vl]} {
		verbose -log "SVE vector length $vl not supported."
	    } elseif {![aarch64_supports_sme_svl $svl]} {
		verbose -log "SME streaming vector length $svl not supported."
	    }
	    verbose -log "Skipping test."
	    set skip_unsupported 1
	}

	with_test_prefix "state=${state} vl=${vl} svl=${svl}" {
	    # If the SVE or SME vector length is not supported, just skip
	    # these next tests.
	    if {$skip_unsupported} {
		untested "unsupported configuration on target"
		continue
	    }

	    if ![runto_main] {
		untested "could not run to main"
		return -1
	    }

	    # Check if we are talking to a remote target.  If so, bail out,
	    # as right now remote targets can't communicate vector length (vl
	    # or svl) changes to gdb via the RSP.  When this restriction is
	    # lifted, we can remove this guard.
	    if {[gdb_is_target_remote]} {
		unsupported "aarch64 sve/sme tests not supported for remote targets"
		return -1
	    }

	    generate_sme_core_files ${executable} ${binfile} $id $state $vl $svl
	}
    }
}

require is_aarch64_target
require allow_aarch64_sve_tests
require allow_aarch64_sme_tests

test_sme_core_file $id_start $id_end
