using DelimitedFiles
dname = "../../COVID-19/csse_covid_19_data/csse_covid_19_time_series"
fname = "time_series_19-covid-Confirmed.csv"
A  = readdlm("$dname/$fname", ',');
a = findall(A[:,5:end] .== "")
for i=1:length(a)
   A[a[i][1], a[i][2]+4] = A[a[i][1], a[i][2]+3]
end

paises = ["US", "South Korea", "Switzerland", "Italy", "Germany", "Iran",
   "France", "Spain", "UK", "Greece", "Japan", "Mainland China"]

fontname       = "Helvetica Neue"
fontsize       = 20
legendfontsize = 13

"""
   mydate(str)
   Turns a struing of the form 03/02/20  into 2-March-20
"""
function mydate(str)
   d = Date(str, "mm/dd/yy")
   return "$(Dates.day(d))-$(Dates.monthname(d))-$(Dates.year(d))"
end

#

function smooth(s::Vector, k::Vector)
   @assert isodd(length(k)) "k should have odd length"

   mid = Int64((length(k)+1)/2)

   sout = copy(s)
   for i=1:length(s)
      sguys = maximum([i-(mid-1), 1]) : minimum([i+(mid-1), length(s)])
      kguys = sguys .- i .+ mid

      sout[i] = sum(s[sguys].*k[kguys])./sum(k[kguys])
   end
   return sout
end

#

# ###########################################
#
#  CUMULATIVE TOTAL
#
# ###########################################



days_previous = 15

confirmed = Array{Float64}(undef, length(paises), size(A,2)-4)



for i = 1:length(paises)
   pais = paises[i]

   # Find all rows for this country
   crows = findall(A[:,2] .== pais)

   # daily count starts in column 5; turn it into Float64s
   my_confirmed = Array{Float64}(A[crows,5:end])

   # Add all rows for the country
   my_confirmed = sum(my_confirmed, dims=1)[:]
   confirmed[i,:] = my_confirmed
end
v = sortperm(confirmed[:,end])[end:-1:1]
# We're going to put China last for now, just to keep plot colors
# consistent with previous versions
v = [v[1:end-1]; v[end]]
paises = paises[v]
confirmed = confirmed[v,:]


figure(1); clf(); println()
   # Make zeros into NaNs so they don't disturb the log plot
confirmed[confirmed.==0.0] .= NaN
for i=1:length(paises)
   pais = paises[i]

   dias = 1:size(A,2)-4
   semilogy(dias[end-days_previous:end] .- dias[end],
      confirmed[i, end-days_previous:end], "o-", label=pais)
   println("$pais = $(confirmed[i,end])")
end

gca().legend(fontsize=legendfontsize)
xlabel("days", fontsize=fontsize, fontname=fontname)
ylabel("confirmed cases", fontsize=fontsize, fontname=fontname)
title("Confirmed COVID-19 cases in selected countries", fontsize=fontsize, fontname=fontname)
gca().set_yticks([1, 10, 100, 1000])
gca().set_yticklabels(["1", "10", "100", "1000"])
h = gca().get_xticklabels()
for i=1:length(h)
   if h[i].get_position()[1] == 0.0
      h[i].set_text(mydate(A[1,end]))
   end
end
gca().set_xticklabels(h)
grid("on")
gca().tick_params(labelsize=16)

savefig("confirmed.png")
run(`sips -s format JPEG confirmed.png --out confirmed.jpg`)


#
# ###########################################
#
#  MULTIPLICATIVE CHANGE
#
# ###########################################


minimum_cases = 50
ngroup = 20
smkernel = [0.1, 0.4, 0.7, 0.4, 0.1]

using PyCall
hs      = Array{PyObject}(undef, 0)   # line handles

i = 1; f=1;
while i <= 3
   global i, f
   figure(2); clf(); println()
   plotted = Array{String}(undef, 0)     # plotted country strings
   for j=1:ngroup
      pais = paises[i]
      myconf = confirmed[i,:]
      myconf[myconf.<minimum_cases] .= NaN

      global mratio = (myconf[2:end]./myconf[1:end-1] .- 1) .* 100
      mratio = mratio[end-days_previous:end]
      u = findall(.!isnan.(mratio))

      global dias = 1:size(A,2)-4
      dias = dias[end-days_previous:end] .- dias[end]

      h = plot(dias[u], smooth(mratio[u], smkernel), "o-", label=pais)[1]
      if length(u)>0
         global hs = vcat(hs, h)
         plotted = vcat(plotted, pais)
         println("$pais = $(confirmed[i,end])")
      end

      global i += 1
      if i > length(paises)
         break
      end
   end

   if ~isempty(plotted)
      gca().legend(hs, plotted, fontsize=legendfontsize)
      xlabel("days from today", fontname=fontname, fontsize=fontsize)
      ylabel("% daily growth", fontname=fontname, fontsize=fontsize)
      title("% daily growth in cumulative confirmed COVID-19 cases\n(smoothed with a +/- 1-day moving average; $minimum_cases cases minimum)",
         fontname="Helvetica Neue", fontsize=20)
      PyPlot.show(); gcf().canvas.flush_events()  # make graphics are ready to ask for tick labels
      h = gca().get_xticklabels()
      for i=1:length(h)
         if h[i].get_position()[1] == 0.0
            h[i].set_text(mydate(A[1,end]))
         end
      end
      gca().set_xticklabels(h)
      gca().tick_params(labelsize=16)
      grid("on")
      figname = "multiplicative_factor"
      savefig("$(figname)_$f.png")
      run(`sips -s format JPEG $(figname)_$f.png --out $(figname)_$f.jpg`)
      f += 1
   end
end
