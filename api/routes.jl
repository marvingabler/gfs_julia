using Genie.Router
using Genie.Renderer.Json
using GRIB

grib_file = "/home/neo/Projekte/Predly/weather/gfs_workflow/download/data/gfs.20210109/06/gfs.t06z.pgrb2.0p25.f002"
f = GribFile(grib_file)   


function getVals(band, lat, lon)
  for (index, message) in enumerate(f)

    start_time = time()
    data_array = []
    parameter_name = message["parameterName"]
    parameter_unit = message["parameterUnits"]
    parameter_ecmf = message["nameECMF"]
    units_ecmf     = message["unitsECMF"]
    name           = message["name"]
    units          = message["units"]
    level          = message["level"]
    type_of_level  = message["typeOfLevel"]
    short_name     = message["shortName"]

      if index == band    

          near = Nearest(message)
          lons, lats, values, distances = find(near, message, lat, lon)
          seek(f, 0)
          println("Took ", time()-start_time)
          println(lons, lats, values, distances)
          destroy(near)
          return [lons,lats,values,distances]
      end
  end
end

route("/") do
  serve_static_file("welcome.html")
end

function plus(a, b)
  return string(a+b , a , b)
end

route("/hello") do 

  band = haskey(@params, :band) ? @params(:band) : 450
  lat = haskey(@params, :lat) ? @params(:lat) : 50.0
  lon = haskey(@params, :lon) ? @params(:lon) : 8.25

  start_time = time()
  resp = Dict()

  println( typeof(band), typeof(lat), typeof(lon))

  getVals(band, lat, lon)

  """
  for n in 1:length(lats)
    resp[n] = Dict()
    resp[n]["lat"] = lats[n]
    resp[n]["lon"] = lons[n]
    resp[n]["val"] = vals[n]
  end
  """

  return( "hi")
  
end
