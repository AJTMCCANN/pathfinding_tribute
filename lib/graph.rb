require_relative 'grid'

class Node
  attr_reader :name, :coord, :connections
  attr_writer :visited
  attr_accessor :destination_direction, :destination_distance

  def initialize(name, coord = [0,0])
    @name = name
    @connections = {}
    @visited = false
    @coord = coord
    @destination_direction = nil
    @destination_distance = 0
  end

  def destination_coord
    x = coord[0]
    y = coord[1]
    if destination_direction != nil
      adjust_x = destination_direction[0]
      adjust_y = destination_direction[1]
    else
      adjust_x = 0
      adjust_y = 0
    end
    [x - adjust_x, y - adjust_y]
  end

  def add_edge(connection, weight: 1)
    @connections[connection] = weight
  end

  def remove_edge(connection)
    @connections.delete(connection)
  end

  def goes_to?(connection)
    @connections.include?(connection)
  end

  def visited?
    @visited
  end

  def unvisited_connections
    @connections.select{ |k,v| k.visited? == false }
  end

  def to_s
    "#{@name} -> [#{@connections.keys.map(&:name).join(' ')}]"
  end

  def name_to_a
    @name.gsub(/\[|\]/,'').split(',').map(&:to_i)
  end

end

class DirectedGraph
  attr_accessor :nodes, :deleted_nodes

  def initialize
    @nodes = {}
    @deleted_nodes = []
  end

  def has_node?(node)
    @nodes.values.include?(node)
  end

  def has_node_named?(node_name)
    @nodes.keys.include?(node_name)
  end

  def add_node(node)
    @nodes[node.name] = node
  end

  def add_nodes(nodes)
    nodes.each do |node| add_node(node) end
  end

  def remove_node(node)
    @nodes.delete(node.name)
    @nodes.each do |other_node_name, other_node|
      if other_node.goes_to?(node) then other_node.remove_edge(node) end
    end
  end

  def add_edge(from_node_name, to_node_name, weight: 1)
    if @nodes[from_node_name] != nil && @nodes[to_node_name] != nil
      @nodes[from_node_name].add_edge(@nodes[to_node_name], weight: weight)
    end
  end

  def remove_edge(from_node_name, to_node_name)
    @nodes[from_node_name].remove_edge(@nodes[to_node_name])
  end

  def [](name)
    @nodes[name]
  end

  def unvisited_nodes
    @nodes.select{ |k,v| v.visited? == false }
  end

  def visited_nodes
    @nodes.select{ |k,v| v.visited? == true }
  end

  def reset_nodes
    @nodes.each { |k,v| v.visited = false }
  end

  def is_cyclic?
    if unvisited_nodes.size == 0 then reset_nodes ; return false end
    leaves = @nodes.select{ |k,v| v.unvisited_connections.size == 0 && v.visited? == false}
    if leaves.size == 0 then reset_nodes ; return true end
    leaf = @nodes[leaves.keys.first]
    @nodes[leaf.name].visited = true
    is_cyclic?
  end

  def add_outgoing_edges(node)
    add_node(node) unless has_node?(node) == true

    loc   = node.coord
    above = [loc[0], loc[1] - 1]
    below = [loc[0], loc[1] + 1]
    left  = [loc[0] - 1, loc[1]]
    right = [loc[0] + 1, loc[1]]

    add_edge(node.name,above.to_s)
    add_edge(node.name,below.to_s)
    add_edge(node.name,left.to_s)
    add_edge(node.name,right.to_s)
  end

  def add_incoming_edges(node)
    add_node(node) unless has_node?(node) == true

    loc   = node.coord
    above = [loc[0], loc[1] - 1]
    below = [loc[0], loc[1] + 1]
    left  = [loc[0] - 1, loc[1]]
    right = [loc[0] + 1, loc[1]]
    adjacent = [above, below, left, right]

    @nodes.each do |other_node_name, other_node|
      if not other_node.goes_to?(node) && adjacent.include?(other_node) then add_edge(other_node_name, node.name) end
    end
  end

end

def build_grid_and_graph(ww, wh, bw, bh, start_row, start_col, end_row, end_col)
  grid = SquareGrid.new(ww,wh,bw,bh)
  rows = grid.row_count
  cols = grid.column_count



  nodes = []

  (0..cols).to_a.each do |i|
    (0..rows).to_a.each do |j|
      nodes << Node.new([i,j].to_s,[i,j])
    end
  end

  graph = DirectedGraph.new
  graph.add_nodes(nodes)

  nodes.each do |node|
    graph.add_outgoing_edges(node)
  end

  nodes.each do |node|
    if (node.coord[0] < start_row) || (node.coord[0] > end_row)
      graph.remove_node(node)
      graph.deleted_nodes << [node.coord[0], node.coord[1]]
    elsif (node.coord[1] < start_col) || (node.coord[1] > end_col)
      graph.remove_node(node)
      graph.deleted_nodes << [node.coord[0], node.coord[1]]
    end
  end

  {grid: grid, graph: graph}
end