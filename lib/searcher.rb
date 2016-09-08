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
    @jump_count      = 0
    @paths           = []
    @temp_paths      = []
    search_node(@current_node)
  end

  def search_node(node)
    # -remember the default distance from 'a' to the sink is infinite
    # -if possible_distance = a.destination_distance then there  + a.cost_to_enter
    @current_node         = node
    @adjacent_nodes       = @graph.adjacent_nodes_from(@current_node.location)
    @adjacent_nodes.each do |a|
      @fringe << a unless (@fringe.include?(a) || (a.visited?))
      possible_distance = @current_node.destination_distance + a.cost_to_enter
      if possible_distance <= a.destination_distance
        a.destination_distance = possible_distance
        if (possible_distance < a.destination_distance)
          a.destination_directions = []
          search_node(a)
        end
        possible_direction = {x: node.point[:x] - a.point[:x], y: node.point[:y] - a.point[:y]}
        case possible_direction
          when {x:  1, y:  0} then a.destination_directions << :right unless a.destination_directions.include?(:right)
          when {x: -1, y:  0} then a.destination_directions << :left  unless a.destination_directions.include?(:left)
          when {x:  0, y:  1} then a.destination_directions << :down  unless a.destination_directions.include?(:down)
          when {x:  0, y: -1} then a.destination_directions << :up   unless a.destination_directions.include?(:up)
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

  def reset_search
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
  end

  def redo_search
    temp_jump_count = @jump_count
    reset_search
    temp_jump_count.times { step_forward }
  end

  # these next two methods are used in the find_shortest_paths_from(source) method

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
      min_fringe_dist = get_min_distance_in_fringe
    end

    @paths = [[source]]
    while do_all_paths_end_at_sink? == false do
      @paths.each do |path|
        path.last.destination_directions.each do |dir|
          new_loc = @graph[path.last.point.send(dir,1).location]
          if new_loc != nil
            @temp_paths << (path.dup << new_loc)
          end
        end
      end
      @paths = @temp_paths
      @temp_paths = []
    end
    puts @paths
    @paths
  end

  def get_nodes_within(dist)
    nodes_within = []
    @graph.all_nodes.each do |node|
      if node.destination_distance <= dist
        nodes_within << node
      end
    end
  end

end
