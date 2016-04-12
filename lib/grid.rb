class Point3D

	attr_accessor :location

	def initialize(x: 0, y: 0, z: 0)
		@location = {x: x, y: y, z: z}
	end

	def [](i)
		@location[i]
	end

	def left!(j)
		@location[:x] -= j
		self
	end

	def left(j)
		new_loc = @location.dup
		new_loc[:x] -= j
		Point3D.new(x: new_loc[:x], y: new_loc[:y], z: new_loc[:z])
	end

	def right!(j)
		@location[:x] += j
		self
	end

	def right(j)
		new_loc = @location.dup
		new_loc[:x] += j
		Point3D.new(x: new_loc[:x], y: new_loc[:y], z: new_loc[:z])
	end

	def up!(j)
		@location[:y] -= j
		self
	end

	def up(j)
		new_loc = @location.dup
		new_loc[:y] -= j
		Point3D.new(x: new_loc[:x], y: new_loc[:y], z: new_loc[:z])
	end

	def down!(j)
		@location[:y] += j
		self
	end

	def down(j)
		new_loc = @location.dup
		new_loc[:y] += j
		Point3D.new(x: new_loc[:x], y: new_loc[:y], z: new_loc[:z])
	end

	def higher!(z)
		@location[:z] += z
		self
	end

	def higher(z)
		new_loc = @location.dup
		new_loc[:z] += z
		Point3D.new(x: new_loc[:x], y: new_loc[:y], z: new_loc[:z])
	end

	def lower!(z)
		@location[:z] -= z
		self
	end

	def lower(z)
		new_loc = @location.dup
		new_loc[:z] -= z
		Point3D.new(x: new_loc[:x], y: new_loc[:y], z: new_loc[:z])
	end

end

class GridOfSquares
	attr_accessor :window_width, :window_height, :box_side_length,
	              :row_count, :column_count, :row_pixel_coords, :col_pixel_coords

	def initialize(width: 900, height: 600, box_side: 30)
		@window_width    = width
		@window_height   = height
		@box_side_length = box_side

		@row_count    = @window_height / @box_side_length
		@column_count = @window_width  / @box_side_length

		@row_pixel_coords =    (0..@row_count).map{ |j| j * @box_side_length }
		@col_pixel_coords = (0..@column_count).map{ |i| i * @box_side_length }

	end

	# x and y are the x'th and y'th grid boxes, counting from the top left of the window
	# later on we will prefer to use grid box coordinates instead of pixel coordinates
	def pixel_top_left(x, y)
		Point3D.new(x: x * @box_side_length, y: y * @box_side_length)
	end

	def pixel_top_right(x, y)
		Point3D.new(x: (x + 1) * @box_side_length, y: y * @box_side_length)
	end

	def pixel_bottom_left(x, y)
		Point3D.new(x: x * @box_side_length, y: (y + 1) * @box_side_length)
	end

	def pixel_bottom_right(x, y)
		Point3D.new(x: (x + 1) * @box_side_length, y: (y + 1) * @box_side_length)
	end

# fix this
	def pixel_center_of_side(side)
		case side
			when :top then "something"
			when :bottom then "something"
			when :left then "something"
			when :right then "something"
		end
	end

# fix this
	def pixel_center
		#something
	end
end

