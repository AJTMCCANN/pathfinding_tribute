describe SquareGridGraph do

  before(:example) do
    @grid_graph = SquareGridGraph.new
    @graph = @grid_graph.graph
  end

  it 'has a cyclic graph with 600 nodes' do
    expect(@graph).not_to be nil
    expect(@graph.nodes.size).to be 600
    expect(@graph.is_cyclic?).to be true
  end

  it 'has a sink node and a source node' do
    expect(@grid_graph.sink_node.class).to be Node3D
    expect(@grid_graph.source_node.class).to be Node3D
  end



end