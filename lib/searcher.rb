require_relative 'graph'
require 'pry'

class GraphSearcher
  attr_accessor :graph, :current_node, :adjacent_nodes, :fringe, :jump_count, :paths, :temp_paths

  def initialize(graph: PathfindingGraph.new)
    @graph           = graph
    @current_node    = @graph.sink_node
    @current_node.destination_distance = 0
    @adjacent_nodes  = {}
    @fringe          = []
    @jump_count      = 1
    @paths           = []
    @temp_paths      = []
    search_node(@current_node)
  end

  def search_node(node)
    @current_node         = node
    @adjacent_nodes       = @graph.adjacent_nodes_from(@current_node.location)
    @adjacent_nodes.each do |v|
      @fringe << v unless (@fringe.include?(v) || (v.visited?))
      possible_distance = @current_node.destination_distance + v.cost_to_enter
      if possible_distance <= v.destination_distance
        v.destination_distance = possible_distance
        # if possible_distance = v.destination_distance then there are two or more paths of equal length from the grid square
        # if all edge weights are 1, then there are at most two equal length paths out of any given grid square
        v.destination_directions = [] if (possible_distance < v.destination_distance)
        possible_direction = {x: node.point[:x] - v.point[:x], y: node.point[:y] - v.point[:y]}
        case possible_direction
          when {x:  1, y:  0} then v.destination_directions << :right unless v.destination_directions.include?(:right)
          when {x: -1, y:  0} then v.destination_directions << :left  unless v.destination_directions.include?(:left)
          when {x:  0, y:  1} then v.destination_directions << :down  unless v.destination_directions.include?(:down)
          when {x:  0, y: -1} then v.destination_directions << :up    unless v.destination_directions.include?(:up)
        end
      end
    end
    @current_node.visited = true
  end

  def step_forward
    next_node = @fringe.shift
    if next_node != nil
      search_node(next_node)
      @jump_count += 1
    end
  end

  def redo_search
    temp_jump_count = @jump_count
    @current_node = @graph.sink_node
    @fringe = []
    @paths = []
    @jump_count = 0
    @graph.all_nodes.each do |node|
      node.destination_distance = Float::INFINITY
      node.destination_directions = []
      node.unvisit
    end
    @current_node.destination_distance = 0
    search_node(@current_node)
    temp_jump_count.times { step_forward }
  end

  def reset_search
    @current_node = @graph.sink_node
    @fringe = []
    @paths = []
    @jump_count = 0
    @graph.all_nodes.each { |node| node.unvisit }
    search_node(@current_node)
  end

  def get_min_distance_in_fringe
    @fringe.reduce(Float::INFINITY) do |memo,node|
      if (node.destination_distance < memo)
        node.destination_distance
      else
        memo
      end
    end
  end

  def do_all_paths_end_at_sink?
    @paths.reduce(true) do |memo,path|
      if memo == false
        break false
      else
        if path.last.destination_distance == 0
          true
        else
          break false
        end
      end
    end
  end

  def find_shortest_paths_from(source = @graph.source_node)
    # the search can terminate when the destination distance of all
    # nodes in the fringe is equal to or greater than the first found distance to the source
    # this condition works as long as there are no negative edge weights
    reset_search
    min_fringe_dist = get_min_distance_in_fringe

    while min_fringe_dist < source.destination_distance do
      step_forward
      @jump_count += 1
      min_fringe_dist = get_min_distance_in_fringe
    end

    step_count = 1
    @paths = [[source]]
    while do_all_paths_end_at_sink? == false do
      @paths.each do |path|
        path.last.destination_directions.each do |dir|
          @temp_paths << (path.dup << @graph[path.last.grid_point.send(dir,1).location])
        end
      end
      @paths = @temp_paths
      @temp_paths = []
      step_count += 1
    end
    @paths
  end