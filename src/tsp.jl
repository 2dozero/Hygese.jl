
function solve_tsp(tsp_file_path::AbstractString, parameters=AlgorithmParameters(); verbose=true)
    tsp = TSPLIB.readTSP(tsp_file_path)
    return solve_tsp(tsp, parameters; verbose=verbose, use_dist_mtx=true)
end

function solve_tsp(tsp::TSP, parameters=AlgorithmParameters(); verbose=true, use_dist_mtx=false)
    n = tsp.dimension
    x = tsp.nodes[:, 1]
    y = tsp.nodes[:, 2]
    serv_time = zeros(size(x))
    dem = ones(size(x))
    vehicleCapacity = n
    maximum_number_of_vehicles = 1
    
    c_dist_mtx = Matrix(tsp.weights')
    for i in 1:n
        c_dist_mtx[i, i] = 0.0
    end

    if use_dist_mtx
        # need to input dist_mtx' instead of dist_mtx
        # Julia: column-first indexing
        # C: row-first indexing
        return c_api_solve_cvrp_dist_mtx(n, x, y, c_dist_mtx, serv_time, dem, vehicleCapacity, maximum_number_of_vehicles, parameters, verbose)
    else
        return c_api_solve_cvrp(n, x, y, serv_time, dem, vehicleCapacity, maximum_number_of_vehicles, parameters, verbose)
    end
end


function solve_tsp(dist_mtx::Matrix, parameters=AlgorithmParameters(); verbose=true, x_coordinates=zeros(size(dist_mtx,1)), y_coordinates=zeros(size(dist_mtx,1)))
    n = size(dist_mtx, 1)

    serv_time = zeros(n)
    dem = ones(n)
    vehicleCapacity = n
    maximum_number_of_vehicles = 1
    
    c_dist_mtx = Matrix(dist_mtx')
    for i in 1:n
        c_dist_mtx[i, i] = 0.0
    end

    # need to input dist_mtx' instead of dist_mtx
    # Julia: column-first indexing
    # C: row-first indexing
    return c_api_solve_cvrp_dist_mtx(n, x_coordinates, y_coordinates, c_dist_mtx, serv_time, dem, vehicleCapacity, maximum_number_of_vehicles, parameters, verbose)
end
function solve_tsp(x::Vector, y:: Vector, parameters=AlgorithmParameters(); verbose=true)
    n = length(x)
    serv_time = zeros(n)
    dem = ones(n)
    vehicleCapacity = n
    maximum_number_of_vehicles = 1
    
    return c_api_solve_cvrp(n, x, y, serv_time, dem, vehicleCapacity, maximum_number_of_vehicles, parameters, verbose)
end



function solve_tsp(data::Dict, parameters=AlgorithmParameters(); verbose=true)

    use_dist_mtx = haskey(data, "distance_matrix")
    has_coordinates = haskey(data, "x_coordinates") && haskey(data, "y_coordinates")

    if !use_dist_mtx && !has_coordinates 
        error("Insufficient data input. Either coordinates or a distance matrix must be provided.")
    end

    n = use_dist_mtx ? size(data["distance_matrix"], 1) : length(data["x_coordinates"])
    demands = ones(n)
    demands[1] = 0 
    data["demands"] = demands
    data["num_vehicles"] = 1
    data["vehicle_capacity"] = n 
    return solve_cvrp(data, parameters; verbose=verbose)
end


