require_relative 'grid'


#TODO: sort out the use of the terms coord, coordinates, location, point, and how those terms relate to the terms
#      box and grid and node.  maybe some convention like, if the variable is a Point3D the word point appears in the name
#      and if it is a Node3D the word node appears in the name.  boxes have grid locations (which are Hashes), and
#      pixel locations (which are Hashes).
#
#      grid_point, pixel_point, node_point, grid_location_hash, pixel_location_hash, node_location_hash
#

module NodesOnSquareGrids

  attr_accessor :destination_distance, :destination_directions, :visited, :cost_to_enter

  def initialize(cost: 1)
    @destination_distance = 0
    @destination_directions = []
    @visited = false
    @cost_to_enter = cost
  end

  def visited?
    @visited
  end

end


class Node3D
  include NodesOnSquareGrids

  attr_accessor :grid_point, :grid_coordinates, :edges, :flagged

  def initialize(coord: Point3D.new, edges: {}, cost: 1)
    @grid_point = coord
    @grid_coordinates = @grid_point.location
    @edges = edges #a hash consisting of node keys and edge weight values
    @flagged = false
    super(cost: cost) #this calls the initialize method in NodesOnSquareGrids
  end

  # the word 'define' is used in the method name nstead of 'add', because it
  # can be used to both create an edge or re-define an edge weight.
  def define_edge(node, weight = node.cost_to_enter)
    @edges[node] = weight
  end

  def remove_edge(node)
    @edges.delete(node)
  end

  def edge_weight(node)
    @edges[node]
  end

  def goes_to?(node)
    @edges.include?(node)
  end

  def flag
    @flagged = true
  end

  def unflag
    @flagged = false
  end

  def flagged?
    @flagged
  end

  def flagged_connections
    @edges.select{ |k,v| k.flagged? == true }
  end

  def unflagged_connections
    @edges.select{ |k,v| k.flagged? == false }
  end

end

module GraphsOnSquareGrids
  # what if I initialize the GridOfSquares in this module, and have the DirectedGraph class
  # call super. that way I can get rid of the SquareGridGraph class

  def get_outgoing_node(node, sidename)
    loc = node.grid_point
    new_point = loc.send(:"#{sidename}", 1)
    outgoing_node = @nodes[new_point.location]
  end

  def get_adjacent_nodes(node)
    { top: get_outgoing_node(node, :up), bottom: get_outgoing_node(node, :down), left: get_outgoing_node(node, :left), right: get_outgoing_node(node, :right) }
  end

  def add_outgoing_edge(node, sidename)
    outgoing_node = get_outgoing_node(node,sidename)
    if not outgoing_node == nil
      define_edge(from: node, to: outgoing_node, weight: outgoing_node.cost_to_enter)
    end
  end

  def add_outgoing_edges(node)
    sides = [:up, :down, :left, :right]
    sides.each do |sidename|
      add_outgoing_edge(node, sidename)
    end
  end

  def add_incoming_edges(node)
    adjacent_nodes = get_adjacent_nodes(node)
    adjacent_nodes.each do |k,v|
      if (not v == nil) && (not v.goes_to?(node))
        define_edge(from: v, to: node, weight: node.cost_to_enter)
      end
    end
  end

end

class DirectedGraph
  include GraphsOnSquareGrids

  attr_accessor :nodes, :wall_nodes

  def initialize
    @nodes = {}         # a hash of node coordinate keys and node values
    @wall_nodes = []    # an array of nodes that are not traversible
  end

  def [](node_coord)
    @nodes[node_coord]
  end

  def add_node(node)
    @nodes[node.grid_point.location] = node
  end

  def add_nodes(nodes)
    nodes.each do |node|
      add_node(node)
    end
  end

  def remove_node(node)
    @nodes.delete(node.grid_point)
    node.edges = {}
    @nodes.each do |other_node_name, other_node|
      if other_node.goes_to?(node) then other_node.remove_edge(node) end
    end
  end

  # the word 'define' is used in the method name instead of 'add', because it
  # can be used to both create an edge or re-define an edge weight.
  def define_edge(from: Point.new.location, to: Point.new.location, weight: @nodes[to].cost_to_enter)
    if @nodes[from.grid_coordinates] != nil && @nodes[to.grid_coordinates] != nil
      from.define_edge(to, weight)
    end
  end

  def remove_edge(from_node, to_node)
    from_node.remove_edge(to_node)
  end


  # the next three methods are used to determine if the graph contains any cyclces
  def unflagged_nodes
    @nodes.select{ |k,v| v.flagged? == false }
  end

  def unflagged_leaves
    @nodes.select{ |k,v| v.flagged? == false && v.unflagged_connections.size == 0 }
  end

  def unflag_all_nodes
    @nodes.each { |k,v| v.flagged = false }
  end

  def is_cyclic?
    # flagging a node as visited is analogous to deleting it, from the perspective of this method
    # if there are no nodes, then there are no cycles
    # if there are no leaves, then there is at least one cycle
    # if unvisited nodes remain, but all leaves have been visited, then there must be a cycle
    # conversely, if the last leaf visited is also the last node visited, then no cycles were found
    if unflagged_nodes.size  == 0 then unflag_all_nodes ; return false end
    if unflagged_leaves.size == 0 then unflag_all_nodes ; return true end
    puts unflagged_leaves.size
    next_leaf = unflagged_leaves.values.first
    next_leaf.flag
    is_cyclic?
  end
end

module SingleSourceAndSink
  attr_accessor :sink_node, :source_node

  def initialize
    @sink_node = @graph[{x: rand(1..(@col_count).to_i), y: rand(1..(@row_count).to_i), z: 0}]
    @source_node = @sink_node
    while @source_node == @sink_node do
      @source_node = @graph[{x: rand(1..(@col_count).to_i), y: rand(1..(@row_count).to_i), z: 0}]
    end
  end

end

class SquareGridGraph
  include SingleSourceAndSink

  attr_reader :row_count, :col_count
  attr_accessor :grid, :graph, :nodes

  def initialize(rows: 20, cols: 30, pixels_per_side: 30)
    # the thing about a GridOfSquares object is that it can return pixel coordinates for one of nine points on any
    # grid box referenced by its row and column number. this is useful for drawing functions
    @grid = GridOfSquares.new(width: cols * pixels_per_side, height: rows * pixels_per_side, box_side: pixels_per_side)
    @row_count = rows
    @col_count = cols
    # create a node for each box in the grid...
    @nodes = []
    (1..@col_count).to_a.each do |i|
      (1..@row_count).to_a.each do |j|
        @nodes << Node3D.new(coord: Point3D.new(x: i, y: j))
      end
    end
    # then add those nodes to a graph where each node has bidirectional edges
    # to the top, bottom, left, and right sides...
    @graph = DirectedGraph.new
    @graph.add_nodes(@nodes)
    @nodes.each do |node|
      @graph.add_outgoing_edges(node)
    end
    super()
  end

end
