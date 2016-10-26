#Ecrit toutes les étapes de construction / recherche locale / path relinking pour les afficher plus tard avec PyPlot
const output = true
const ouput_tour = true
const alpha = 0.5
const nbRun = 100
const neighborhood_size = 5 #Taille du voisinage pour la recherche locale 3_opt_fast
const simple_PR = true 
const nbGRASP = 100

type solution
	x::Array{Int,1}
	z::Float64
end
type Point
	x::Float64
	y::Float64
end
function eval(perm::Array{Int,1},distancier::Array{Float64,2})::Float64
	z=0.0
	for i = 1:(length(perm)-1)
		z += distancier[perm[i],perm[i+1]]
	end
	z+= distancier[perm[end],perm[1]]
	return z
end

include("ParserTSP.jl")
include("Jarvis.jl")
include("construction_heuristics.jl")
include("local_search_functions.jl")
include("path_relinking.jl")

					
cd("data")
println("reading data")
xyData, names, distancier = parse(ARGS[1])
cd("..")

f = nothing
if output
	!isdir("output") && mkdir("output")
	cd("output")
	f = open("output_GRASP.txt", "w") 
	cd("..")
	pr_type = simple_PR ? "simple" : "CIH"
	write(f, "$(length(xyData)) $alpha $nbRun $nbGRASP $neighborhood_size $pr_type \n")
end

f_t = nothing
if ouput_tour
!isdir("output") && mkdir("output")
	cd("output")
	f_t = open("output_tour.txt", "w") 
	cd("..")
	writedlm(f_t, transpose([t.x for t = xyData]), " ")
	writedlm(f_t, transpose([t.y for t = xyData]), " ")
end

voisins = k_neighborhood(neighborhood_size,distancier)
pr = simple_PR ? simple_relink : relink
hull = convexHull(xyData)

function solve(hull, distancier, voisins, nbRun)

	bestSol = NIH(hull,distancier, 1.0, f_t)

	for i = 1:nbRun
		#println("\tRun ",i)

		sol = NIH(hull,distancier, alpha)
		if i == 1 
			bestSol = deepcopy(sol)
		end
	
		z = sol.z
		k = 1
		while k <= 1
			k == 1 && ls_2opt(sol,distancier)
			k == 2 && ls_3opt_fast(sol,voisins,distancier)	
		 	z == sol.z ? k += 1 : k = 1
			z = sol.z
		end
	
		sol_a = pr(sol,bestSol,distancier)
		sol_b = pr(bestSol,sol,distancier)

		if min(sol.z, sol_a.z, sol_b.z) < bestSol.z - 1e-6
			ind = sortperm([sol.z,sol_a.z,sol_b.z])[1]
			sol2 = [sol,sol_a,sol_b][ind]
		
			if ind != 1 && sol2.z > sol.z - 1e-6
				ind = 1
				sol2 = sol
			end
		
			k = 1
			z2 = sol2.z
			while k <= 2
				k == 1 && ls_2opt(sol2,distancier)
				k == 2 && ls_3opt_fast(sol2,voisins,distancier)	
				k == 3 && ls_3opt(sol2, distancier)
			 	abs(z2-sol2.z) < 1e-6 ? k += 1 : k = 1
				z2 = sol2.z
			end
		
			bestSol = sol2
			f_t != nothing && writedlm(f_t, transpose(bestSol.x), " ")
		
			if ind == 1
				#println("\tLS improvement : $z")
				f != nothing && write(f, "$(bestSol.z) $z\n")
			else
				#println("\tPR improvement : $z2")
				f != nothing &&  write(f, "$(bestSol.z) $z $z2\n")
			end
		else
			f != nothing &&  write(f, "$(bestSol.z) $z\n")
		end
	
	end
	
	return bestSol
end

solutions = Array(solution,nbGRASP)
for i = 1:nbGRASP
	print("GRASP $i / $nbGRASP...")
	@time solutions[i] = solve(hull, distancier, voisins, nbRun)
end

avg = 0.0
Min = (solutions[1]).z
Max = (solutions[1]).z
for i = 1:nbGRASP
	avg += (solutions[i]).z
	if (solutions[i]).z < Min
		Min = (solutions[i]).z
	end
	if (solutions[i]).z > Max
		Max = (solutions[i]).z
	end
end
avg = avg / nbGRASP
println("min : $Min, avg : $avg, max : $Max")

output && close(f)
