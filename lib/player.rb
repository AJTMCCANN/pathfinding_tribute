require_relative 'graph'

class Player
  attr_accessor :current_loc, :left, :right, :up, :down, :adjacent, :fringe

  def initialize(x,y, graph)
    @left       = [x - 1, y]
    @right      = [x + 1, y]
    @up         = [x, y - 1]
    @down       = [x, y + 1]
    @adjacent   = [up, down, left, right]
    @graph      = graph
    @fringe     = []
    self.teleport(x,y)
  end

  def update
    @left     = [@current_loc[0] - 1, @current_loc[1]    ]
    @right    = [@current_loc[0] + 1, @current_loc[1]    ]
    @up       = [@current_loc[0]    , @current_loc[1] - 1]
    @down     = [@current_loc[0]    , @current_loc[1] + 1]
    @adjacent = [right, down, left, up]
  end

  def teleport(x,y)
    @current_loc         = [x, y]
    current_node         = @graph[@current_loc.to_s]
    current_node.visited = true
    update
    adjacent.each do |adj|
      node = @graph[adj.to_s]
      if node && node.visited? == false && !fringe.include?(adj)
        fringe.unshift(adj)
        node.destination_direction ||= (Vector[*node.coord] - Vector[*current_node.coord]).to_a
        node.destination_distance = current_node.destination_distance + 1
      end
    end
  end

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
end