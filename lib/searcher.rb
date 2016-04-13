require_relative 'graph'

class Searcher
  attr_accessor :graph, :current_node, :adjacent_nodes, :fringe, :step_count

  def initialize(search_space: SquareGridGraph.new(rows: 20, cols: 30, pixels_per_side: 30),
                 start: search_space.sink_node, end: nil)
    @graph = search_space.graph
    @current_node    = start
    @current_node.destination_distance = 0
    @fringe = []
    @step_count = 1
    search_node(@current_node)
  end

# gridgraph methods should also include, get_row, get_col (which the grid highlight method will use,
# so that there only needs to be one highlight method and it will take an argument, that being a list of nodes,
# which it will convert to grid coordinates)

# then there will also need to be methods for getting all nodes visible from a particular location,
# getting all nodes within a certain distance (measured from edge weights), getting all nodes you can travel to
# within 'n' turns,
  def search_node(node)
    @current_node         = node
    @adjacent_nodes       = @graph.get_adjacent_nodes(@current_node)
    @adjacent_nodes.each do |k,v|
      if (not v == nil)  #nil checking required here because get_adjacent_nodes returns at least one nil for boundary nodes
        @fringe << v unless (@fringe.include?(v) || (v.visited?))
        possible_distance = @current_node.destination_distance + v.cost_to_enter
        #puts "#{possible_distance} < #{v.destination_distance}?"
        if possible_distance <= v.destination_distance
          v.destination_distance = possible_distance
          # if possible_distance = v.destination_distance then there are two or more paths of equal length from the grid square
          # if all edge weights are 1, then there are at most two equal length paths out of any given grid square
          v.destination_directions = [] if possible_distance < v.destination_distance
          possible_direction = {x: node.grid_point[:x] - v.grid_point[:x], y: node.grid_point[:y] - v.grid_point[:y]}
          case possible_direction
            when {x:  1, y:  0} then v.destination_directions << :right
            when {x: -1, y:  0} then v.destination_directions << :left
            when {x:  0, y:  1} then v.destination_directions << :down
            when {x: 0,  y: -1} then v.destination_directions << :up
          end
        end
      end
    end
    @current_node.visited = true
  end
    #@current_node.set_destination_directions(@sink)

      #if node && node.visited? == false && !fringe.include?(adj)
        #fringe.unshift(adj)
        #node.destination_direction ||= (Vector[*node.coord] - Vector[*current_node.coord]).to_a
        #node.destination_distance = current_node.destination_distance + 1
      #end
  def step_forward
    next_node = @fringe.shift
    if next_node != nil
      search_node(next_node)
      @step_count += 1
      puts @graph.nodes[x: 10, y:10, z:0].destination_distance
    else
      puts "that's all folks!"
    end
  end

=begin
  def go_left
    @current_loc = @left
    update
  end

  def go_right
    @current_loc = @right
    update
  end

  def go_up
    @current_loc = @up
    update
  end

  def go_down
    @current_loc = @down
    update
  end

# need to fix
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

  def redo_sim(back: 0)
    @path           = []
    @cells_within_d = []
    @player.fringe    = []
    @graph.nodes.each do |k,v|
      v.visited          = false
      #v.destination_direction  = nil
      #v.destination_distance = 0
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
=end

end