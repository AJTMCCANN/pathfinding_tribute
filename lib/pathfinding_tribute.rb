require 'pathfinding_tribute/version'
require 'gosu'
require 'minigl'
require 'pry'
require_relative 'core'
require_relative 'searcher'
require_relative 'colors'
#require_relative 'text_field' #use minigl instead

include MiniGL
#TODO: instead of a Point class, monkeypatch the methods onto Hash?
#TODO: what if there is a grid square where you can't go left or down?  there should be walls shown on those sides, but not filling the whole square
#TODO: the graph class and the player class need to be unified
#TODO: a grid and a graph together should be a new type of object, and have its own class.  for example, add_outgoing_edges and add_incoming_edges should be in this new class
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
#TODO: when the starting position is randomized, it should be randomized somewhere in the visible range.
#TODO: when the player moves past the edge of the screen, the view should scroll to follow
#TODO: removing a node from a graph should add it to the deleted nodes list, unless some additional argument is specified


#TODO: move as much code as possible into grid.rb, and graph.rb, such as teleport code
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


#window = Pathfinding.new
#window.show
