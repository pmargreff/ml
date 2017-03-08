type Node 
  bias::Float64
  output::Float64
  wcount::Int64
  weights::Array{Float64}
end

type Layer
  ncount::Int64
  nodes::Array{Node} 
end

type Network
  inp_node_size::Int64
  inp_layer_size::Int64
  hid_node_size::Int64
  hid_layer_size::Int64
  out_node_size::Int64
  out_layer_size::Int64
  layers::Array{Layer}
end


function create_layer(node_count::Int64, weight_count::Int64)
  # Create a detault node
  node = Node(0.0, 0.0, weight_count, zeros(Float64, weight_count))
  
  # create a default layer with n nodes
  layer = (node_count, fill(node, node_count))
  
  println(layer)
end

function main()
  create_layer(10, 3)
end

main()
