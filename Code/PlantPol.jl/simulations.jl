"""
    generate_pollinator_degree_presence(T,Mt,z,l)

Generates a matrix of pollinator presence and degree over time. Both are sampled from their respective Poisson distributions with means z and l. The matrix keeps the number of pollinators at any point fixed (Mt) over a given time period (T). 

The function works by sampling the length of the active period of each pollinator and sequentially counting down untill the node is removed form the system and replaced by a new one.
"""
function get_pollinator_presence(z,τ,Tmax,Mt)
    #store info in matricies
    state_matrix = zeros(Int, Tmax, Mt)
    time_left = zeros(Int, Tmax, Mt)
    
    #sample first time-left 
    #samples from x * T(x)
    k_total = [rand() < (1/(1+τ)) ? rand(1 + Poisson(τ)) : rand(2 + Poisson(τ)) for i = 1:Mt]
    time_left[1,:] .= [rand(1:k) for k = k_total]
    state_matrix[1,:] .= 1:Mt
    
    #loop through time and replace pollinators
    indx = Mt+1
    for t = 2:Tmax
        #find zero
        time_left[t,:] .= time_left[t-1, :] .- 1
        state_matrix[t,:] .= state_matrix[t-1,:]
        for i = 1:Mt
            if time_left[t,i] == 0
                time_left[t,i] = rand(1 + Poisson(τ))
                state_matrix[t,i] = indx
                indx += 1
            end
        end
    end
    #get system size
    N = Tmax * Mt
    M = indx-1

    return N,M,state_matrix
end

"""
    build_network(T,Mt,z,l)

Creates a SimpleGraph object with the underlying network structure and a dictionary with groupings for each timestep of the pollinator links. 
"""
function build_network(z,τ,Tmax,Mt)
    N,M,state_matrix = get_pollinator_presence(z,τ,Tmax,Mt)

    #preallocate adj-vector
    fadj_vec = Vector{Dict{Int,Vector{Int}}}(undef, N + M)
    [fadj_vec[i] = Dict() for i = 1:(M+N)]

    #current plant
    Nt = M + 1
    for t = 1:Tmax
        #add pollinators
        for i = 1:Mt
            fadj_vec[state_matrix[t,i]][t] = []
        end
        #add Mt plants per timestep
        for j = Nt:(Nt+Mt-1)
            fadj_vec[j][t] = []
        end
        
    
        #add links
        k_pol = rand(Poisson(z),Mt)
        k_plt = rand(Multinomial(sum(k_pol), Mt));
    
        #get stubs
        pol_stubs = inverse_rle(state_matrix[t,:], k_pol) |> shuffle
        plt_stubs = inverse_rle(Nt:(Nt+Mt-1), k_plt) |> shuffle
    
        for (i,j) = zip(pol_stubs, plt_stubs)
            push!(fadj_vec[i][t], j)
            push!(fadj_vec[j][t], i)
        end
        Nt += Mt 
    end

    return N,M,fadj_vec
end


#---Simulation---
"""
    any_neighbour(s::BitVector, neighbours::Vector{Int})

Checks if any node from the vector `neighbours` is active.
"""
function any_neighbour(s::BitVector, neighbours::Vector{Int})
    for i = neighbours
        if @inbounds s[i]
            return true
        end
    end
    return false
end


"""
    simulate_network(seed, N, M, g, edge_group)

Find proportion of feasbile pollinator nodes in the network from an inital seed. 
"""
function simulate_network!(s, stmp, N, M, fadj_vec)
    #simulation
    τ = 0
    changed = true

    all_indicies = collect(1:(N+M))
    # filter!(x -> x != exc, all_indicies)
    
    while changed && τ < 1000
        changed = false
        copyto!(stmp, s)
    
        shuffle!(all_indicies)
        
        #loop over nodes
        for i in all_indicies
            # Check if `i` is a pollinator or a plant
            if i <= M # It's a pollinator
                new_state = true
                for (k,v) = fadj_vec[i]
                    if !any_neighbour(s, v)
                        new_state = false
                        break
                    end
                end
            else # It's a plant
                new_state = false
                for (k,v) = fadj_vec[i]
                    if any_neighbour(s, v)
                        new_state = true
                        break
                    end
                end
            end
    
            # Update state and check if anything changed
            if s[i] != new_state
                s[i] = new_state
                changed = true
            end
        end
        τ += 1
    end
end
