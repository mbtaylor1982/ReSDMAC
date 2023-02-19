// interactive fpp javascript
//
// $Header: $
//

// jslint pragmas:
/*global d3, document, $ */


//
// globals
//

ifp_app = {};
ifp_app.device = {};
ifp_app.placement = {};

//
// utilities
//

// append text to a defined debug div tag
function myDebug(text, debug_on, overwrite) {
	var d;
	if (debug_on === undefined)  { debug_on = false; }
	if (overwrite === undefined) { overwrite = true; }
	if (debug_on) {
		d = document.getElementById("debug");
		if (overwrite) {
			d.innerHTML = text;
		} else {
			d.innerHTML += "<br>" + text;
		}
	}
}

function bboxToString(bbox) {
	return '(' + bbox.x1 + ',' + bbox.y1 + ')' + ','  + '(' + bbox.x2 + ',' + bbox.y2 + ')';
}

function xyzToStringWithZ(xyz) {
	return '(' + xyz.x + ',' + xyz.y + ',' + xyz.z + ')';
}

function xyzToString(xyz) {
	return bboxToString({
		x1: xyz.x,
		y1: xyz.y,
		x2: xyz.x,
		y2: xyz.y
	});
}


//
// support functions
//

function symbol_type(type) {
	var xsymbols = {
		"CDR_PLL"                           : {"order": 100, "type": "point", "stroke": "none", "fill": "steelblue"},
		"CDR_PLL_MUX_CLUSTER"               : {"order": 100, "type": "point", "stroke": "none", "fill": "steelblue"},
		"CLKMUX_GROUP"                      : {"order": 100, "type": "point", "stroke": "none", "fill": "blue"},
		"CLK_REGION"                        : {"order":  10, "type": "rect",  "stroke": "blue", "fill": "blue"},
		"DLL"                               : {"order": 100, "type": "point", "stroke": "none", "fill": "blue"},
		"DQSLB_IP_SCAN_CHAIN_CONTROL_PATH"  : {"order": 100, "type": "point", "stroke": "none", "fill": "blue"},
		"DQS_CONFIG"                        : {"order": 100, "type": "point", "stroke": "none", "fill": "blue"},
		"DQS_LOGIC_BLOCK"                   : {"order": 100, "type": "point", "stroke": "none", "fill": "blue"},
		"DQ_GROUP"                          : {"order": 100, "type": "point", "stroke": "none", "fill": "blue"},
		"FFPLL_GROUP"                       : {"order": 100, "type": "point", "stroke": "none", "fill": "blue"},
		"FRACTIONAL_PLL"                    : {"order": 100, "type": "point", "stroke": "none", "fill": "blue"},
		"F_PLL_GROUP"                       : {"order": 100, "type": "point", "stroke": "none", "fill": "blue"},
		"HSSI_8G_RX_PCS"                    : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_8G_TX_PCS"                    : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_AVMM_INTERFACE"               : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_COMMON_PCS_PMA_INTERFACE"     : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_COMMON_PLD_PCS_INTERFACE"     : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_PMA_AUX"                      : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_PMA_CDR_REFCLK_SELECT_MUX"    : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_PMA_RX_BUF"                   : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_PMA_RX_DESER"                 : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_PMA_TX_BUF"                   : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_PMA_TX_CGB"                   : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_PMA_TX_SER"                   : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_REFCLK_CLUSTER"               : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_REFCLK_DIVIDER"               : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_RX_CHANNEL_CLUSTER"           : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_RX_PCS_PMA_INTERFACE"         : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_RX_PLD_PCS_INTERFACE"         : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_TX_CHANNEL_CLUSTER"           : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_TX_PCS_PMA_INTERFACE"         : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"HSSI_TX_PLD_PCS_INTERFACE"         : {"order": 100, "type": "point", "stroke": "none", "fill": "orange"},
		"INTERNAL_GLOBAL_SOURCE"            : {"order": 100, "type": "point", "stroke": "none", "fill": "blue"},
		"IO_CLUSTER"                        : {"order": 100, "type": "point", "stroke": "none", "fill": "darkred"},
		"IO_CONFIG"                         : {"order": 100, "type": "point", "stroke": "none", "fill": "pink"},
		"IO_OUTPUT_BUFFER"                  : {"order": 100, "type": "point", "stroke": "none", "fill": "red"},
		"LEVELING_DELAY_CHAIN"              : {"order": 100, "type": "point", "stroke": "none", "fill": "blue"},
		"LVDS_QUADRANT"                     : {"order": 100, "type": "point", "stroke": "none", "fill": "green"},
		"LVDS_RX"                           : {"order": 100, "type": "point", "stroke": "none", "fill": "green"},
		"LVDS_TX"                           : {"order": 100, "type": "point", "stroke": "none", "fill": "green"},
		"OCT_CAL_BLOCK"                     : {"order": 100, "type": "point", "stroke": "none", "fill": "blue"},
		"PLL_LVDS_OUTPUT"                   : {"order": 100, "type": "point", "stroke": "none", "fill": "steelblue"},
		"PLL_OUTPUT_COUNTER"                : {"order": 100, "type": "point", "stroke": "none", "fill": "steelblue"},
		"ROWCLK_REGION"                     : {"order":  50, "type": "rect",  "stroke": "blue", "fill": "blue"},
		"BOGUS"                             : {"order": 100, "type": "point", "stroke": "none", "fill": "red"}
	};
	return xsymbols[type];
};	

// color returns fill color. if this is none, it returns stroke color
function color(type) {
	var fill_color = fill(type);
	if (fill_color === "none") {
		return stroke(type);
	} else {
		return fill_color;
	}
};


function fill(type) {
	if (typeof symbol_type(type) === "undefined") {
		return "red";
	} else {
		return symbol_type(type).fill;
	}
};

function stroke(type) {
	if (typeof symbol_type(type) === "undefined") {
		return "red";
	} else {
		return symbol_type(type).stroke;
	}
};

function rect_type(type) {
	if (typeof symbol_type(type) === "undefined") {
		return "point";
	} else {
		return symbol_type(type).type;
	}
};

function rect_z_order(type) {
	if (typeof symbol_type(type) === "undefined") {
		return 100;
	} else {
		return symbol_type(type).order;
	}
};

function rect_opacity(type) {
	if (typeof symbol_type(type) === "undefined") {
		return 0.8;
	} else {
		if (symbol_type(type).type === "rect") {
			return 0.0;
		}
	}
};


// compute all the used locations in the design, given the json cells data
function used_locs(cells) {
	var used_locs = [];
	cells.forEach(function (cell) {
		var cell_locs = cell.locations;
		if (cell_locs !== undefined) {
			cell_locs.forEach(function (loc) {
				used_locs.push(parseInt(loc.lid));
			});
		}
	});
	return used_locs;
}

// flatten the json datastructure we get from tcl.
// i.e., instead of a list of locations for each cell, flatten 
// to a single array that has all info in each entry
function flatten_cells(cells) {
	var loc_map = d3.map(),
		flat_cells = [],
		c,
		l,
		lxyz,
		key,
		current_val,
		max_values_string;

	// first pass to get number of cells at an x,y location
	for (c = 0; c < cells.length; c += 1) {
		if (cells[c].locations !== undefined) {
			// cells with locations...
			for (l = 0; l < cells[c].locations.length; l += 1) {
				// first see if anything else is at this location.
				lxyz = cells[c].locations[l].lxyz;
				key = lxyz.x + "," + lxyz.y;
				if (loc_map.has(key)) {
					// already something at this location... need to increment
					current_val = loc_map.get(key);
					current_val.max += 1;
				} else {
					// nothing here... just create
					current_val = {max: 1, current: -1};
				}
				loc_map.set(key, current_val);
			}
		} else {
			// cells without locations...
		}
	}

	// second pass to set current + max on each cell
	for (c = 0; c < cells.length; c += 1) {
		if (cells[c].locations !== undefined) {
			// cells with locations...
			for (l = 0; l < cells[c].locations.length; l += 1) {
				// first see if anything else is at this location.
				lxyz = cells[c].locations[l].lxyz;
				key = lxyz.x + "," + lxyz.y;
				if (loc_map.has(key)) {
					// already something at this location... need to increment
					current_val = loc_map.get(key);
					current_val.current += 1;
				} else {
					// nothing here... just create
					current_val = {current: 0};
				}
				loc_map.set(key, current_val);

				flat_cells.push({
					cell: cells[c].cell,
					cell_name: cells[c].cell_info.cname,
					cell_type: cells[c].cell_info.ctype,
					loc: cells[c].locations[l],
					num_locs: cells[c].locations.length,
					xy_max: current_val.max,
					xy_index: current_val.current
				});
			}
		} else {
			// cells without locations...
			flat_cells.push({
				cell: cells[c].cell,
				cell_name: cells[c].cell_info.cname,
				cell_type: cells[c].cell_info.ctype
			});
		}
	}

	return flat_cells;
}


//
// link graph functionality
//


function mouseover_info_graph_links(links) {
	// record some useful information
	// need to pass an array to .data()
	// for now, just append data to the debug pane
	var p = d3.select("#debug")
		.selectAll("p.nowrap")
		// need a custom key...
		.data(links, function (d) {
			return d.source_name + " (" + d.source_type + "::" + d.source_port + ") -> "
				+  d.target_name + " (" + d.target_type + "::" + d.target_port + ")";
		});

	// new entries		
	p.enter().append("p")
		.attr("class", "nowrap")
		.text(function (d) {
			return d.source_name + " (" + d.source_type + "::" + d.source_port + ") -> "
				+  d.target_name + " (" + d.target_type + "::" + d.target_port + ")";
		});

	p.exit().remove();
}



// use the json data to draw the svg and the construct the cell table
// currently untested... probably gets called on button click but not sure
// what else happens!
function use_json_links(json_data) {

	// http://blog.thomsonreuters.com/index.php/mobile-patent-suits-graphic-of-the-day/
	var links = json_data,
		nodes = {},
		width = 500,
		height = 500,
		links_map = d3.map(),
		x_nodes,
		x_links,
		force,
		key,
		svg,
		link,
		node;


	// compute new source and target names for the links
	links.forEach(function (link) {
		var graph_ports = false;
		if (graph_ports) {
			link.source = link.src_name + "." + link.src_port_name;
			link.target = link.dst_name + "." + link.dst_port_name;
		} else {
			link.source = link.src_name;
			link.target = link.dst_name;
			link.source_type = link.src_type_name;
			link.target_type = link.dst_type_name;
			link.source_id   = link.src_id;
			link.target_id   = link.dst_id;
		}
	});

	// computer distinct links first...
	links.forEach(function (link) {
		// also compute distinct links, given the nodes we are using
		// key is the source->target string, value is the object with the source and target separated out
		// need to make this work still!
		// also would like to count the number of links collapsed so they can be drawn thicker.
		key = link.source + "." + link.target;
		var map_link;
		// check if the key already has an entry, and if it does bump the link counter
		if (links_map.has(key)) {
			map_link = links_map.get(key);
			map_link.links.push({
				source_name : link.src_name,
				source_port : link.src_port_name,
				source_type : link.src_type_name,
				target_name : link.dst_name,
				target_port : link.dst_port_name,
				target_type : link.dst_type_name
			});
			links_map.set(key, map_link);
		} else {
			map_link = {
				source      : link.source,
				source_id   : link.source_id,
				source_type : link.source_type,
				target      : link.target,
				target_id   : link.target_id,
				target_type : link.target_type,
				links       : []
			};
			map_link.links.push({
				source_name : link.src_name,
				source_port : link.src_port_name,
				source_type : link.src_type_name,
				target_name : link.dst_name,
				target_port : link.dst_port_name,
				target_type : link.dst_type_name
			});
			links_map.set(key, map_link);
		}
	});

	links = d3.values(links_map);

	// Compute the distinct nodes from the links.
	links.forEach(function (link) {
		link.source = nodes[link.source] || (nodes[link.source] = {name: link.source, type: link.source_type, id: link.source_id});
		link.target = nodes[link.target] || (nodes[link.target] = {name: link.target, type: link.target_type, id: link.target_id});
	});


	x_nodes = d3.values(nodes);
	x_links = links;

	force = d3.layout.force()
		.charge(-80)
		.linkDistance(35)
		.size([width, height]);

	// need to fix for reloads... look at the chip/device code above!
	svg = d3.select("#links-svg")
		.select("svg")
		.attr("width", width)
		.attr("height", height);

	force
		.nodes(x_nodes)
		.links(x_links)
		.start();

	link = svg.selectAll("line.link")
		.data(links)
		.enter().append("line")
		.attr("class", "link")
		.style("stroke-width", function (d) {
			return Math.sqrt(d.links.length);
		})
		.on("mouseover", function (d) {
			// highlight
			d3.select(this).attr("class", "link-selected");
			mouseover_info_graph_links(d.links);
		})
		.on("mouseout",  function () {
			// unhighlight
			d3.select(this).attr("class", "link");
		});

	link.append("title")
		.text(function (d) {
			var src = d.source,
				dst = d.target;
			return d.links.length + " links: " + src.name + " (" + src.type + ") -> " + dst.name + " (" + dst.type + ")";
		});

	node = svg.selectAll("circle.node")
		.data(force.nodes())
		.enter().append("circle")
		.attr("class", "node")
		.attr("r", 5)
		.style("fill", function (d) {
			return color(d.type);
		})
		.call(force.drag)
		.on("mouseover", function (d) {
			// highlight
			d3.select(this)
				.style("stroke", "black")
				.style("stroke-width", "2.0px")
				.style("fill", "yellow");
		})
		.on("mouseout",  function () {
			// unhighlight
			d3.select(this)
				.style("stroke", "white")
					.style("stroke-width", "1.0px")
				.style("fill", function (d) {
					return color(d.type);
				});
		});


	node.append("title")
		.text(function (d) {
			return d.type + " " + d.name;
		});

	force.on("tick", function () {
		link.attr("x1", function (d) { return d.source.x; })
			.attr("y1", function (d) { return d.source.y; })
			.attr("x2", function (d) { return d.target.x; })
			.attr("y2", function (d) { return d.target.y; });

		node.attr("cx", function (d) { return d.x; })
			.attr("cy", function (d) { return d.y; });
	});
}


//
// right-click menu command functionality
//


function buildmenu (parent, children) {
	$.each(children, function () {
		if (this.label !== undefined) {
			var href = $("<a href='#'>" + this.label + "</a>");
			if (this.onclick !== undefined) {
				href[0].onclick = this.onclick;
			}
			
			var li = $("<li></li>");
			href.appendTo(li);
			li.appendTo(parent);

			if (this.disable !== undefined && this.disable === true) {
				li.addClass("ui-state-disabled");
			}
			// build submenu items
			if (this.children !== undefined && this.children.length > 0) {
				var ul = $("<ul></ul>");
				ul.appendTo(li);
				buildmenu(ul, this.children);
			}
		}
	});
}


var unplace_cell = function (cell_id, cell_name) {
	var tcl_cmd = "unplace_periph_cell -cell " + cell_id;
	do_tcl(tcl_cmd);
}

function place_cell_in_loc(cell_id, cell_name, loc, loc_name) {
	var tcl_cmd = "fpp_place -cell " + cell_id + " -loc " + loc;
	do_tcl(tcl_cmd);
}

function place_cell_in_bank(cell_id, cell_name, bank_id, bank_name) {
	var tcl_cmd = "place_periph_pin_in_bank -cell " + cell_id + " -bank " + bank_id;
	do_tcl(tcl_cmd);
}


function menu_entries (cell_id, cell_name, json_menu_entries) {
	var entries = [{}, {}, {}],
		in_loc = entries[0],
		in_bank = entries[1],
		unplace = entries[2];

	var tcl_cmd = "[lindex [fpp_get_locations -cell " + cell_id + "] 0]";

	// populate place in location
	var locs = [{ loc_name : "a", loc_id : 0 },
				{ loc_name : "b", loc_id : 1 }];
	locs = json_menu_entries.locs;
	
	in_loc.label = "Set Cell Location";
	in_loc.children = [];
	in_loc.disable = true;
	locs.forEach(function(loc) {
		var loc_entry = {};
		loc_entry.label = loc.loc_name;
		loc_entry.onclick = function() { place_cell_in_loc(cell_id, cell_name, loc.loc_id, loc.loc_name); };
		in_loc.children.push(loc_entry);
		in_loc.disable = false;
	});

	// populate place in bank
	var banks = [{ bank_name : "x", bank_id : 7 },
				{ bank_name : "y", bank_id : 8}];
	banks = json_menu_entries.banks;
	
	in_bank.label = "Set Cell in Bank Location";
	in_bank.children = [];
	in_bank.disable = true;
	banks.forEach(function(bank) {
		var bank_entry = {};
		bank_entry.label = bank.bank_name;
		bank_entry.onclick = function() { place_cell_in_bank(cell_id, cell_name, bank.bank_id, bank.bank_name); };
		in_bank.children.push(bank_entry);
		in_bank.disable = false;
	});

	// populate unplace cell
	unplace.label = "Clear Cell Location";
	unplace.onclick = function() { unplace_cell(cell_id, cell_name); };
	unplace.disable = !in_loc.disable;

	return entries;
}

function on_menu_click (d) {
	// 1. construct:
	var tcl_cmd = "::quartus::int_fitter::html5::menu_entry_json " + d.cell,
		tcl_json_file = "menu_entries.json";

	// use anonymous function so callback has access to closure variables
	var ajax_object = do_tcl_with_callback(tcl_cmd, tcl_json_file, event, function (result, mouse_event) {
		var entries = menu_entries(d.cell, d.cell_name, result);

		// purge the existing menu, reload it with the new entries and then refresh
		$("#menu").empty();
		buildmenu($("#menu"), entries);
		$( "#menu" ).menu("refresh");

		// show the new menu to the user.
		$( "#menu" )
			.show()
			.position({
				my: "left top",
				of: mouse_event,
				collision: "flip"
			});
		// also need to hide the menu if the user clicks anywhere else (ie entire body)
		// menu is only created once so this can't be done in .menu.create
		$("body").bind({
			'click.menucancel': function () {
				$("#menu").hide();
				$("body").unbind('.menucancel');
			},
			'contextmenu.menucancel': function () {
				$("#menu").hide();
				$("body").unbind('.menucancel');
			}
		});
	});
}


// initialize our menu for use later
$(function() {
	$( "#menu" ).menu({
		select: function (event, ui) {
			// when an item is selected its callback will be executed and then
			// we need hide them menu, and then remove the mouse override on the
			// rest of the document elements.
			if (ui.item[0].childElementCount === 1) {
				$("#menu").hide();
				$("body").unbind('.menucancel');
			}
		}
	});
	$( "#menu" ).hide();
});

//
// placement
//


function do_tcl_with_callback(cmd, response_file, mouse_event, callback) {
	var cmd_url = "http://tcl/itc_backend_cmd -creator default -run_hidden {::quartus::int_fitter::html5::to_file {"
			+ cmd + "} "
			+ response_file + "}",
		response_url = "/project/db/json/" + response_file,
		result_json = {};

	var ajax = jQuery.ajax({
		url: cmd_url,
		complete: function(result) {
			jQuery.ajax({
				url: response_url,
				success: function (result) {
					callback(result, mouse_event);
				}
			});
		}
	});
	return ajax;
}

function do_tcl(cmd, supress_reload) {
	if (supress_reload === undefined) {
		supress_reload = false;
	}
	// todo: generalize to take a callback so that all tcl urls are centralized here
	var url_cmd_text = "http://tcl/itc_backend_cmd -creator default -run_hidden {" + cmd + "}";
	// execute the tcl command and update the json...
	var reload_callback = update_placement;
	if (supress_reload) {
		reload_callback = {};
	}
	
	d3.text(url_cmd_text, reload_callback);
}

function place_all() {
	do_tcl("place_periph_cells -all");
}

function unplace_all() {
	do_tcl("unplace_periph_cells -all");
}

// use the json data to draw the svg and then construct the cell table
function use_json_placement(json_data) {
	ifp_app.placement.cells = flatten_cells(json_data.cells);
	ifp_app.placement.used_locs = used_locs(json_data.cells);
	ifp_app.device.chip_rect = json_data.chip_rect;
	var flat_cells = ifp_app.placement.cells,
		chip_rect =  ifp_app.device.chip_rect;

	// once the placement data is loaded then we can format the banks
	update_banks("special");

	//
	// function definitions
	//
	
	function cell_table_key(d) {
		if (d.loc !== undefined) {
			return rect_z_order(d.loc.ltype) + "." + d.cell + "." + d.loc.lname;
		} else {
			return d.cell + "." + "unplaced";
		}
	}

	function chip_drawing (flat_cells, cell_table_key, chip_rect) {
		var	chip_width = chip_rect.x2 - chip_rect.x1 + 1,
			chip_height  = chip_rect.y2 - chip_rect.y1 + 1,
			xmax = 500,
			ymax = 500,
			margin = 30,
			xScale = d3.scale.linear().domain([0, chip_width]).range([0, xmax]),
			yScale = d3.scale.linear().domain([0, chip_height]).range([ymax, 0]),
			xAxis = d3.svg.axis().scale(xScale).orient("top"),
			yAxis = d3.svg.axis().scale(yScale).orient("left"),
			svg,
			device_group,
			device_rect,
			rect_group,
			zoom;

		function on_zoom() {
			var t = d3.event.translate,
				s = d3.event.scale,
				s_xmax = xmax * (1 - s),
				s_ymax = ymax * (1 - s);

			// the translate event gives the offset (screen coordinates) of the contained object.
			// [xy]Scale will transform a value from domain to range, taking into account both scaling
			// and offset translations!
			// we can use the scaling of the viewport rect to ensure that the viewport stays in view

			// following handles when scale is < 1 even though we don't currently allow.
            if (s < 1) {
				// for objects smaller than the viewport ensure
				// it can't be panned outside the viewport rect
				if (t[0] < 0) {
					t[0] = 0;
				}
				if (t[0] > s_xmax) {
					t[0] = s_xmax;
				}
				if (t[1] < 0) {
					t[1] = 0;
				}
				if (t[1] > s_ymax) {
					t[1] = s_ymax;
				}
			} else {
				// for objects larger than the viewport ensure
				// viewport is always filled with some part of the object
				if (t[0] > 0) {
 					t[0] = 0;
				}
				if (t[0] < s_xmax) {
 					t[0] = s_xmax;
				}
				if (t[1] > 0) {
 					t[1] = 0;
				}
				if (t[1] < s_ymax) {
					t[1] = s_ymax;
				}
			}

			// write-back the clipped translate event so the axes will conform!
			zoom.translate(t);

			// translate and scale the actual chip-view			
			device_group.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");

			svg.select(".x.axis").call(xAxis);
			svg.select(".y.axis").call(yAxis);
		}


		zoom = d3.behavior.zoom()
			.x(xScale)
			.y(yScale)
			.scaleExtent([1.0, 10])
			.on("zoom", on_zoom);

		// the chip drawing
		svg = d3.select("#chip-svg")
			.select("svg")
			.attr("viewbox", 0, 0, xmax + margin + margin, ymax + margin + margin)
			.attr("width", xmax + margin + margin)
			.attr("height", ymax + margin + margin);

		// remove everything from before first... must be a better way
		svg.select("g").remove();
		svg = svg.append("g")
			.attr("transform", "translate(" + margin + "," + margin + ")")
			.call(zoom);

		// device
		device_group = svg.append("g")
			.attr("id", "device_group");
		
		device_rect = device_group.append("rect")
			.style("fill", "aliceblue")
			.style("stroke", "teal")
			.style("stroke-width", "1.0px")
			.attr("x", xScale(0))
			.attr("y", yScale(chip_height))
			.attr("width", xScale(chip_width))
			.attr("height", yScale(0) - yScale(chip_height));

		// idea...
		// insert a "rect" and a "point" group here. the purpose is to
		// ensure that the rect is drawn before (and hence under) the
		// points so that the z-order is nice for drawing/mouse events
		// is this possible?

		// we can also enforce an order with a custom key...

		rect_group = device_group.selectAll("g")
			.data(flat_cells, cell_table_key)
			.enter()
			.append("g");

		// ack. this works but i don't think it is the best way of doing this.
		// also, what happens when items are placed/unplaced? are all regions
		// placed during constraint propagation? if so then this is okay; if 
		// not then probably not...
		// todo: i have seen problems with this... need to debug and fix!
		rect_group = rect_group.sort(function(a, b) {
			if ((a.loc !== undefined) && (b.loc !== undefined)) {
				return d3.ascending(rect_z_order(a.loc.ltype), rect_z_order(b.loc.ltype));
			} else {
				// these nodes should not be shown in the device view, so it
				// shouldn't matter where they are sorted to...
				return NaN;
			}
		});

		rect_group = rect_group
			.append("rect")
			.attr("class", "loc")
			.attr("id", function (d) {
				return "cell" + d.cell;
			})
			.style("stroke-width", 1)
			.style("stroke", function (d) {
				if (d.loc !== undefined) {
					return stroke(d.loc.ltype);
				}
			})
			.style("fill", function (d) {
				if (d.loc !== undefined) {
					return fill(d.loc.ltype);
				}
			})
			.style("fill-opacity", function(d) {
				if (d.loc !== undefined) {
					return rect_opacity(d.loc.ltype);
				} else {
					return 0.8;
				}
			});

		rect_group.append("title")
			.text(function (d) {
				var tt = d.cell_name;
				if (d.loc !== undefined) {
					tt = tt + " (" + d.loc.lxyz.x + "," + d.loc.lxyz.y + ")";
					tt = tt + " " + d.loc.ltype;
				}
				return tt;
			});

		rect_group.call(position);
		
		// position the cells on the device
		function position (cell_rect) {
			cell_rect
				.attr("x", function (d) {
					if (d.loc !== undefined) {
						switch (rect_type(d.loc.ltype)) {
							case "rect":
								return xScale(d.loc.lbbox.x1);
								break;
							case "point":
							default:
								// default to a point...
								return xScale(d.loc.lxyz.x);
						}
					}
				})
				.attr("y", function (d) {
					// subdivide the rect so that all cells at this x,y location are
					// visible. we will do this in the y direction only... but we need
					// to calculate new values for both the y origin and the height
					if (d.loc !== undefined) {
						switch (rect_type(d.loc.ltype)) {
							case "rect":
								return yScale(d.loc.lbbox.y2 + 1);
								break;
							case "point":
							default:
								// default to a point...
								var new_y = d.loc.lxyz.y + 1,
									scale = 1.0;

								new_y -= d.xy_index * scale / d.xy_max;
								return yScale(new_y);
						}
					}
				})
				.attr("width", function (d) {
					if (d.loc !== undefined) {
						var width, x2, x1;
						// need to calculate the x,y of each corner and then pass back the difference
						// to make calculations work with distortions! point is like a rect with size 1
						switch (rect_type(d.loc.ltype)) {
							case "rect":
								// scale individual
								x2 = d.loc.lbbox.x2 + 1,
								x1 = d.loc.lbbox.x1;
								break;
							case "point":
							default:
								// default to a point...
								x1 = d.loc.lxyz.x;
								x2 = d.loc.lxyz.x + 1;
						}
						x2 = xScale(x2);
						x1 = xScale(x1);
						width = x2 - x1;
						return width;
					}
				})
				.attr("height", function (d) {
					// subdivide the rect so that all cells at this x,y location are
					// visible. we will do this in the y direction only... but we need
					// to calculate new values for both the y origin and the height
					// base height is 1.0.
					if (d.loc !== undefined) {
						// need to calculate the x,y of each corner and then pass back the difference
						// to make calculations work with distortions! point is like a rect with size 1
						var height, y2, y1;
						switch (rect_type(d.loc.ltype)) {
							case "rect":
								y2 = d.loc.lbbox.y2 + 1;
								y1 = d.loc.lbbox.y1;
								break;
							case "point":
							default:
								// default to a point...
								y1 = d.loc.lxyz.y + (d.xy_index / d.xy_max);
								y2 = d.loc.lxyz.y + ((d.xy_index + 1) / d.xy_max);
						}
						y2 = yScale(y2);
						y1 = yScale(y1);
						height = y1 - y2;
						return height;
					}

				});
		}

		// add callbacks for mouse functionality
		rect_group
			.on("mouseover", function (d) {
				var cells = [];
				// paint us orange
				d3.select(this)
					.style("stroke", "yellow")
					.style("fill", "yellow");
			})
			.on("mouseout",  function () {
				d3.select(this)
					.style("stroke", function (d) {
						return stroke(d.loc.ltype);
					})
					.style("fill", function (d) {
						return fill(d.loc.ltype);
					});
			});


		// add some rects to block the image the falls outside the
		// graph but inside the viewport
		svg.append("rect")
			.attr("x", -margin)
			.attr("y", -margin)
			.attr("width", xmax + margin + margin)
			.attr("height", margin)
			.style("fill", "white");
		svg.append("rect")
			.attr("x", -margin)
			.attr("y", ymax)
			.attr("width", xmax + margin + margin)
			.attr("height", margin)
			.style("fill", "white");
		svg.append("rect")
			.attr("x", -margin)
			.attr("y", 0)
			.attr("width", margin)
			.attr("height", ymax)
			.style("fill", "white");
		svg.append("rect")
			.attr("x", xmax)
			.attr("y", 0)
			.attr("width", margin)
			.attr("height", ymax)
			.style("fill", "white");

		// some axis
		svg.append("g")
			.attr("class", "x axis").call(xAxis);
		svg.append("g")
			.attr("class", "y axis").call(yAxis);
	}

	function cell_highlight (d) {
		// this is a list of lists of elements? seems wrong...
		d3.select(this[0][0])
			.style("stroke", "yellow")
			.style("fill", "yellow")
			.style("fill-opacity", .8);
	}

	function cell_unhighlight (d) {
		// this is a list of lists of elements? seems wrong...
		d3.select(this[0][0])
			.style("stroke", function (d) {
				if (d.loc !== undefined) {
					return stroke(d.loc.ltype);
				}
			})
			.style("fill", function (d) {
				if (d.loc !== undefined) {
					// all rect seems to exist, even if not locations (should fix)
					// need to only continue if location exists
					return fill(d.loc.ltype);
				}
			})
			.style("fill-opacity", function(d) {
				if (d.loc !== undefined) {
					return rect_opacity(d.loc.ltype);
				}
			});
	}

	function bank_highlight (d) {
		// this is a list of lists of elements? seems wrong...
		d3.select(this[0][0])
			.style("fill", "yellow");
	}

	function bank_unhighlight (d) {
		// this is a list of lists of elements? seems wrong...
		d3.select(this[0][0])
			.style("fill", "lightblue");
	}

	// cell table generation
	function cell_table(flat_cells, cell_table_key) {
		var chip,
			tr,
			tr_enter;

		// chip test table via d3
		chip = d3.select("#celltable")
			.select("table")
			.select("tbody");

		tr = chip.selectAll("tr")
			.data(flat_cells, cell_table_key);

		tr_enter = tr.enter().append("tr")
			.on("mouseover", function (d) {
				// highlight a row in the table...
				d3.select(this)
					.style("background-color", "lightblue");
				// highlight the cell in the svg...
				var cell_selector = "rect.loc#cell" + d.cell;
				d3.select(cell_selector)
					.call(cell_highlight);
				// highlight the bank
				if (d.loc !== undefined) {
					var bank_selector = "rect.loc#bank" + d.loc.lbankid;
					d3.select(bank_selector)
						.call(bank_highlight);
				}
			})
			.on("mouseout",  function (d) {
				// un-highlight a row in the table...
				d3.select(this)
					.style("background-color", "white");
				// un-highlight the cell in the svg...
				var cell_selector = "rect.loc#cell" + d.cell;
				d3.select(cell_selector)
					.call(cell_unhighlight);
				// un-highlight the bank
				if (d.loc !== undefined) {
					var bank_selector = "rect.loc#bank" + d.loc.lbankid;
					d3.select(bank_selector)
						.call(bank_unhighlight);
				}
			})
			.on("contextmenu", function (d) {
				// build and display the menu
				on_menu_click(d);
			})
			.attr("oncontextmenu", "return false;");

		tr_enter.append("td").text(function (d) {
			return d.cell;
		});
		tr_enter.append("td").text(function (d) {
			return d.cell_name;
		});
		tr_enter.append("td").text(function (d) {
			return d.cell_type;
		});
		tr_enter.append("td").text(function (d) {
			if (d.loc !== undefined) {
				return d.loc.lbank;
			}
		});
		tr_enter.append("td").text(function (d) {
			if (d.loc !== undefined) {
				return d.loc.lname;
			}
		});

		tr.exit().remove();

		// refresh table sorting cache
		$('#cells')
			.trigger("update")
			.trigger("appendCache");

		// refresh table filter cache
		$('#cells').tableFilterRefresh();
	}

	//
	// code
	//

	chip_drawing(flat_cells, cell_table_key, chip_rect);

	cell_table(flat_cells, cell_table_key);
}



function hide_or_show_based_on_ini_callback() {
	// should generalize this...
	function chomp(raw)
	{
		return raw.replace(/(\n|\r)+$/, '');
	}
	
	d3.text("/project/db/json/ini.txt", function(ini_data) {
		switch (chomp(ini_data)) {
			case "on":
			case "1":
				$(".hide-unless-ini").show();
				break;
			default:
				break;
		}
	});
}

function hide_or_show_based_on_ini() {
	d3.text("http://tcl/itc_backend_cmd -creator default -run_hidden {::quartus::int_fitter::html5::to_file {get_ini_var -name ifp_app_show_hidden} ini.txt}", hide_or_show_based_on_ini_callback);
}

//
// loading
//

// this bs callback chain needs to be refactored...

// perform ajax load of jason placement data
function load_placement() {
	d3.json("/project/db/json/placement.json", use_json_placement);
}

// update placement.json and then load the new placement
function update_placement(error, response) {
	d3.text("http://tcl/itc_backend_cmd -creator default -run_hidden {::quartus::int_fitter::html5::to_file ::quartus::int_fitter::html5::placement placement.json}", load_placement);
}

function use_device_and_update_placement(json_data) {
	ifp_app.device = json_data;
	update_placement();
}

function load_device_and_update_placement() {
	d3.json("/project/db/json/device.json", use_device_and_update_placement);
}

// update device.json and then load the new device
function update_device_and_placement() {
	d3.text("http://tcl/itc_backend_cmd -creator default -run_hidden {::quartus::int_fitter::html5::to_file ::quartus::int_fitter::html5::device device.json}", load_device_and_update_placement);
}

// called from html script to start everything going...
function init_ifp_app() {
	hide_or_show_based_on_ini();
	update_device_and_placement();
	update_links();
}

// perform ajax load of jason links data
function load_links() {
	d3.json("/project/db/json/links.json", use_json_links);
}

// update links.json and then load the new links
function update_links() {
	d3.json("http://tcl/itc_backend_cmd -creator default -run_hidden {::quartus::int_fitter::html5::to_file ::quartus::int_fitter::html5::links links.json}", load_links);
}


// use the json data to draw the svg and then construct the cell table
function update_banks(layout_type) {
	var chip_rect =  ifp_app.device.chip_rect
		banks = ifp_app.device.banks;

	if (typeof(layout_type) === 'undefined') layout_type = "special";


	//
	// function definitions
	//
	
	function cell_table_key(d) {
		if (d.loc !== undefined) {
			return rect_z_order(d.loc.ltype) + "." + d.cell + "." + d.loc.lname;
		} else {
			return d.id + "." + "unplaced";
		}
	}

	function chip_drawing (banks, cell_table_key) {
		var	chip_rect = banks.rect,
			chip_width = chip_rect.x2 - chip_rect.x1 + 1,
			chip_height  = chip_rect.y2 - chip_rect.y1 + 1,
			xmax = 500,
			ymax = 500,
			margin = 40,
			xScale = d3.scale.linear().domain([0, chip_width]).range([0, xmax]),
			yScale = d3.scale.linear().domain([0, chip_height]).range([ymax, 0]),
			svg,
			device,
			rect_group;

		// the chip drawing
		svg = d3.select("#banks-svg")
			.select("svg")
			.attr("viewbox", 0, 0, xmax + margin + margin, ymax + margin + margin)
			.attr("width", xmax + margin + margin)
			.attr("height", ymax + margin + margin);

		// remove everything from before first... must be a better way
		svg.select("g").remove();
		svg = svg.append("g");

		// device
		device = svg.append("rect")
			.style("fill", "aliceblue")
			.style("stroke", "teal")
			.style("stroke-width", "1.0px")
			.attr("id", "banks-rect")
			.attr("x", xScale(0))
			.attr("y", yScale(chip_height))
			.attr("width", xScale(chip_width))
			.attr("height", yScale(0) - yScale(chip_height));

		rect_group = svg.selectAll("g")
			.data(banks, cell_table_key)
			.enter();

		var new_rect_group = rect_group
			.append("rect")
			.attr("class", "loc")
			.attr("id", function (d) {
				return "bank" + d.id;
			})
			.style("fill", function (d) {
				if (d.loc !== undefined) {
					return fill(d.loc.ltype);
				} else {
					return "lightblue";
				}				
			})
			.style("fill-opacity", function(d) {
				if (d.loc !== undefined) {
					return rect_opacity(d.loc.ltype);
				} else {
					return 0.8;
				}
			})
			.style("stroke", "teal")
			.style("stroke-width", "1.0px");

		new_rect_group.call(position);
		new_rect_group.call(add_mouse_callbacks);
		new_rect_group.append("title")
			.text(function (d) {
				var used = num_used_locations_in_bank(d);
				var locations = d.children.length;
				return "Bank " + d.name + ": " + used + "/" + locations;
			});
		
		var bank_name = rect_group
			.append("text")
			.attr("class", "loc")
			.attr("id", function (d) {
				return "bank" + d.id;
			})
			.style("text-anchor", "middle")
			.style("dominant-baseline", "central")
			.text(function (d) {
				return "Bank " + d.name;
			});

		bank_name.call(position_text, -10);
		bank_name.call(add_mouse_callbacks);

		var bank_occupancy = rect_group
			.append("text")
			.attr("class", "loc")
			.attr("id", function (d) {
				return "bank" + d.id;
			})
			.style("text-anchor", "middle")
			.style("dominant-baseline", "central")
			.text(function (d) {
				var used = num_used_locations_in_bank(d);
				var locations = d.children.length;
				return used + "/" + locations;
			});

		bank_occupancy.call(position_text, 10);
		bank_occupancy.call(add_mouse_callbacks);

		function num_used_locations_in_bank (bank) {
			var used_bank_locs = _.intersection(bank.children, ifp_app.placement.used_locs);
			return used_bank_locs.length;
		};
			
		// position the banks on the device
		// commonize!
		function position (cell_rect) {
			cell_rect
				.attr("x", function (d) {
					if (d !== undefined) {
						return xScale(d.bb.x1);
					}
				})
				.attr("y", function (d) {
					if (d !== undefined) {
						return yScale(d.bb.y2 + 1);
					}
				})
				.attr("width", function (d) {
					if (d !== undefined) {
						var width, x2, x1;
						// need to calculate the x,y of each corner and then pass back the difference
						// to make calculations work with distortions! point is like a rect with size 1
						// scale individual
						x2 = d.bb.x2 + 1,
						x1 = d.bb.x1;
						x2 = xScale(x2);
						x1 = xScale(x1);
						width = x2 - x1;
						return width;
					}
				})
				.attr("height", function (d) {
					// subdivide the rect so that all cells at this x,y location are
					// visible. we will do this in the y direction only... but we need
					// to calculate new values for both the y origin and the height
					// base height is 1.0.
					if (d !== undefined) {
						// need to calculate the x,y of each corner and then pass back the difference
						// to make calculations work with distortions! point is like a rect with size 1
						var height, y2, y1;
						y2 = d.bb.y2 + 1;
						y1 = d.bb.y1;
						y2 = yScale(y2);
						y1 = yScale(y1);
						height = y1 - y2;
						return height;
					}

				});
		}

		// position the cells on the device
		// commonize!
		function position_text (cell_rect, offset) {
			cell_rect
				.attr("x", function (d) {
					if (d !== undefined) {
						return xScale(d.bb.x1 + 0.5);
					}
				})
				.attr("y", function (d) {
					if (d !== undefined) {
						return yScale(d.bb.y2 + 0.5) + offset;
					}
				});
		}

		// add callbacks for mouse functionality
		// centralize!
		function add_mouse_callbacks (new_rect_group) {
			// for both mouseover and mouseout we manipulate the 
			// associated rect because we can register against the
			// assoicated text label that may be in front of the rect
			new_rect_group
				.on("mouseover", function (d) {
					d3.select("rect#" + this.id)
						.style("fill", "yellow");
				})
				.on("mouseout",  function () {
					d3.select("rect#" + this.id)
						.style("fill", function (d) {
							return "lightblue";
						});
				});
		}
	}

	function massage_banks(banks) {
		// packing algorithm A:
		// 1. iterate through bank via the y-coord. calculate new y-value based on order visited.
		// 2. iterate through bank via the x-coord. calculate new x-value based on order visited.
		// problem: banks don't always pack "nicely".
		// seems like we need to know more about edges and columns.
		// packing algorithm B:
		// this will assume that banks are on edges and possibly in columns in the core
		// 1. iter
		// idea: if only columns that are found are edges then we do just edges
		//       if more columns are found, then we don't do top/bot?

		banks.xs = [];
		banks.xs_max_length = 0;
		banks.ys = [];
		banks.edges = {};
		banks.edges.use = true;
		
		banks.forEach(function (bank) {
			var x = bank.cbb.x1,
				y = bank.cbb.y1;

			if (banks.xs[bank.cbb.x1] === undefined) {
				banks.xs[bank.cbb.x1] = [];
			}
			// each list of xs needs to be sorted as well
			// find next unused coord in this xs column
			while( banks.xs[bank.cbb.x1][y] !== undefined ) {
				y += 1;
			}
			banks.xs[bank.cbb.x1][y] = bank;
			banks.xs_max_length = Math.max(banks.xs_max_length, banks.xs.length);

			if (banks.ys[bank.cbb.y1] === undefined) {
				banks.ys[bank.cbb.y1] = [];
			}
			// each list of ys needs to be sorted as well
			// find next unused coord in this ys row
			while( banks.ys[bank.cbb.y1][x] !== undefined ) {
				x += 1;
			}
			banks.ys[bank.cbb.y1][x] = bank;

			// are banks only on an edge? assume true and
			// set to false if find a bank that isn't...
			if (bank.cbb.x1 !== chip_rect.x1 
				&& bank.cbb.x1 !== chip_rect.x2
				&& bank.cbb.y1 !== chip_rect.y1
				&& bank.cbb.y1 !== chip_rect.y2) {
				// not on an edge...
				banks.edges.use = false;
			}
		});

		if (banks.edges.use) {
			// use layout for edge-based banks layout (i.e., 28nm)
			
			// remember the edges
			banks.edges.top = banks.ys[chip_rect.y1];
			banks.edges.bot = banks.ys[chip_rect.y2];
			banks.edges.left = banks.xs[chip_rect.x1];
			banks.edges.right = banks.xs[chip_rect.x2];

			if (banks.edges.top === undefined) {banks.edges.top = [];}
			if (banks.edges.bot === undefined) {banks.edges.bot = [];}
			if (banks.edges.left === undefined) {banks.edges.left = [];}
			if (banks.edges.right === undefined) {banks.edges.right = [];}

			// layout alrogithm:
			// 1. y for top is 0
			// 2. y for bot is max banks in left/right + 1
			// 3. x for left is 0
			// 4. x for right is max banks in top/bot + 1

			(function () {
				// layout edge banks here...
				var keys = {};
				banks.edges.rect = {}
				banks.edges.rect.x1 = 0;
				banks.edges.rect.y1 = 0;
				banks.edges.rect.x2 = Math.max(Object.keys(banks.edges.top).length, Object.keys(banks.edges.bot).length) + 1;
				banks.edges.rect.y2 = Math.max(Object.keys(banks.edges.left).length, Object.keys(banks.edges.right).length) + 1;

				// extents of bank layout are in rect...

				// for top...
				keys = Object.keys(banks.edges.top);
				keys.forEach(function (key, i) {
					var bank = banks.edges.top[key];
					bank.svbb = {};
					bank.svbb.x1 = i + 1;
					bank.svbb.x2 = i + 1;
					bank.svbb.y1 = banks.edges.rect.y1;
					bank.svbb.y2 = banks.edges.rect.y1;
				});
				// for bot...
				keys = Object.keys(banks.edges.bot);
				keys.forEach(function (key, i) {
					var bank = banks.edges.bot[key];
					bank.svbb = {};
					bank.svbb.x1 = i + 1;
					bank.svbb.x2 = i + 1;
					bank.svbb.y1 = banks.edges.rect.y2;
					bank.svbb.y2 = banks.edges.rect.y2;
				});
				// for left...
				keys = Object.keys(banks.edges.left);
				keys.forEach(function (key, i) {
					var bank = banks.edges.left[key];
					bank.svbb = {};
					bank.svbb.x1 = banks.edges.rect.x1;
					bank.svbb.x2 = banks.edges.rect.x1;
					bank.svbb.y1 = i + 1;
					bank.svbb.y2 = i + 1;
				});
				// for right...
				keys = Object.keys(banks.edges.right);
				keys.forEach(function (key, i) {
					var bank = banks.edges.right[key];
					bank.svbb = {};
					bank.svbb.x1 = banks.edges.rect.x2;
					bank.svbb.x2 = banks.edges.rect.x2;
					bank.svbb.y1 = i + 1;
					bank.svbb.y2 = i + 1;
				});
			})();
		} else {
			// use layout for column-based bank layout (i.e., nf)
			// the 'xs' array is all we need?

			(function () {
				// layout column banks here...
				banks.cols = {};
				banks.cols.rect = {}
				banks.cols.rect.x1 = 0;
				banks.cols.rect.y1 = 0;
				banks.cols.rect.x2 = 0;
				banks.cols.rect.y2 = 0;

				// extents of bank layout are in rect...

				var keys = Object.keys(banks.xs);
				keys.forEach(function (key, i) {
					// for each column
					var skeys = Object.keys(banks.xs[key]);
					var x1 = i;
					var x2 = x1 - 0.1; // leave some whitespace between columns
					
					// record x as we go, so we end up with max x in the bank rect
					banks.cols.rect.x2 = x2;
					// add 2 to length for top and bottom
					// subtract 1 because we start counting at 0
					banks.cols.rect.y2 = Math.max(banks.cols.rect.y2, Object.keys(banks.xs[key]).length + 2 - 1);

					skeys.forEach(function (skey, j) {
						var bank = banks.xs[key][skey],
							y1 = 0
							y2 = 0;
						// banks in the top/bottom need to remain in the top/bottom
						// all others go in between: others need to increment j by 1
						// to go in correct spot
						if (bank.cbb.y1 == chip_rect.y1) {
							// top edge ios
							y1 = 0;
						} else if (bank.cbb.y1 == chip_rect.y2) {
							// bottom edge ios
							y2 = banks.xs_max_length + 1;
						} else {
							// "core" ios
							y1 = j + 1;
						}
						y2 = y1;
						
						bank.svbb = {};
						bank.svbb.x1 = x1;
						bank.svbb.x2 = x2;
						bank.svbb.y1 = y1;
						bank.svbb.y2 = y2;
					});
				});
			})();
			
		}

		(function () {
			// generalized layout... somewhat ugly for both edge and column-based
			// iterate through each y-bank and assign new y-value based on position in list
			var keys = Object.keys(banks.ys);
			keys.forEach(function (key, i) {
				var skeys = Object.keys(banks.ys[key]);
				// record i as we go, so we end up with max i in the bank rect
				banks.rect = {};
				banks.rect.y1 = 0;
				banks.rect.y2 = i;

				skeys.forEach(function (skey) {
					var bank = banks.ys[key][skey];
					
					bank.bvbb = {};
					bank.bvbb.y1 = i;
					bank.bvbb.y2 = i;
				});
			});

			// iterate through each x-bank and assign new x value based on position in list
			var keys = Object.keys(banks.xs);
			keys.forEach(function (key, i) {
				var skeys = Object.keys(banks.xs[key]);
				// record i as we go, so we end up with max i in the bank rect
				banks.rect.x1 = 0;
				banks.rect.x2 = i;

				skeys.forEach(function (skey, j) {
					var bank = banks.xs[key][skey];
					bank.bvbb.x1 = i;
					bank.bvbb.x2 = i;
				});
			});
		})();

		// copy the correct bank bbox to bank.bb for use by layout
		// ditto with max values for bank.rect
		switch (layout_type) {
			case "ugly":
				banks.rect = banks.rect;
				banks.forEach(function (bank) {
					bank.bb = {};
					bank.bb = bank.bvbb;
				});
				break;
			case "special":
				if (banks.edges.use) {
					banks.rect = banks.edges.rect;
				} else {
					// must be columngs...
					banks.rect = banks.cols.rect;
				}
				banks.forEach(function (bank) {
					bank.bb = {};
					bank.bb = bank.svbb;
				});
				break;
			case "centroid":
				banks.rect = chip_rect;
				banks.forEach(function (bank) {
					bank.bb = {};
					bank.bb = bank.cbb;
				});
				break;
			case "bbox":
			default:
				banks.rect = chip_rect;
				banks.forEach(function (bank) {
					bank.bb = {};
					bank.bb = bank.xbb;
				});
				break;
		}
	}

	//
	// code
	//

	massage_banks(banks);

	chip_drawing(banks, cell_table_key);
}

