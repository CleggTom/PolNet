"""
    process_bifurcation_data(x_values, fixed_points_data)

Processes a vector of vectors of fixed points into distinct, continuous branches,
inferring stability based on common bifurcation patterns.
"""
function process_bifurcation_data(x_values, fixed_points_data)
    # Initialize data structures for each potential branch
    branches = Dict(
        :zero_stable => Point2f[],
        :zero_unstable => Point2f[],
        :upper_stable => Point2f[],
        :middle_unstable => Point2f[]
    )

    #max
    max_sol = maximum(length.(fixed_points_data))
    
    # Iterate through each parameter step to populate the branches
    for (i, x) in enumerate(x_values)
        points = sort(fixed_points_data[i])
        num_points = length(points)

        if num_points == 1
            # The single branch is the stable zero branch
            push!(branches[:zero_stable], Point2f(x, points[1]))
        elseif num_points == 2
            # The zero branch becomes unstable, and a new stable branch appears
            push!(branches[:zero_unstable], Point2f(x, points[1]))
            if max_sol == 2
                push!(branches[:zero_stable], Point2f(x, points[2]))
            else
                push!(branches[:upper_stable], Point2f(x, points[2]))
            end
        elseif num_points == 3
            # Bistability: zero is stable again, middle is unstable, upper is stable
            push!(branches[:zero_stable], Point2f(x, points[1]))
            push!(branches[:middle_unstable], Point2f(x, points[2]))
            push!(branches[:upper_stable], Point2f(x, points[3]))
        end
    end
    
    return branches
end

"""
    plot_bifurcation_diagram!(ax, x_values, fixed_points_data)

Takes a Makie axis `ax` and plots the bifurcation diagram,
styling stable branches as solid lines and unstable ones as dashed.
This version ensures branches are visually continuous.
"""
function plot_bifurcation_diagram!(ax, x_values, fixed_points_data; kwargs...)
    branches = process_bifurcation_data(x_values, fixed_points_data)

    # Plot stable branches (solid lines)
    if !isempty(branches[:zero_stable])
        lines!(ax, branches[:zero_stable]; kwargs...)
    end
    if !isempty(branches[:upper_stable])
        # Add label only if it's the first stable branch being plotted
        label = isempty(branches[:zero_stable]) ? "Stable" : ""
        lines!(ax, branches[:upper_stable]; kwargs...)
    end

    # Plot unstable branches (dashed lines)
    if !isempty(branches[:zero_unstable])
        lines!(ax, branches[:zero_unstable], linestyle = :dash; kwargs...)
    end
    if !isempty(branches[:middle_unstable])
        # Add label only if it's the first unstable branch being plotted
        label = isempty(branches[:zero_unstable]) ? "Unstable" : ""
        lines!(ax, branches[:middle_unstable], linestyle = :dash; kwargs...)
    end
end
