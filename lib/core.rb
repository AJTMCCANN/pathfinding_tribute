=begin
module SquareGridMethodsForGosu

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

    make_quad( tl,                  tr.left(thickness),
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
      arrow_y = pt[:y] - 2
      scale(@grid.box_width / 50.0, @grid.box_height / 50.0, arrow_x + x_to_center, arrow_y + y_to_center) do
        rotate(rot, arrow_x + x_to_center, arrow_y + y_to_center) do
          draw_arrow(arrow_x, arrow_y, color, z, stem: stem, thickness: thickness, head: head, flare: flare)
        end
      end
    when :bottom
      facing == :out ? rot = 90 : rot = 270
      pt = @grid.bottom_left(x,y)
      arrow_x = pt[:x] + @grid.box_width / 2 - x_to_center
      arrow_y = pt[:y] - 2
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
end

class Pathfinding < GameWindow

  attr_accessor :window_width, :window_height, :fullscreen, :update_interval, :title_bar, :kb_held_delay,
                :kb_held_interval, :double_click_delay

  def initialize(width: 800, height: 600, screen: false, interval: 20, caption: "Pathfinding", held_delay: 40,
                 held_interval: 20, dblclick_delay: 20)
    @window_width = width
    @window_height = height
    @fullscreen = screen
    @update_interval = interval
    @title_bar = caption
    @kb_held_delay = held_delay
    @kb_held_interval = held_interval
    @double_click_delay = dblclick_delay

    super(@window_width, @window_height, @fullscreen, nil, nil, nil, nil, nil, @kb_held_delay,
          @kb_held_interval, @double_click_delay)
    self.caption   = @title_bar

    grid_graph = GridGraph.new(width, height, 30, 30, 3, 3, 10, 10)
    @grid          = grid_graph.grid
    @graph         = grid_graph.graph

    @starting_node = [7,7]
    @player        = Player.new(@starting_node[0], @starting_node[1], @graph)
    @cursor        = Gosu::Image.new(self, "icons/S_Ice03.png", true)
    @eight_bit     = Gosu::Font.new(self, "fonts/ST01R.TTF", 30)
    @arial         = Gosu::Font.new(self, "arial", 20)

    @old_path = []
    @old_loc  = [0,0]
    @old_dist = 0

    @run_sim       = false
    @run_pry       = false
    @show_path     = false
    @show_within_d = false
  end

  def active_window
    self.text_input == nil ? "Main Window" : text_input.name
  end


  # all of these should be shortened by referring to functions in searcher.rb

  def button_down(id)
    case id
    when Gosu::KbReturn
      current_loc = [@player.current_loc[0], @player.current_loc[1]]
      @path       = reconstruct_path(current_loc[0], current_loc[1])
      @show_path == true && @old_path[0] == current_loc ? @show_path = false : @show_path = true
      @old_path   = @path
    when Gosu::KbD
      current_dist    = @graph[@player.current_loc.to_s].destination_dist
      current_loc     = [@player.current_loc[0], @player.current_loc[1]]
      @cells_within_d = within_dist(current_dist)
      @show_within_d == true && @old_loc == current_loc ? @show_within_d = false : @show_within_d = true
      @old_loc  = [@player.current_loc[0], @player.current_loc[1]]
      @old_dist = current_dist
    when Gosu::KbB
      redo_sim(back: 1)
    when Gosu::KbSpace
      increment_sim
    when Gosu::KbP
      @run_sim == true ? @run_sim = false : @run_sim = true
    when Gosu::KbW
      @run_pry = true
    when Gosu::KbQ
      puts "something else"
    when Gosu::KbR
      redo_sim(back: @step_count)
    when Gosu::KbLeft
      @player.go_left if @graph[@player.current_loc.to_s].goes_to?(@graph[@player.left.to_s])
    when Gosu::KbRight
      @player.go_right if @graph[@player.current_loc.to_s].goes_to?(@graph[@player.right.to_s])
    when Gosu::KbUp
      @player.go_up if @graph[@player.current_loc.to_s].goes_to?(@graph[@player.up.to_s])
    when Gosu::KbDown
      @player.go_down if @graph[@player.current_loc.to_s].goes_to?(@graph[@player.down.to_s])
    when Gosu::MsLeft
      ms = mouseover_cell
      if self.text_input == nil
        if @graph["[#{ms[:x]}, #{ms[:y]}]"]
          @graph.remove_node(@graph["[#{ms[:x]}, #{ms[:y]}]"])
          @graph.deleted_nodes << [ms[:x], ms[:y]]
          redo_sim
        elsif @graph["[#{ms[:x]}, #{ms[:y]}]"] == nil
          n = Node.new([ms[:x], ms[:y]].to_s,[ms[:x], ms[:y]])
          @graph.add_outgoing_edges(n)
          @graph.add_incoming_edges(n)
          @graph.deleted_nodes.delete([ms[:x], ms[:y]])
          redo_sim
        end
      end
    end
  end



  def update
    if @run_sim == true
      sleep(0.1)
      increment_sim
    end
    if @run_pry == true
      binding.pry
      @run_pry = false
    end
  end

  def draw

    @graph.nodes.each do |k,v|
      if v.visited? == true
        highlight_cell(v.coord[0], v.coord[1], VISITED_NODE_COLOR, 255)
      elsif v.visited? == false
        highlight_cell(v.coord[0], v.coord[1], UNVISITED_NODE_COLOR, 255)
      end
    end

    @player.fringe.each do |loc|
      highlight_cell(loc[0], loc[1], FRINGE_NODE_COLOR, 255)
    end

    highlight_cells(@cells_within_d) if @show_within_d

    highlight_cells(@path) if @show_path

    highlight_cell(@player.current_loc[0], @player.current_loc[1], PLAYER_COLOR, 255)

    highlight_cell(@starting_node[0], @starting_node[1], START_NODE_COLOR, 255)

    @player.adjacent.each do |loc|
      highlight_cell_border(loc[0], loc[1], ADJACENT_NODE_COLOR, 255) if @graph.has_node_named?(loc.to_s)
    end

    # @graph.nodes.each do |k,v|
    #   case v.destination_direction
    #   when [0,1]
    #     direction_arrow(v.coord[0], v.coord[1], BLUE, side: :top, facing: :out)
    #   when [1,0]
    #     direction_arrow(v.coord[0], v.coord[1], RED, side: :left, facing: :out)
    #   when [0,-1]
    #     direction_arrow(v.coord[0], v.coord[1], GREEN, side: :bottom, facing: :out)
    #   when [-1,0]
    #     direction_arrow(v.coord[0], v.coord[1], YELLOW, side: :right, facing: :out)
    #   end

      draw_grid_text(v.coord[0], v.coord[1], v.destination_distance, @arial) unless v.destination_distance == 0
    end

    @graph.deleted_nodes.each do |x,y|
      highlight_cell(x, y, WALL_NODE_COLOR, 255, 1)
    end

    highlight_mouseover_cell
    highlight_mouseover_row
    highlight_mouseover_col
    highlight_row(@player.current_loc[1])
    highlight_col(@player.current_loc[0])

    #@eight_bit.draw("#{)}", 50, height - 140, 0, 1, 1, RED)
    @eight_bit.draw("Player Loc: #{@player.current_loc.to_s}", 50, height - 110 ,2, 1, 1, RED)
    #@eight_bit.draw("Text Input: #{self.active_window}", 50, height - 80, 0, 1, 1, RED)

    @eight_bit.draw("X: #{mouseover_cell[:x]}", 50, height - 50, 2, 1, 1,  RED)
    @eight_bit.draw("Y: #{mouseover_cell[:y]}", 200, height - 50, 2, 1, 1, RED)
    @cursor.draw(mouse_x,mouse_y,2)
  end
=end
