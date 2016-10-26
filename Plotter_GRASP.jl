!isdir("output") && error("Le dossier output n'existe pas")
cd("output")
!("output_GRASP.txt" in readdir()) && error("Pas de fichier output")

f = open("output_GRASP.txt")


if !eof(f) #Si le fichier n'est pas vide
	zBestTab, zLSTab,zPRTab = Array(Float64,0) , Array(Float64,0) , Array(Float64,0)
	xBestTab, xPRTab = Array(Int,0) , Array(Int,0)
	i=1
	
	l = readline(f)
	n,alpha,nbrun,nbGRASP,taille_voisinage,PR_type = split(chomp(l)," ")
	
	for ln in eachline(f)
		l = split(chomp(ln)," ")
		zBest = Base.parse(Float64,l[1])
		zLS = Base.parse(Float64,l[2])
		push!(zBestTab,zBest)
		push!(zLSTab,zLS)
		push!(xBestTab, i)
		if length(l) > 2
			zPR = Base.parse(Float64,l[3])
			push!(zPRTab,zPR)
			push!(xPRTab,i)
		end
			
		i += 1
	end	
end
close(f)


print("Loading PyPlot......") ; using PyPlot ; println(" Done.")
using PyCall
title("nbCity = $n, alpha = $alpha, $(nbGRASP)x$(nbrun)runs\n nbNeighbors = $taille_voisinage, PR : $PR_type, z* = $(round((zBestTab[end]),3))")
println("Plotting...")
plot(xBestTab,zBestTab,"g-",xBestTab,zLSTab,"b.", xPRTab,zPRTab,"rx",markersize=8)
savefig("$(n)cities_$(alpha)_$(nbGRASP)GRASPx$(nbrun)runs_$(taille_voisinage)_$(PR_type).png", bbox_inches="tight")
show()

