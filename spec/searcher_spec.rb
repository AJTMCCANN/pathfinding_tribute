describe Searcher do

  before(:example) do
    @wizard = Searcher.new
    @search_space = @wizard.search_space
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
    number_nodes_without_directions_to_source = @graph.nodes.values.select { |v| v.destination_directions.size == 0 }.size
    expect(number_nodes_without_directions_to_source).to equal 1 #the source node
  end
 
  it 'can find the shortest paths from the source node to the sink node' do
    puts 'hello world'
    paths = @wizard.find_shortest_paths_from(@search_space.source_node)
    #@wizard.do_something("#{@search_space.source_node.grid_point.location}")
    #paths.class
    expect(paths.size).to be > 0
  end

 # it 'can search either from sink to source, or from soeurce to sink' do
 #   expect(false).to be true
 # end

 # it 'can search without consdiering edge weights' do
 #   expect(false).to be true
 # end

 # it 'can search using the A* algorithm' do
 #  expect(false).to be true
 # end


end