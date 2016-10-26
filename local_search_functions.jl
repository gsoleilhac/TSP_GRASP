#3-opt local search
function ls_3opt(sol::solution, distancier::Array{Float64,2})::Void
	x=sol.x
	bestimprovement = 0.0
	indice_rearrangement = 0
	cutting_points = (0,0,0)
	n = length(x)
	for i = 1:n-4, j = i+2:n-2, k = j+2:n
		cut = distancier[x[i],x[i+1]] + distancier[x[j],x[j+1]] + distancier[x[k],x[k%n + 1]]
		rearrangement1 = distancier[x[i],x[j]] + distancier[x[i+1],x[k]] + distancier[x[j+1],x[k%n + 1]]
		rearrangement2 = distancier[x[i],x[j+1]] + distancier[x[k],x[i+1]] + distancier[x[j],x[k%n + 1]]
		rearrangement3 = distancier[x[i],x[j+1]] + distancier[x[k],x[j]] + distancier[x[i+1],x[k%n + 1]]
		rearrangement4 = distancier[x[i],x[k]] + distancier[x[j+1],x[i+1]] + distancier[x[j],x[k%n + 1]]
		zmin = min(rearrangement1, rearrangement2, rearrangement3, rearrangement4)
		#println("i,j,k = (",i,",",j,",",k,") ", zmin - cut," | ", bestimprovement)
		if zmin - cut < bestimprovement
			bestimprovement = zmin - cut
			indice_rearrangement = indmin([rearrangement1, rearrangement2, rearrangement3, rearrangement4])
			cutting_points = (i,j,k)
		end
	end
	
	if bestimprovement < 0.0
		i,j,k = cutting_points
		if indice_rearrangement == 1
			splice!(x,i+1:k, cat(1, reverse(x[i+1:j]), reverse(x[j+1:k])))
		elseif indice_rearrangement == 2
			splice!(x,i+1:k, cat(1, x[j+1:k], x[i+1:j]))
		elseif indice_rearrangement == 3
			splice!(x,i+1:k, cat(1, x[j+1:k], reverse(x[i+1:j])))
		else
			splice!(x,i+1:k, cat(1, reverse(x[j+1:k]), x[i+1:j]))
		end
		sol.z += bestimprovement	
	end
	return
end

#2-opt local search
function ls_2opt(sol::solution, distancier::Array{Float64,2})::Void
	x = sol.x
	bestimprovement = 0.0
	cutting_points = (0,0)
	n = length(x)
	for i = 1:n-2, j = i+2:n
		cut = distancier[x[i],x[i+1]] + distancier[x[j],x[j%n+1]]
		rearrangement = distancier[x[i],x[j]] + distancier[x[i+1],x[j%n+1]]
		if rearrangement - cut < bestimprovement
			bestimprovement = rearrangement - cut
			cutting_points = (i,j)
		end
	end
	
	if bestimprovement < -1e-6
		i,j = cutting_points
		res = x[1:i]
		append!(res, reverse(x[i+1:j]))
		if j < n
			append!(res, x[j+1:n])
		end
		copy!(sol.x, res)
		sol.z += bestimprovement
	end
	return
end

function k_neighborhood(k::Int, distancier::Array{Float64,2})::Array{Int,2}
	n = size(distancier,1)
	res = Matrix(n, k)
	#pour chaque ville
	for i = 1:n
		distances = sortperm(distancier[i, :]) #indices des villes les plus proches dans l'ordre croissant
		res[i, :] = distances[2:k+1] 
	end
	res
end


#3-opt fast local search 
function ls_3opt_fast(sol::solution, voisins::Array{Int,2}, distancier::Array{Float64,2})::Void
	x=sol.x
	bestimprovement = 0.0
	indice_rearrangement = 0
	cutting_points = (0,0,0)
	n = length(x)
	nb_voisin = size(voisins,2)
	for i in 1:n ,vj in 1:nb_voisin, vk in 1:nb_voisin #Beaucoup moins gourmand en mémoire que faire des "for j in voisins[x[i],:]...
		j = findfirst(x,voisins[x[i],vj])	
		k = findfirst(x,voisins[x[j],vk])
		if j > i+1 && k > j+1
			cut = distancier[x[i],x[i%n+1]] + distancier[x[j],x[j%n+1]] + distancier[x[k],x[k%n + 1]]
			rearrangement1 = distancier[x[i],x[j]] + distancier[x[i%n+1],x[k]] + distancier[x[j%n+1],x[k%n + 1]]
			rearrangement2 = distancier[x[i],x[j%n+1]] + distancier[x[k],x[i%n+1]] + distancier[x[j],x[k%n + 1]]
			rearrangement3 = distancier[x[i],x[j%n+1]] + distancier[x[k],x[j]] + distancier[x[i%n+1],x[k%n + 1]]
			rearrangement4 = distancier[x[i],x[k]] + distancier[x[j%n+1],x[i%n+1]] + distancier[x[j],x[k%n + 1]]
			zmin = min(rearrangement1, rearrangement2, rearrangement3, rearrangement4)
			#println("i,j,k = (",i,",",j,",",k,") ", zmin - cut," | ", bestimprovement)
			if zmin - cut < bestimprovement
				bestimprovement = zmin - cut
				indice_rearrangement = indmin([rearrangement1, rearrangement2, rearrangement3, rearrangement4])
				cutting_points = (i,j,k)
			end
		end
	end
	
	if bestimprovement < -1e-6
		i,j,k = cutting_points
		if indice_rearrangement == 1
			splice!(x,i+1:k, cat(1, reverse(x[i+1:j]), reverse(x[j+1:k])))
		elseif indice_rearrangement == 2
			splice!(x,i+1:k, cat(1, x[j+1:k], x[i+1:j]))
		elseif indice_rearrangement == 3
			splice!(x,i+1:k, cat(1, x[j+1:k], reverse(x[i+1:j])))
		else
			splice!(x,i+1:k, cat(1, reverse(x[j+1:k]), x[i+1:j]))
		end
		sol.z += bestimprovement	
	end
	return
end
