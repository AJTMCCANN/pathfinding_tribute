describe Searcher do

  before(:example) do
    @wizard = Searcher.new
    @graph = @wizard.graph
  end

  it 'has searched its starting node' do
    expect(@wizard.fringe.size.to_s).to match /(3|4)/
    expect(@wizard.current_node.visited?).to be true
  end

  it 'can assign to each node a distance from the sink node' do
    @graph.nodes.size.times  do
      @wizard.step_forward
    end
  end

  it 'can assign to each node a direction towards the sink node' do
    @graph.nodes.size.times do 
      @wizard.step_forward
    end
    number_of_nodes_with_no_directions_to_source = @graph.nodes.values.select { |v| v.destination_directions.size == 0 }.size
    expect(number_of_nodes_with_no_directions_to_source).to equal 1 #the source node
  end
 
 # it 'can terminate the search when it finds the source node' do
 #   expect(false).to be true
 # end

 # it 'can search either from sink to source, or from source to sink' do
 #   expect(false).to be true
 # end

 # it 'can search without consdiering edge weights' do
 #   expect(false).to be true
 # end

 # it 'can search using the A* algorithm' do
 #  expect(false).to be true
 # end


end