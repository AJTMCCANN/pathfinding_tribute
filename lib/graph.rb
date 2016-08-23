require_relative 'grid'

class PathfindingNode

  attr_accessor :point, :location, :edges, :cost_to_enter,
                :visited, :destination_distance, :destination_directions

  def initialize(loc: {x: 0, y: 0, z: 0}, weight: 1)
    @point         = GridPoint3D.new(loc: loc)
    @location      = @point.location
    @edges         = {} #a hash of coordinate keys and edge weight values
    @cost_to_enter = weight

    @visited                = false
    @destination_distance   = Float::INFINITY
    @destination_directions = []
  end

  def visited?
    @visited
  end

  def visit
    @visited = true
  end

  def unvisit
    @visited = false
  end

  def goes_to?(coord)
    @edges.keys.include?(coord)
  end

  def goes_to
    @edges.keys
  end

  def adjacent_loc(dir)
    @point.send(:"#{dir}", 1).location
  end

end


class PathfindingGraph

  attr_accessor :node_box, :removed_node_box, :source_node, :sink_node

  def initialize
    @node_box          = {}  # a hash of grid coordinate keys and PathfindingNode values
    @removed_node_box  = {}
    @source_node       = nil
    @sink_node         = nil
  end

  def [](coord)
    @node_box[coord]
  end

  def node_at(coord)
    @node_box[coord]
  end

  def all_nodes
    @node_box.values
  end

  def all_removed_nodes
    @removed_node_box.values
  end

  def get_adjacent_node_from(coord, dir)
    node = node_at(coord)
    adjacent = node.adjacent_loc(dir)
    node_at(adjacent)
  end

  def adjacent_nodes_from(coord)
    adjacent_nodes = []
    [:up,:down,:left,:right,:higher,:lower].each do |dir|
      node = get_adjacent_node_from(coord, dir)
      adjacent_nodes << node unless node == nil
    end
    adjacent_nodes
  end

  def connect_node_at(coord)
    node = @node_box[coord]
    adjacent_nodes = adjacent_nodes_from(node.location)
    adjacent_nodes.each do |adj_node|
      node.edges[adj_node.location] = adj_node.cost_to_enter
      adj_node.edges[node.location] = node.cost_to_enter
    end
  end

  def disconnect_node_at(coord)
    node_at(coord).edges = {}
    all_nodes.each do |node|
      if node.goes_to?(coord) then node.edges.delete(coord) end
    end
  end

  def add_node_at(coord)
    @node_box[coord] = PathfindingNode.new(loc: coord)
    @removed_node_box.delete(coord)
  end

  def remove_node_at(coord)
    @removed_node_box[coord] = @node_box[coord]
    @node_box.delete(coord)
  end

  def make_wall_at(coord)
    disconnect_node_at(coord)
    remove_node_at(coord)
  end

  def make_passable_at(coord)
    add_node_at(coord)
    connect_node_at(coord)
  end

  def is_a_wall_at?(coord)
    if @removed_node_box.keys.include?(coord) == true && @node_box.keys.include?(coord) == false
      true
    else
      false
    end
  end

  def is_a_path_at?(coord)
    if @node_box.keys.include?(coord) == true && @removed_node_box.keys.include?(coord) == false
      true
    else
      false
    end
  end

end