module main

import iui as ui
import os

struct Config {
mut:
	cfg_dir       string = os.join_path(os.home_dir(), '.vide')
	workspace_dir string
	vexe          string
	font_path     string
	font_size     int    = 18
	theme         string = 'Vide Default Dark'
}

fn make_config() &Config {
	mut cfg := &Config{}

	file := os.join_path(cfg.cfg_dir, 'config.yml')

	if !os.exists(file) {
		cfg.load_defaults()
	} else {
		cfg.load_from_file()
	}

	cfg.save()

	return cfg
}

fn (mut this Config) load_from_file() {
	file := os.join_path(this.cfg_dir, 'config.yml')

	lines := os.read_lines(file) or { [''] }
	for line in lines {
		spl := line.split(': ')
		if spl[0].starts_with('# ') {
			continue
		}
		match spl[0] {
			'cfg_dir' { this.cfg_dir = spl[1] }
			'workspace_dir' { this.workspace_dir = spl[1] }
			'vexe' { this.vexe = spl[1] }
			'font_path' { this.font_path = spl[1] }
			'font_size' { this.font_size = spl[1].int() }
			'theme' { this.theme = spl[1] }
			else {}
		}
	}
}

fn (mut this Config) save() {
	file := os.join_path(this.cfg_dir, 'config.yml')

	data := [
		'# Vide Configuration',
		'cfg_dir: ${this.cfg_dir}',
		'workspace_dir: ${this.workspace_dir}',
		'vexe: ${this.vexe}',
		'font_path: ${this.font_path}',
		'font_size: ${this.font_size}',
		'theme: ${this.theme}',
	]

	mut lic := ['\n\n# LICENSE.txt:', '#', '# Copyright (c) 2021-2023 Isaiah\n#',
		'# Permission is hereby granted, free of charge, to any person obtaining a copy of this',
		'# software and associated documentation files (the “Software”), to deal in the Software',
		'# without restriction, including without limitation the rights to use, copy, modify, merge',
		'# publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons',
		'# to whom the Software is furnished to do so, subject to the following conditions:\n#',
		'# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n#',
		'# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.']

	write_file(file, data.join('\n') + lic.join('\n')) or {}
}

fn (mut this Config) load_defaults() {
	dot_vide := os.join_path(os.home_dir(), '.vide')

	os.mkdir(dot_vide) or {}

	this.cfg_dir = dot_vide
	this.workspace_dir = os.join_path(dot_vide, 'workspace')

	mut font_path := os.join_path(dot_vide, 'FiraCode-Regular.ttf')
	if !os.exists(font_path) {
		mut font_file := $embed_file('assets/FiraCode-Regular.ttf')
		os.write_file_array(font_path, font_file.to_bytes()) or { font_path = ui.default_font() }
	}
	this.font_path = font_path
	this.vexe = 'v'
}

// Settings Page

fn (mut app App) show_settings() {
	mut page := ui.Page.new(title: 'Vide Settings')

	mut p := ui.Panel.new(
		layout: ui.BoxLayout.new(
			ori: 1
		)
	)
	p.set_pos(1, 1)

	mut ttf := app.s_cfg_dir()
	mut swp := app.s_workspace_dir()
	mut sexe := app.s_vexe()
	mut sfp := app.s_font_path()
	mut sfs := app.s_font_size()

	p.add_child(ttf)
	p.add_child(swp)
	p.add_child(sexe)
	p.add_child(sfp)
	p.add_child(sfs)

	/*
	mut save_btn := ui.Button.new(
		text: 'Save'
	)
	save_btn.set_bounds(0, 0, 170, 30)
	p.add_child(save_btn)*/

	mut sv := ui.ScrollView.new(
		view: p
	)

	page.add_child(sv)
	app.win.add_child(page)
}

fn (mut app App) s_cfg_dir() &ui.Titlebox {
	mut p := ui.Panel.new(layout: ui.BoxLayout.new(ori: 0, vgap: 0))

	mut tf := ui.TextField.new(text: app.confg.cfg_dir)
	mut sb := ui.Button.new(text: 'Save')
	sb.subscribe_event('mouse_up', fn [mut app, tf] (mut e ui.MouseEvent) {
		app.confg.cfg_dir = tf.text
		app.confg.save()
	})
	tf.set_bounds(0, 0, 400, 30)
	sb.set_bounds(0, 0, 100, 30)

	p.add_child(tf)
	p.add_child(sb)

	mut ttf := ui.Titlebox.new(text: 'cfg_dir', children: [p])
	return ttf
}

fn (mut app App) s_workspace_dir() &ui.Titlebox {
	mut p := ui.Panel.new(layout: ui.BoxLayout.new(ori: 0, vgap: 0))

	mut tf := ui.TextField.new(text: app.confg.workspace_dir)
	mut sb := ui.Button.new(text: 'Save')
	sb.subscribe_event('mouse_up', fn [mut app, tf] (mut e ui.MouseEvent) {
		app.confg.workspace_dir = tf.text
		app.confg.save()
	})
	tf.set_bounds(0, 0, 400, 30)
	sb.set_bounds(0, 0, 100, 30)

	p.add_child(tf)
	p.add_child(sb)

	mut ttf := ui.Titlebox.new(text: 'workspace_dir', children: [p])
	return ttf
}

fn (mut app App) s_vexe() &ui.Titlebox {
	mut p := ui.Panel.new(layout: ui.BoxLayout.new(ori: 0, vgap: 0))

	mut tf := ui.TextField.new(text: app.confg.vexe)
	mut sb := ui.Button.new(text: 'Save')
	sb.subscribe_event('mouse_up', fn [mut app, tf] (mut e ui.MouseEvent) {
		app.confg.vexe = tf.text
		app.confg.save()
	})

	mut ttf := ui.Titlebox.new(text: 'vexe', children: [p])
	mut teb := ui.Button.new(text: 'Test')
	teb.subscribe_event('mouse_up', fn [mut app, tf, mut ttf] (mut e ui.MouseEvent) {
		app.confg.vexe = tf.text
		app.confg.save()
		res := os.execute('${app.confg.vexe} version')
		app.win.tooltip = res.output
		ttf.text = 'vexe (test: ${res.output})'
	})

	tf.set_bounds(0, 0, 335, 30)
	sb.set_bounds(0, 0, 95, 30)
	teb.set_bounds(0, 0, 65, 30)

	p.add_child(tf)
	p.add_child(sb)
	p.add_child(teb)

	return ttf
}

fn (mut app App) s_font_path() &ui.Titlebox {
	mut p := ui.Panel.new(layout: ui.BoxLayout.new(ori: 0, vgap: 0))

	mut tf := ui.TextField.new(text: app.confg.font_path)
	mut sb := ui.Button.new(text: 'Save')
	sb.subscribe_event('mouse_up', fn [mut app, tf] (mut e ui.MouseEvent) {
		app.confg.font_path = tf.text
		app.confg.save()
	})
	tf.set_bounds(0, 0, 400, 30)
	sb.set_bounds(0, 0, 100, 30)

	p.add_child(tf)
	p.add_child(sb)

	mut ttf := ui.Titlebox.new(text: 'font_path', children: [p])
	return ttf
}

fn (mut app App) s_font_size() &ui.Titlebox {
	mut p := ui.Panel.new(layout: ui.BoxLayout.new(ori: 0, vgap: 0))

	mut tf := ui.numeric_field(app.confg.font_size)
	tf.set_bounds(0, 0, 100, 30)

	mut ib := ui.Button.new(text: '+')
	ib.subscribe_event('mouse_up', fn [mut app, mut tf] (mut e ui.MouseEvent) {
		val := cfs(tf.text.int() + 1)
		dump(val)
		tf.text = '${val}'
		app.set_fs(val)
	})

	mut db := ui.Button.new(text: '-')
	db.subscribe_event('mouse_up', fn [mut app, mut tf] (mut e ui.MouseEvent) {
		val := cfs(tf.text.int() - 1)
		dump(val)
		tf.text = '${val}'
		app.set_fs(val)
	})

	ib.set_bounds(0, 0, 50, 30)
	db.set_bounds(0, 0, 50, 30)

	p.add_child(tf)
	p.add_child(ib)
	p.add_child(db)

	mut ttf := ui.Titlebox.new(text: 'font_size', children: [p])
	return ttf
}

fn (mut app App) set_fs(fs int) {
	app.win.font_size = fs
	app.confg.font_size = fs
	app.confg.save()
}

fn cfs(fs int) int {
	if fs < 8 {
		return 8
	}
	if fs > 32 {
		return 32
	}
	return fs
}
