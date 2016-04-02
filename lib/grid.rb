require 'matrix'

class Point

	attr_accessor :loc

	def initialize(x, y)
		@loc = {x: x, y: y}
	end

	def [](i)
		@loc[i]
	end

	def left!(j)
		@loc[:x] -= j
		self
	end

	def left(j)
		new_loc = @loc.dup
		new_loc[:x] -= j
		Point.new(new_loc[:x], new_loc[:y])
	end

	def right!(j)
		@loc[:x] += j
		self
	end

	def right(j)
		new_loc = @loc.dup
		new_loc[:x] += j
		Point.new(new_loc[:x], new_loc[:y])
	end

	def up!(j)
		@loc[:y] -= j
		self
	end

	def up(j)
		new_loc = @loc.dup
		new_loc[:y] -= j
		Point.new(new_loc[:x], new_loc[:y])
	end

	def down!(j)
		@loc[:y] += j
		self
	end

	def down(j)
		new_loc = @loc.dup
		new_loc[:y] += j
		Point.new(new_loc[:x], new_loc[:y])
	end

	def here
		new_loc = @loc.dup
		Point.new(new_loc[:x], new_loc[:y])
	end

	def here!
		self
	end

end

class SquareGrid
	attr_accessor :window_width, :window_height, :box_width, :box_height,
	              :row_count, :column_count, :row_coords, :col_coords, :grid_index,
	              :partial_row, :partial_col

	def initialize(ww, wh, bw, bh, offset: 0)
		@window_width  = ww
		@window_height = wh
		@box_width     = bw
		@box_height    = bh

		@row_count    = (@window_height / @box_height)
		@column_count = (@window_width  / @box_width)

		@row_coords =    (0..@row_count).map{ |j| j * @box_height }
		@col_coords = (0..@column_count).map{ |i| i * @box_width }

	end

	# x and y are the x'th and y'th grid boxes, counting from the top left of the window
	# later on we will prefer to use grid box coordinates instead of pixel coordinates
	def top_left(x, y)
		Point.new( x * @box_width, y * @box_height)
	end

	def top_right(x, y)
		Point.new( (x + 1) * @box_width, y * @box_height)
	end

	def bottom_left(x, y)
		Point.new( x * @box_width, (y + 1) * @box_height)
	end

	def bottom_right(x, y)
		Point.new( (x + 1) * @box_width, (y + 1) * @box_height)
	end

end

module SquareGridMethodsGosu

	# draw_quad and draw_rect are methods in the Gosu module, the difference being
	# that draw_quad can draw other kinds of quadrilateral shapes, such as
	# parallelograms (including rotated squares and rectangles), rhombuses, and
	# trapezoids, since the locations of all four vertices must be specified

	# the Gosu methods are wrapped to set defaults for fill_color, opacity, and z,
	# and to make use of the Point class to use one argument per vertex

	# this wrapper conceals the color gradient functionality of the original
	def make_quad(tl, tr, bl, br, fill_color = BLUE, opacity = 255, z = 0)
		fill_color.alpha = opacity
		draw_quad(tl[:x], tl[:y], fill_color,
			        tr[:x], tr[:y], fill_color,
			        bl[:x], bl[:y], fill_color,
			        br[:x], br[:y], fill_color, z)
	end

	# th
	def highlight_cell(x, y, fill_color = BLUE, opacity = 255, z = 0)
		fill_color.alpha = opacity
		tl, tr, bl, br = @grid.top_left(x, y),                 @grid.top_right(x, y),
		                 @grid.bottom_left(x, y),              @grid.bottom_right(x, y)
		make_quad(tl, tr.left!(1), bl.up!(1), br.left!(1).up!(1), fill_color, opacity, z)
	end

	def highlight_cells(cells, fill_color = GRAY, opacity = 255, z = 0)
		cells.each do |x,y|
			highlight_cell(x, y, fill_color, opacity, z)
		end
	end

	def highlight_cell_border(x, y, fill_color = GREEN, opacity = 255, z = 0, thickness: 0)

		fill_color.alpha = opacity
		tl, tr, bl, br = @grid.top_left(x, y),                 @grid.top_right(x, y),
		                 @grid.bottom_left(x, y),              @grid.bottom_right(x, y)

		make_quad( tl, 				          tr.left(thickness),
							 tl.down!(thickness), tr.left(thickness).down!(thickness),
							 fill_color, opacity, z )

		make_quad( tr.left(thickness),                tr,
							 br.left(thickness).up!(thickness), br.up!(thickness),
							 fill_color, opacity, z )

		make_quad( bl.right(thickness).up!(thickness), br.up!(thickness),
			 				 bl.right(thickness),                br,
			 				 fill_color, opacity, z )

		make_quad( tl.down!(thickness),     tl.right(thickness).down!(thickness),
			         bl,                      bl.right(thickness),
			         fill_color, opacity, z)
	end

	def highlight_row(y, fill_color = WHITE, opacity = 50, z = 0)
		tl, tr, bl, br = @grid.top_left(0,y),                @grid.top_right(@grid.column_count,y),
		 				 				 @grid.bottom_left(0,y),             @grid.bottom_right(@grid.column_count,y)
		make_quad(tl, tr, bl, br, fill_color, opacity, z)
	end

	def highlight_col(x, fill_color = WHITE, opacity = 50, z = 0)
		tl, tr, bl, br = @grid.top_left(x,0),                @grid.top_right(x,0),
						 				 @grid.bottom_left(x,@grid.column_count), @grid.bottom_right(x,@grid.column_count)
		make_quad(tl, tr, bl, br, fill_color, opacity, z)
	end

	def mouseover_cell
		mouse_cell_x = ( (mouse_x).to_i / @grid.box_width.to_i)
		mouse_cell_y = ( (mouse_y).to_i / @grid.box_height.to_i)
		{x: mouse_cell_x, y: mouse_cell_y}
	end

	def highlight_mouseover_cell(fill_color = BLUE, opacity = 100, z = 0)
		cell = mouseover_cell
	  	highlight_cell(cell[:x], cell[:y], fill_color, opacity, z)
	end

	def highlight_mouseover_row(fill_color = BLUE, opacity = 100, z = 0)
		cell = mouseover_cell
		highlight_row(cell[:y], fill_color, opacity, z)
	end

	def highlight_mouseover_col(fill_color = BLUE, opacity = 100, z = 0)
		cell = mouseover_cell
		highlight_col(cell[:x], fill_color, opacity, z)
	end

	def draw_arrow(x, y, color = RED, z = 0, stem: 15, thickness: 4, head: 15, flare: 10)
		draw_quad(x, y, color, x + stem, y, color, x, y + thickness, color, x + stem, y + thickness, color, z)
		draw_triangle(x + stem, y - flare / 2, color, x + stem + head, y + thickness / 2, color, x + stem, y + thickness + flare / 2, color, z)
	end

	def direction_arrow(x, y, color = RED, z = 0, side: :left, facing: :out, stem: 15, thickness: 4, head: 15, flare: 10)
		x_to_center = (stem + head) / 2
		y_to_center = thickness / 2
		case side
		when :left
			facing == :out ? rot = 180 : rot = 0
			pt = @grid.top_left(x, y)
			arrow_x = pt[:x] - x_to_center
			arrow_y = pt[:y] + @grid.box_height / 2
			scale(@grid.box_width / 50.0, @grid.box_height / 50.0, arrow_x + x_to_center, arrow_y + y_to_center) do
				rotate(rot, arrow_x + x_to_center, arrow_y + y_to_center) do
					draw_arrow(arrow_x, arrow_y, color, z, stem: stem, thickness: thickness, head: head, flare: flare)
				end
			end
		when :right
			facing == :out ? rot = 0 : rot = 180
			pt = @grid.top_right(x,y)
			arrow_x = pt[:x] - x_to_center
			arrow_y = pt[:y] + @grid.box_height / 2
			scale(@grid.box_width / 50.0, @grid.box_height / 50.0, arrow_x + x_to_center, arrow_y + y_to_center) do
				rotate(rot, arrow_x + x_to_center, arrow_y + y_to_center) do
					draw_arrow(arrow_x, arrow_y, color, z, stem: stem, thickness: thickness, head: head, flare: flare)
				end
			end
		when :top
			facing == :out ? rot = 270 : rot = 90
			pt = @grid.top_left(x, y)
			arrow_x = pt[:x] + @grid.box_width / 2 - x_to_center
			arrow_y = pt[:y]
			scale(@grid.box_width / 50.0, @grid.box_height / 50.0, arrow_x + x_to_center, arrow_y + y_to_center) do
				rotate(rot, arrow_x + x_to_center, arrow_y + y_to_center) do
					draw_arrow(arrow_x, arrow_y, color, z, stem: stem, thickness: thickness, head: head, flare: flare)
				end
			end
		when :bottom
			facing == :out ? rot = 90 : rot = 270
			pt = @grid.bottom_left(x,y)
			arrow_x = pt[:x] + @grid.box_width / 2 - x_to_center
			arrow_y = pt[:y]
			scale(@grid.box_width / 50.0, @grid.box_height / 50.0, arrow_x + x_to_center, arrow_y + y_to_center) do
				rotate(rot, arrow_x + x_to_center, arrow_y + y_to_center) do
					draw_arrow(arrow_x, arrow_y, color, z, stem: stem, thickness: thickness, head: head, flare: flare)
				end
			end
		end
	end

	def draw_grid_text(x, y, txt, font)
		pt = @grid.top_left(x, y)
		horiz_adjust = (@grid.box_width - font.text_width("#{txt}")) / 2
		vert_adjust = (@grid.box_height - font.height) / 2
		font.draw("#{txt}", pt.right!(horiz_adjust)[:x], pt.down!(vert_adjust)[:y], 0, 1, 1, BLACK)
	end
#this should be a graph method
	def reconstruct_path(x, y)
		path = []
		node = @graph[[x,y].to_s]
		if node.visited?
			node.destination_dist.times do
				path << node.coord
				new_node_coord = node.destination_coord
				node = @graph[new_node_coord.to_s]
			end
		end
		path
	end

#this should be a graph method
	def within_dist(d)
		list = []
		@graph.nodes.each do |k,v|
			dist = v.destination_dist
			if dist <= d && dist != 0 then list << v.coord end
		end
		list
	end

end

module SquareGridMethodsCLI



end