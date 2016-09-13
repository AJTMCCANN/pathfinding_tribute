require_relative 'colors'

class GridPoint3D

	attr_accessor :location

	def initialize(loc: nil, x: 0, y: 0, z: 0)
    if loc == nil
		  @location = {x: x, y: y, z: z}
    else
      @location = loc
    end
	end

	def [](i)
		@location[i]
	end

  # these methods let you define points relative to other points (be they
  # pixel coordinates or grid coordinates), which is often more convenient
  # than using absolute references
	def left(j)
		new_loc = @location.dup
		new_loc[:x] -= j
		GridPoint3D.new(x: new_loc[:x], y: new_loc[:y], z: new_loc[:z])
	end

	def right(j)
		new_loc = @location.dup
		new_loc[:x] += j
		GridPoint3D.new(x: new_loc[:x], y: new_loc[:y], z: new_loc[:z])
	end

	def up(j)
		new_loc = @location.dup
		new_loc[:y] -= j
		GridPoint3D.new(x: new_loc[:x], y: new_loc[:y], z: new_loc[:z])
	end

	def down(j)
		new_loc = @location.dup
		new_loc[:y] += j
		GridPoint3D.new(x: new_loc[:x], y: new_loc[:y], z: new_loc[:z])
	end

	def higher(z)
		new_loc = @location.dup
		new_loc[:z] += z
		GridPoint3D.new(x: new_loc[:x], y: new_loc[:y], z: new_loc[:z])
	end

	def lower(z)
		new_loc = @location.dup
		new_loc[:z] -= z
		GridPoint3D.new(x: new_loc[:x], y: new_loc[:y], z: new_loc[:z])
	end

end

class GridOfSquares
	attr_accessor :window_width, :window_height, :box_side_length,
	              :row_count, :column_count

	def initialize(width: 900, height: 600, box_side: 30)
		@window_width    = width
		@window_height   = height
		@box_side_length = box_side

		@row_count    = @window_height / @box_side_length
		@column_count = @window_width  / @box_side_length

	end

  # the list of coordinates is used later on to generate one node per coordinate
  def generate_coordinates
    coordinates = []
    (0..@column_count - 1).to_a.each do |i|
      (0..@row_count - 1).to_a.each do |j|
        coordinates << {x: i, y: j, z: 0}
      end
    end
    coordinates
  end

  # these methods are for randomizing the sink node location
  def random_x_coordinate
    (rand(0..(@column_count)-1).to_i)
  end

  def random_y_coordinate
    (rand(0..(@row_count)-1).to_i)
  end

  # determines the mouse's grid coordinates
  def mouseover_cell(loc)
    mouse_cell_x = loc[:x].to_i / @box_side_length.to_i
    mouse_cell_y = loc[:y].to_i / @box_side_length.to_i
    {x: mouse_cell_x, y: mouse_cell_y, z: 0}
  end

	# these methods let us use grid box coordinates instead
  # of pixel coordinates when drawing to screen
	def pixel_top_left(grid_x, grid_y)
		GridPoint3D.new(x: grid_x * @box_side_length, y: grid_y * @box_side_length)
	end

	def pixel_top_right(grid_x, grid_y)
		GridPoint3D.new(x: (grid_x + 1) * @box_side_length, y: grid_y * @box_side_length)
	end

	def pixel_bottom_left(grid_x, grid_y)
		GridPoint3D.new(x: grid_x * @box_side_length, y: (grid_y + 1) * @box_side_length)
	end

	def pixel_bottom_right(grid_x, grid_y)
		GridPoint3D.new(x: (grid_x + 1) * @box_side_length, y: (grid_y + 1) * @box_side_length)
	end

  # make_quad wraps Gosu's draw_quad, reducing the number of arguments and
  # hiding the gradient-fill functionality;
  # tl, tr, bl, and br are expected to be GridPoint3D objects
  def make_quad(tl, tr, bl, br, fill_color = BLUE, opacity = 255, z = 0)
    fill_color.alpha = opacity
    Gosu.draw_quad(tl[:x], tl[:y], fill_color,
              tr[:x], tr[:y], fill_color,
              bl[:x], bl[:y], fill_color,
              br[:x], br[:y], fill_color, z)
  end

  # reducing the number of arguments and the functionality further
  # so a cell can be filled by referencing its grid coordinates
  def fill_cell(loc = {}, fill_color = BLUE, opacity = 255)
    fill_color.alpha = opacity
    tl, tr, bl, br = pixel_top_left(loc[:x], loc[:y]),    pixel_top_right(loc[:x], loc[:y]),
                     pixel_bottom_left(loc[:x], loc[:y]), pixel_bottom_right(loc[:x], loc[:y])
    make_quad(tl, tr.left(1), bl.up(1), br.left(1).up(1), fill_color, opacity, loc[:z])
  end

  # the cells adjacent to the searcher's current position use filled borders
  def fill_border(loc, fill_color = GREEN, opacity = 255, thickness: 4)
    fill_color.alpha = opacity
    tl, tr, bl, br = pixel_top_left(loc[:x], loc[:y]),    pixel_top_right(loc[:x], loc[:y]),
                     pixel_bottom_left(loc[:x], loc[:y]), pixel_bottom_right(loc[:x], loc[:y])

    make_quad( tl, tr.left(thickness), tl.down(thickness),
               tr.left(thickness).down(thickness), fill_color, opacity, loc[:z] )

    make_quad( tr.left(thickness), tr, br.left(thickness).up(thickness),
               br.up(thickness), fill_color, opacity, loc[:z] )

    make_quad( bl.right(thickness).up(thickness), br.up(thickness),
               bl.right(thickness), br, fill_color, opacity, loc[:z] )

    make_quad( tl.down(thickness), tl.right(thickness).down(thickness),
               bl, bl.right(thickness), fill_color, opacity, loc[:z])
  end

  # used to draw the distance from the sink node in the middle of each cell
  def draw_text(loc, txt, font)
    pt = pixel_top_left(loc[:x], loc[:y])
    horiz_adjust = (@box_side_length - font.text_width("#{txt}")) / 2
    vert_adjust = (@box_side_length - font.height) / 2
    font.draw("#{txt}", pt.right(horiz_adjust)[:x], pt.down(vert_adjust)[:y], 0, 1, 1, BLACK)
  end

  def draw_arrow(x, y, color = RED, z = 0, stem: 15, thickness: 4, head: 15, flare: 10)
    Gosu.draw_quad(x, y, color, x + stem, y, color, x, y + thickness, color, x + stem, y + thickness, color, z)
    Gosu.draw_triangle(x + stem, y - flare / 2, color, x + stem + head, y + thickness / 2, color, x + stem, y + thickness + flare / 2, color, z)
  end

  def direction_arrow(loc, color = RED, z = 0, side: :left, facing: :out, stem: 15, thickness: 4, head: 15, flare: 10)
    x_to_center = (stem + head) / 2
    y_to_center = thickness / 2
    case side
    when :left
      facing == :out ? rot = 180 : rot = 0
      pt = pixel_top_left(loc[:x], loc[:y])
      arrow_x = pt[:x] - x_to_center
      arrow_y = pt[:y] + @box_side_length / 2
      Gosu.scale(@box_side_length / 50.0, @box_side_length / 50.0, arrow_x + x_to_center, arrow_y + y_to_center) do
        Gosu.rotate(rot, arrow_x + x_to_center, arrow_y + y_to_center) do
          draw_arrow(arrow_x, arrow_y, color, z, stem: stem, thickness: thickness, head: head, flare: flare)
        end
      end
    when :right
      facing == :out ? rot = 0 : rot = 180
      pt = pixel_top_right(loc[:x], loc[:y])
      arrow_x = pt[:x] - x_to_center
      arrow_y = pt[:y] + @box_side_length / 2
      Gosu.scale(@box_side_length / 50.0, @box_side_length / 50.0, arrow_x + x_to_center, arrow_y + y_to_center) do
        Gosu.rotate(rot, arrow_x + x_to_center, arrow_y + y_to_center) do
          draw_arrow(arrow_x, arrow_y, color, z, stem: stem, thickness: thickness, head: head, flare: flare)
        end
      end
    when :up
      facing == :out ? rot = 270 : rot = 90
      pt = pixel_top_left(loc[:x], loc[:y])
      arrow_x = pt[:x] + @box_side_length / 2 - x_to_center
      arrow_y = pt[:y] - 2
      Gosu.scale(@box_side_length / 50.0, @box_side_length / 50.0, arrow_x + x_to_center, arrow_y + y_to_center) do
        Gosu.rotate(rot, arrow_x + x_to_center, arrow_y + y_to_center) do
          draw_arrow(arrow_x, arrow_y, color, z, stem: stem, thickness: thickness, head: head, flare: flare)
        end
      end
    when :down
      facing == :out ? rot = 90 : rot = 270
      pt = pixel_bottom_left(loc[:x], loc[:y])
      arrow_x = pt[:x] + @box_side_length / 2 - x_to_center
      arrow_y = pt[:y] - 2
      Gosu.scale(@box_side_length / 50.0, @box_side_length / 50.0, arrow_x + x_to_center, arrow_y + y_to_center) do
        Gosu.rotate(rot, arrow_x + x_to_center, arrow_y + y_to_center) do
          draw_arrow(arrow_x, arrow_y, color, z, stem: stem, thickness: thickness, head: head, flare: flare)
        end
      end
    end
  end

end