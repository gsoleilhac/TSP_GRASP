!isdir("output") && error("Le dossier output n'existe pas")
cd("output")
!("output_PR.txt" in readdir()) && error("Pas de fichier output_PR")

f = open("output_PR.txt")
toggle_names = false


if !eof(f) #Si le fichier n'est pas vide
	#Lecture des coordonnées des villes
	l = split(readline(f)," ")
	l[end] = replace(l[end], "\n", "" )
	xData = map(s -> Base.parse(Float64,s), l)
	
	l = split(readline(f)," ")
	l[end] = replace(l[end], "\n", "" )
	yData = map(s -> Base.parse(Float64,s), l)
	
	#Lecture du nom des villes
	l = split(readline(f),",")
	l[end] = replace(l[end], "\n", "" )
	names = deepcopy(l)
end

using PyCall

print("Loading PyPlot......") ; using PyPlot ; println(" Done.")
title("Path Relinking")
hold(false) #Efface la figure entre deux affichages

println("Plotting...")
while !eof(f)


	l = split(readline(f)," ")
	l[end] = replace(l[end], "\n", "" )
	
	xline = map(s -> xData[Base.parse(Int,s)], l)
	yline = map(s -> yData[Base.parse(Int,s)], l)
	
	push!(xline, xline[1])
	push!(yline, yline[1])
	
	
	plot(xData,yData,"ro", xline, yline, "b-")
	
	if toggle_names
		for i = 1:length(names)
			annotate(names[i], (xData[i],yData[i]))
		end
	end
	
	if length(xline) > length(xData) 
		pause(0.5)#Taux de rafraichissement pour la recherche locale
	else 
		pause(0.5)#Taux de rafraichissement pour l'heuristique de construction
	end
	
end
print("Hit <enter> to continue")
readline()
