!isdir("output") && error("Le dossier output n'existe pas")
cd("output")
!("output_tour.txt" in readdir()) && error("Pas de fichier output")

f = open("output_tour.txt")

const skip_construction = true

if !eof(f) #Si le fichier n'est pas vide
	#Lecture des coordonnées des villes
	l = split(chomp(readline(f))," ")
	xData = map(s -> Base.parse(Float64,s), l)
	
	l = split(chomp(readline(f))," ")
	yData = map(s -> Base.parse(Float64,s), l)
end

using PyCall

print("Loading PyPlot......") ; using PyPlot ; println(" Done.")
title("TSP")
hold(false) #Efface la figure entre deux affichages
println("Plotting...")

while !eof(f)
	

	l = split(chomp(readline(f))," ")

	xline = map(s -> xData[Base.parse(Int,s)], l)
	yline = map(s -> yData[Base.parse(Int,s)], l)
	
	push!(xline, xline[1])#fermeture du tour
	push!(yline, yline[1])#fermeture du tour
	
	if !skip_construction || length(xline) > length(xData)
		plot(xData,yData,"ro", xline, yline, "b-")
		if length(xline) > length(xData) 
			pause(1)#Taux de rafraichissement pour la recherche locale
		else 
			pause(0.01)#Taux de rafraichissement pour l'heuristique de construction
		end
	end
	
end
print("Hit <enter> to continue")
readline()
