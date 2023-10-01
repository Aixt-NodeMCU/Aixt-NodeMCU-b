// Project Name: Aixt project, https://gitlab.com/fermarsan/aixt-project.git
// File Name: builder.v
// Author: Fernando Martínez Santa
// Date: 2023
// License: MIT
//
// Description: This file contains the functions to make a source code project in Aixt.

module aixt_build

import os
import toml
import v.ast
import v.pref
import aixt_cgen

pub fn transpile_file(path string, setup_file toml.Doc, aixt_path string) {
	mut c_gen := aixt_cgen.Gen{
		file: &ast.File{}
		table: ast.new_table()
		base_path: aixt_path
		out: ''
		includes: ''
		definitions: ''
		level_cont: 0
		pref: &pref.Preferences{}
		setup: toml.Doc{}
	}

	c_gen.pref.is_script = true
	c_gen.pref.enable_globals = true
	c_gen.setup = setup_file

	transpiled := c_gen.gen(path) // transpile Aixt (V) to C

	// saves the output file
	output_ext := match c_gen.setup.value('backend').string() {
		'nxc' 		{ '.nxc' }
		'arduino'	{ '.ino' } 
		else 		{ '.c' }
	}
	mut output_path := path.replace('.aixt', output_ext)
	output_path = output_path.replace('.v', output_ext)
	// println('\n${output_path}\n')
	os.write_file(output_path, transpiled) or {}

	// // mut trans_code := c_embedded.gen(tree)
	// mut trans_code := ''
	// if os.args.len > 2 {
	// 	if os.args[2] == '-nxc' { // if -nxt flag
	// 		equivalents := toml.parse_file('../api/equivalents.toml') or {
	// 			panic('file does not exist. ')
	// 		}
	// 		for eq in equivalents.to_any().as_map().keys() {
	// 			trans_code = trans_code.replace(eq, equivalents.value(eq).string()) // replace the NXC equivalents
	// 		}
	// 	} else {
	// 		println('Invalid flag.\n')
	// 	}
	// }
	// println(trans_code)
	// println('_'.repeat(60) + '\n')
}

pub fn compile_file(path string, setup_file toml.Doc) {

	cc := $if windows { // C compiler depending on the OS
		setup_file.value('cc_windows').string()
	} $else {
		setup_file.value('cc_linux').string()
	}

	flags := setup_file.value('cc_flags').string()

	// compiles the output file
	if setup_file.value('backend').string() == 'nxc' {
		println(os.execute('${cc} ${path}.nxc ${flags} ${path}').output)
	} else { 
		println(os.execute('${cc} ${path}.c ${flags} ${path}').output)
	}
	
	// output_path := path.replace('.v', output_ext)
	// os.write_file(output_path, transpiled) or {}

	// // mut trans_code := c_embedded.gen(tree)
	// mut trans_code := ''
	// if os.args.len > 2 {
	// 	if os.args[2] == '-nxc' { // if -nxt flag
	// 		equivalents := toml.parse_file('../api/equivalents.toml') or {
	// 			panic('file does not exist. ')
	// 		}
	// 		for eq in equivalents.to_any().as_map().keys() {
	// 			trans_code = trans_code.replace(eq, equivalents.value(eq).string()) // replace the NXC equivalents
	// 		}
	// 	} else {
	// 		println('Invalid flag.\n')
	// 	}
	// }
	// println(trans_code)
	// println('_'.repeat(60) + '\n')
}

// pub fn build_api(path string) {
// 	file_list := os.walk_ext(path, '.aixt') // transpile secondary files
// 	for file in file_list {
// 		// if file != input_name {
// 		println('Building API........') // os.execute('v run ${aixt_builder} ${device} ${file}').output)
// 		// }
// 	}
// }
