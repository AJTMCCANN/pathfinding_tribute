require "pathfinding_tribute/version"
require 'gosu'
require 'minigl'
require 'pry'
require_relative 'player'
require_relative 'text_field'
require_relative 'colors'

include MiniGL

#TODO: a grid and a graph together should be a new type of object, and have its own class
#TODO: nodes should know who they've been visited by, not just that they've been visited.
#TODO: there should be a command line ascii version of the graphics
#TODO: the simulation should be able to save and load different maps
#TODO: holding down the button should let you drag many wall squares into existence, or out
#TODO: the simulation should be able to run entirely in teh abstract, without being drawn
#TODO: refer to 'boxes' as 'cells'
#TODO: change references to 'open' to 'fringe'
#TODO: turn node coordinates into points, using the Point class
#TODO: deleted nodes should be stored as nodes, not as just coordinates (if so, will their edges still need to be recreated if they are reinserted into the graph?)
#      should there be a policy that nodes store their own outgoing edges only, and that
#      nodes shouldn't store incoming edges?  Or should there be a collection of edges,
#      just like there's a collection of nodes? maybe then nodes just store references
#      to the edge collection

#TODO: removing a node from a graph should add it to the deleted nodes list, unless some additional argument is specified


#TODO: move as much code as possible into grid.rb, such as teleport code
#TODO: cells that are made to be unreachable should have their colour changed too
#TODO: find out why the game crashes if you click on the starting location, and fix it
#TODO: use minigl to create controls in the game, so that buttons can be unbound
#TODO: implement an alternative highlight_cell_border function that uses layers
#TODO: checkbox to show arrows of equivalent paths
#TODO: in game controls should include, changing box size, changing grid size,
#      checkbox for showing arrows, text field for highlighting all within a certain distance,
#      buttons for stop, play, forward, back.  text field for play speed.  checkbox for highlighting
#      mouse row and mouse column.  button to randomize start position. map key to change start position
#TODO: make an end position, where the play terminates.  map key to change this position, button to randomize
#TODO: based on end position, probably A* can be implemented
#TODO: implement switching between grid view and graph view
#TODO: implement Djikstra's algorithm (weighted edges).  bo
#TODO: buttons to change search order (i.e. top, right, bottom, left)

class Pathfinding < GameWindow
  include SquareGridMethodsGosu

  def initialize
    super 800, 600, false
    self.caption   = "Grids"

    @step_count    = 0

    grid_and_graph = build_grid_and_graph(width, height, 30, 30, 3, 3, 10, 10)
    @grid          = grid_and_graph[:grid]
    @graph         = grid_and_graph[:graph]

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

  def redo_sim(back: 0)
    @path           = []
    @cells_within_d = []
    @player.fringe    = []
    @graph.nodes.each do |k,v|
      v.visited          = false
      v.destination_direction  = nil
      v.destination_distance = 0
    end
    @player.teleport(@starting_node[0], @starting_node[1])
    @player.update
    @step_count -= back
    @step_count.times do
      next_loc = @player.fringe.pop
      @player.teleport(next_loc[0], next_loc[1]) if next_loc != nil
    end
    @path = reconstruct_path(@old_path[0][0], @old_path[0][1]) if @show_path == true
    @cells_within_d = within_dist(@old_dist) if @show_within_d == true
  end

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

  def increment_sim
    next_loc = @player.fringe.pop
    if next_loc != nil
      @player.teleport(next_loc[0], next_loc[1])
      @step_count += 1
    else
      @run_sim = false
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

    @graph.nodes.each do |k,v|
      case v.destination_direction
      when [0,1]
        direction_arrow(v.coord[0], v.coord[1], BLUE, side: :top, facing: :out)
      when [1,0]
        direction_arrow(v.coord[0], v.coord[1], RED, side: :left, facing: :out)
      when [0,-1]
        direction_arrow(v.coord[0], v.coord[1], GREEN, side: :bottom, facing: :out)
      when [-1,0]
        direction_arrow(v.coord[0], v.coord[1], YELLOW, side: :right, facing: :out)
      end

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
end

window = Pathfinding.new
window.show
