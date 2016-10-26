#Cheapest Insertion Heuristic
#La RCL est constituée des élements dont la meilleure insertion possible donne la plus petite valeur
#Assez gourmand en temps et en mémoire donc pas utilisée
function CIH(hull::Array{I,1}, distancier::Array{Float64,2}, alpha::Float64, f=nothing)::solution
	n = size(distancier,1)
	res = deepcopy(hull) #enveloppe convexe
	l = length(res)
	left = setdiff(collect(1:n), res) #indices des villes qu'il reste à ajouter
	valuebest = Array(Float64,length(left)) #Pour chaque ville restant à ajouter, contient la longueur supplémentaire du tour dans le meilleur cas
	indexbest = Array(Int64,length(left)) #Pour chaque ville i, contient l'index auquel il faut insérer la ville i dans la permutation
	f!=nothing && writedlm(f, transpose(res), " ")
	
	dist::Float64 = 0.0
	min::Float64 = 0.0
	max::Float64 = 0.0
	limit::Float64 = 0.0
	i_limit::Int = 1
	
	while l < n
		#Construction de la Candidate List
		for i in 1:length(left)
			valuebest[i] = distancier[res[1],left[i]] + distancier[left[i],res[2]] - distancier[res[1],res[2]]
			indexbest[i] = 2 #index auquel ajouter la ville dans la solution
			for j = 2:length(res)
				dist = distancier[res[j],left[i]] + distancier[left[i],res[(j%l) + 1]] - distancier[res[j],res[(j%l) + 1]]
				if dist < valuebest[i]
					valuebest[i] = dist
					indexbest[i] = j+1
				end
			end
		end
		
		#Restriction de la Candidate List
		ind_sorted = sortperm(valuebest)
		min = valuebest[ind_sorted[1]]
		max = valuebest[ind_sorted[end]]
		limit = max - alpha * (max - min)
		i_limit = 1
		while i_limit <= length(left) && valuebest[ind_sorted[i_limit]] <= limit+1e-9
			i_limit += 1
		end	
		
		#Ajout d'un élément aléatoire de la RCL au meilleur endroit possible
		
		i_next_pick = rand(1:i_limit-1)

		next_pick = left[ind_sorted[i_next_pick]]
		insert!(res, indexbest[ind_sorted[i_next_pick]], next_pick)
		
		f!=nothing && writedlm(f, transpose(res), " ")
		deleteat!(left, findfirst(left,next_pick))
		pop!(valuebest)
		pop!(indexbest)
		l = l + 1
	end
	
	return solution(res,eval(res,distancier))
end

#Nearest Neighbour Heuristic
#La RCL est constituée des villes dont la distance à la dernière ville du chemin est la plus petite
#On ajoute la ville choisie dans la RCL après la derniere ville du chemin
function NNH(distancier::Array{Float64,2}, alpha::Float64, f=nothing)::solution
	n = size(distancier,1)
	idep = rand(1:n)
	res = [idep]
	left = setdiff(collect(1:n), res) #indices des villes qu'il reste à ajouter
	value = Array(Float64,length(left))
	l = 1 #length(res)
	while l < n
		#Construction de la Candidate List
		for i = 1:length(left)
			value[i] = distancier[res[end], left[i]]
		end
		
		#Restriction de la Candidate List
		ind_sorted = sortperm(value)
		min = value[ind_sorted[1]]
		max = value[ind_sorted[end]]
		limit = max - alpha * (max - min)
		i_limit = 1
		while i_limit <= length(left) && value[ind_sorted[i_limit]] <= limit+1e-9
			i_limit += 1
		end
		
		
		#Ajout d'un élément aléatoire de la RCL au meilleur endroit possible
		
		i_next_pick = rand(1:i_limit-1)

		next_pick = left[ind_sorted[i_next_pick]]
		push!(res, next_pick)

		deleteat!(left, findfirst(left,next_pick))
		pop!(value)
		f!=nothing && writedlm(f, transpose(res), " ")
		l = l + 1
	end
	return solution(res,eval(res,distancier))
end

#Mixed Insertion Heuristic
#On ajoute toujours la ville dont la distance à une autre ville du sous-tour est la plus petite
#La RCL est constituée des différents indices où l'on va insérer la ville dans le sous-tour
function MIH(hull::Array{Int,1}, distancier::Array{Float64,2}, alpha::Float64, f=nothing)::solution
n = size(distancier,1)
	res = deepcopy(hull) #enveloppe convexe
	l = length(res)
	left = setdiff(collect(1:n), res) #indices des villes qu'il reste à ajouter
	distances = Array(Float64,length(left)) #Pour chaque ville restant à ajouter, 
											#contient la plus petite distance de cette ville à une ville du sous-tour courant
	value = Array(Float64,length(res))
	f!=nothing && writedlm(f, transpose(res), " ")#output
	
	while l < n
		#Calcul de la plus petite distance de chaque ville aux villes du sous tour
		for (i,city) in enumerate(left)
			distances[i] = distancier[res[1],city] 
			for j = 2:length(res)
				dist = distancier[res[j],city] 
				if dist < distances[i]
					distances[i] = dist
				end
			end
		end
		#Selection de la ville la plus proche
		next_pick = left[sortperm(distances)[1]]
		
		#Construction de la RCL
		#value[j] => de combien le sous-tour augmente si on ajoute la ville à l'indice j+1
		for j = 1:length(res)
			value[j] = distancier[res[j],next_pick] + distancier[next_pick,res[(j%l)+1]] - distancier[res[j],res[(j%l)+1]]
		end	

		#Restriction de la RCL
		ind_sorted = sortperm(value)
		min = value[ind_sorted[1]]
		max = value[ind_sorted[end]]
		limit = max - alpha * (max - min)
		i_limit = 2
		while i_limit <= length(value) && value[ind_sorted[i_limit]] <= limit
			i_limit += 1
		end
	
		#Selection d'un élément aléatoire de la RCL
		i_index = rand(1:i_limit-1)
		index_picked = ind_sorted[i_index] + 1
	
		
		#Insertion de la ville à l'endroit choisi aléatoirement dans la RCL
		insert!(res, index_picked, next_pick)
		
		f!=nothing && writedlm(f, transpose(res), " ")
		
		deleteat!(left, findfirst(left,next_pick))
		pop!(distances)
		push!(value,0.0)
		l = l + 1
	end
	
	return solution(res,eval(res,distancier))
end

#Nearest Insertion Heuristic
#La RCL est constituée des villes les proches d'une ville du sous-tour
#Après avoir sélectionné une ville dans la RCL, on l'ajoute à la meilleur position possible
function NIH(hull::Array{Int,1}, distancier::Array{Float64,2}, alpha::Float64, f=nothing)::solution
	n = size(distancier,1)
	res = deepcopy(hull)	#enveloppe convexe
	l = length(res)
	left = setdiff(collect(1:n), res) #indices des villes qu'il reste à ajouter
	distances = Array(Float64,length(left)) #Pour chaque ville restant à ajouter, 
											#contient la plus petite distance de cette ville à une ville du sous-tour courant
	f!=nothing && writedlm(f, transpose(res), " ")#output

	while l < n
		#Construction de la Candidate List
		for (i,city) in enumerate(left)
			distances[i] = distancier[res[1],city] 
			for j = 2:length(res)
				dist = distancier[res[j],city] 
				if dist < distances[i]
					distances[i] = dist
				end
			end
		end
		
		#Restriction de la Candidate List
		ind_sorted = sortperm(distances)
		min = distances[ind_sorted[1]]
		max = distances[ind_sorted[end]]
		limit = max - alpha * (max - min)
		i_limit = 2
		while i_limit <= length(left) && distances[ind_sorted[i_limit]] <= limit
			i_limit += 1
		end
		
		
		
		#Selection d'un élément aléatoire de la RCL
		i_next_pick = rand(1:i_limit-1)
		next_pick = left[ind_sorted[i_next_pick]]
		
		#Calcul du meilleur endroit auquel l'ajouter
		valuebest = distancier[res[1],next_pick] + distancier[next_pick,res[2]] - distancier[res[1],res[2]]
		indexbest = 2 #index auquel ajouter la ville dans la solution
		
		for j = 2:length(res)
			dist = distancier[res[j],next_pick] + distancier[next_pick,res[(j%l) + 1]] - distancier[res[j],res[(j%l) + 1]]
			if dist < valuebest
				valuebest = dist
				indexbest = j+1
			end
		end	
		
		#Insertion de la ville au meilleur endroit possible
		insert!(res, indexbest, next_pick)
		
		f!=nothing && writedlm(f, transpose(res), " ")
		
		deleteat!(left, findfirst(left,next_pick))
		pop!(distances)
		l = l + 1
	end
	
	return solution(res,eval(res,distancier))
end
