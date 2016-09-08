#TODO: right click should cycle between edge weights 2,3,4,5
#TODO: nodes with edge weight of 2 should be light forest, 3 dark forest, 4 light water, 5 dark water
#TODO: save and load (and reset) last graph
#TODO: arrow keys should move around the current node
#TODO: make the 's' key set the source to the current node
#TODO: limit the number of paths highlighted to some reasonable number, and choose them randomly
#TODO: spawn squares at the source and have them move randomly towards the sink (and let there be multiple sources)
#TODO: create a slider UI element to move the simulation forward and backwards
#TODO: randomly assign edge weights to nodes

#TODO: HEXES!

require 'gosu'
require_relative 'searcher'

class Pathfinding < Gosu::Window
  def initialize(width: 600, height: 600, box_side: 40)

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
    @show_arrows = true
    @nodes_within = 0

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

      case node.cost_to_enter
      when 2
        @grid.fill_cell(node.location, LIGHT_GREEN)
      when 3
        @grid.fill_cell(node.location, DARK_GREEN)
      when 4
        @grid.fill_cell(node.location, LIGHT_BLUE)
      when 5
        @grid.fill_cell(node.location, DARK_BLUE)
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

      if node.destination_distance <= @nodes_within
        @grid.fill_cell(node.location, YELLOW, 100)
      end

      if node.destination_directions != []
        if @show_arrows == true
          node.destination_directions.each do |dir|
            @grid.direction_arrow(node.location, side: dir)
          end
        end
      end
    end

    @searcher.paths.each do |path|
      path.each do |node|
        @grid.fill_cell(node.location, YELLOW, 5)
      end
    end

    @grid.fill_cell(mouseover_cell)

  end

  def button_down(id)
    case id
    when Gosu::KbA
      @show_arrows == true ? @show_arrows = false : @show_arrows = true
    when Gosu::KbD
      @show_distances == true ? @show_distances = false : @show_distances = true
    when Gosu::KbP
      @run_sim == true ? @run_sim = false : @run_sim = true
    when Gosu::KbR
      @searcher.reset_search
    when Gosu::KbSpace
      @searcher.step_forward
    when Gosu::Kb1
      @nodes_within = 1
    when Gosu::Kb2
      @nodes_within = 2
    when Gosu::Kb3
      @nodes_within = 3
    when Gosu::Kb4
      @nodes_within = 4
    when Gosu::Kb5
      @nodes_within = 5
    when Gosu::Kb6
      @nodes_within = 6
    when Gosu::Kb7
      @nodes_within = 7
    when Gosu::Kb8
      @nodes_within = 8
    when Gosu::Kb9
      @nodes_within = 9
    when Gosu::Kb0
      @nodes_within = 0
    when Gosu::MsLeft
      coord = @grid.mouseover_cell({x: mouse_x, y: mouse_y})
      if @graph.is_a_wall_at?(coord)
        @graph.make_passable_at(coord)
        @searcher.redo_search
      elsif @graph.is_a_path_at?(coord)
        @graph.make_wall_at(coord)
        @searcher.redo_search
      end
    when Gosu::MsRight
      coord = @grid.mouseover_cell(x: mouse_x, y: mouse_y)
      node = @graph.node_at(coord)
      weight = node.cost_to_enter
      if weight != 5
        node.cost_to_enter += 1
      else
        node.cost_to_enter = 1
      end
    end
  end
end

window = Pathfinding.new
window.show