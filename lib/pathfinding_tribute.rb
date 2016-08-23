
require 'gosu'
require_relative 'searcher'

class Pathfinding < Gosu::Window
  def initialize(width: 900, height: 600, box_side: 30)

    super width, height
    self.caption = "Pathfinding Tribute"

    @grid = GridOfSquares.new(width: width, height: height, box_side: box_side)
    @graph = PathfindingGraph.new

    coordinates = @grid.generate_coordinates

    coordinates.each do |coord|
      @graph.add_node_at(coord)
    end

    coordinates.each do |coord|
      @graph.connect_node_at(coord)
    end

    x_rand = @grid.random_x_coordinate
    y_rand = @grid.random_y_coordinate
    @graph.sink_node = @graph[{x: x_rand, y: y_rand, z: 0}]

    @searcher = GraphSearcher.new(graph: @graph)

    # resource used to draw distances in grid boxes
    @arial = Gosu::Font.new(self, "arial", 20)

    @run_sim = false
    @show_distances = true

  end

  def update
    if @run_sim == true
      sleep(0.1)
      @searcher.step_forward
    end
  end

  def draw
    mouseover_cell = @grid.mouseover_cell({x: mouse_x, y: mouse_y})

    @graph.all_nodes.each do |node|
      if node.visited?
        @grid.fill_cell(node.location, VISITED_NODE_COLOR)
      else
        @grid.fill_cell(node.location, UNVISITED_NODE_COLOR)
      end
    end

    @graph.all_removed_nodes.each do |node|
      @grid.fill_cell(node.location, WALL_NODE_COLOR)
    end

    @searcher.fringe.each do |fringe_node|
      @grid.fill_cell(fringe_node.location, FRINGE_NODE_COLOR)
    end

    @grid.fill_cell(@graph.sink_node.location, SINK_NODE_COLOR)

    @searcher.adjacent_nodes.each do |node|
      @grid.fill_border(node.location)
    end

    @graph.all_nodes.each do |node|
      loc = node.location
      dist = @graph.node_at(loc).destination_distance
      @grid.draw_text(loc, dist, @arial) unless dist == Float::INFINITY || @show_distances == false
    end

    @grid.fill_cell(mouseover_cell)

  end

  def button_down(id)
    case id
    when Gosu::KbD
      @show_distances == true ? @show_distances = false : @show_distances = true
    when Gosu::KbP
      @run_sim == true ? @run_sim = false : @run_sim = true
    when Gosu::KbSpace
      @searcher.step_forward
    when Gosu::MsLeft
      coord = @grid.mouseover_cell({x: mouse_x, y: mouse_y})
      if @graph.is_a_wall_at?(coord)
        @graph.make_passable_at(coord)
        @searcher.redo_search
      elsif @graph.is_a_path_at?(coord)
        @graph.make_wall_at(coord)
        @searcher.redo_search
      end
    end
  end
end

window = Pathfinding.new
window.show